/* -------------------------------------------------------------------------
 *
 * auth_permission_dialog.c
 *
 * Copyright (c) 2023, Jakob Egger
 *
 *
 * -------------------------------------------------------------------------
 */
#include "postgres.h"

#include <limits.h>

#include "libpq/auth.h"
#include "port.h"
#include "utils/guc.h"
#include "utils/timestamp.h"

#include <sys/socket.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <netinet/ip.h>
#include <netinet/ip6.h>
#include <sys/un.h>
#include <sys/ucred.h>
#include <sys/stat.h>
#include <libproc.h>
#include <sys/proc_info.h>

PG_MODULE_MAGIC;

/* GUC Variables */
static char *dialog_executable_path = NULL;

/* Original Hook */
static ClientAuthentication_hook_type original_client_auth_hook = NULL;

// shell quote a string (wrap with back ticks replace backticks with '\'')
// string is alloced, so you must free() the result
static char* ashqu(char *arg) {
	int len;
	int nticks;
	char *quoted;
	char *a, *q;

	// count number of backticks
	a = arg;
	nticks = 0;
	len = 0;
	while (*a) {
		len ++;
		if (*a=='\'') nticks ++;
		a++;
	}

	// add quotes
	quoted = malloc(2 + len + 4*nticks +1);
	a = arg;
	q = quoted;
	*(q++) = '\'';
	while (*a) {
		if (*a=='\'') {
			*(q++) = '\'';
			*(q++) = '\\';
			*(q++) = '\'';
			*(q++) = '\'';
		} else {
			*(q++) = *a;
		}
		a++;
	}
	*(q++) = '\'';
	*q = 0;

	return quoted;
}

static pid_t pid_for_tcp_local_remote(struct sockaddr *laddr, struct sockaddr *faddr) {
	int *allpids;
	int npids;
	
	npids = proc_listallpids(NULL, 0)/sizeof(int);
	if (npids == -1) {
		const char *errstr = strerror(errno);
		ereport(FATAL, (errcode(ERRCODE_INTERNAL_ERROR), errmsg("auth_permission_dialog: proc_listallpids: %s", errstr)));
	}
	allpids = calloc(sizeof(int), npids);
	if (proc_listallpids(allpids, sizeof(int)*npids) == -1) {
		const char *errstr = strerror(errno);
		free(allpids);
		ereport(FATAL, (errcode(ERRCODE_INTERNAL_ERROR), errmsg("auth_permission_dialog: proc_listallpids: %s", errstr)));
	}
	
	for (int i = 0; i<npids; i++) {
		int nfds;
		struct proc_fdinfo *fds;
		
		int pid = allpids[i];
		
		nfds = proc_pidinfo(pid, PROC_PIDLISTFDS, 0, NULL, 0) / sizeof(struct proc_fdinfo);
		if (nfds == -1) {
			const char *errstr = strerror(errno);
			free(allpids);
			ereport(FATAL, (errcode(ERRCODE_INTERNAL_ERROR), errmsg("auth_permission_dialog: proc_pidinfo(PROC_PIDLISTFDS): %s", errstr)));
		}
		fds = calloc(sizeof(struct proc_fdinfo), nfds);
		if (proc_pidinfo(pid, PROC_PIDLISTFDS, 0, fds, sizeof(struct proc_fdinfo)*nfds)==-1) {
			const char *errstr = strerror(errno);
			free(allpids);
			free(fds);
			ereport(FATAL, (errcode(ERRCODE_INTERNAL_ERROR), errmsg("auth_permission_dialog: proc_pidinfo(PROC_PIDLISTFDS): %s", errstr)));
		}
		
		for (int j = 0; j < nfds; j++) {
			if (fds[j].proc_fdtype == PROX_FDTYPE_SOCKET) {
				struct socket_fdinfo fdsockinfo;
				if (proc_pidfdinfo(pid, fds[j].proc_fd, PROC_PIDFDSOCKETINFO, &fdsockinfo, sizeof(fdsockinfo))==-1) {
					const char *errstr = strerror(errno);
					free(allpids);
					free(fds);
					ereport(FATAL, (errcode(ERRCODE_INTERNAL_ERROR), errmsg("auth_permission_dialog: proc_pidfdinfo(PROC_PIDFDSOCKETINFO): %s", errstr)));
				}
				if (fdsockinfo.psi.soi_kind == SOCKINFO_TCP) {
					if (laddr->sa_family == AF_INET6 && fdsockinfo.psi.soi_proto.pri_tcp.tcpsi_ini.insi_vflag==INI_IPV6) {
						// ipv6
						
						// check if ports differ
						if (((struct sockaddr_in6*)laddr)->sin6_port != fdsockinfo.psi.soi_proto.pri_tcp.tcpsi_ini.insi_lport) continue;
						if (((struct sockaddr_in6*)faddr)->sin6_port != fdsockinfo.psi.soi_proto.pri_tcp.tcpsi_ini.insi_fport) continue;
						
						// check if addr differ
						if (memcmp(&((struct sockaddr_in6*)laddr)->sin6_addr, &fdsockinfo.psi.soi_proto.pri_tcp.tcpsi_ini.insi_laddr.ina_6, sizeof(struct in6_addr))) continue;
						if (memcmp(&((struct sockaddr_in6*)faddr)->sin6_addr, &fdsockinfo.psi.soi_proto.pri_tcp.tcpsi_ini.insi_faddr.ina_6, sizeof(struct in6_addr))) continue;
						
						// we have a match!
						free(fds);
						free(allpids);
						return pid;
					} else if (laddr->sa_family == AF_INET && fdsockinfo.psi.soi_proto.pri_tcp.tcpsi_ini.insi_vflag==INI_IPV4) {
						//ipv4
						
						// check if ports differ
						if (((struct sockaddr_in*)laddr)->sin_port != fdsockinfo.psi.soi_proto.pri_tcp.tcpsi_ini.insi_lport) continue;
						if (((struct sockaddr_in*)faddr)->sin_port != fdsockinfo.psi.soi_proto.pri_tcp.tcpsi_ini.insi_fport) continue;
						
						// check if addr differ
						if (memcmp(&((struct sockaddr_in*)laddr)->sin_addr, &fdsockinfo.psi.soi_proto.pri_tcp.tcpsi_ini.insi_laddr.ina_46.i46a_addr4, sizeof(struct in_addr))) continue;
						if (memcmp(&((struct sockaddr_in*)faddr)->sin_addr, &fdsockinfo.psi.soi_proto.pri_tcp.tcpsi_ini.insi_faddr.ina_46.i46a_addr4, sizeof(struct in_addr))) continue;
						
						// we have a match!
						free(fds);
						free(allpids);

						return pid;
					}
				}
			}
		}
		free(fds);
	}
	free(allpids);
	return 0;
}

/*
 * Check authentication
 */
static void
auth_permission_dialog(Port *port, int status)
{
	struct stat st;
	int system_st;
	socklen_t sockaddr_size;
	struct sockaddr_storage local_sockaddr_storage;
	struct sockaddr *local_sockaddr = (struct sockaddr*)&local_sockaddr_storage;
	pid_t pid;
	char *command;
	
	/*
	 * Any other plugins which use ClientAuthentication_hook.
	 */
	if (original_client_auth_hook)
		original_client_auth_hook(port, status);

	/*
	 * Show a dialog for trust or peer auth.
	 */
	if (status != STATUS_OK) return;

	switch (port->hba->auth_method) {
		case uaTrust:
		case uaIdent:
		case uaPeer:
			break;
		default:
			return;
	}
		
	if (!dialog_executable_path || !strlen(dialog_executable_path)) {
		ereport(FATAL, (errcode(ERRCODE_INTERNAL_ERROR), errmsg("auth_permission_dialog.dialog_executable_path is not set")));
	}
	
	if (stat(dialog_executable_path, &st) != 0 || !S_ISREG(st.st_mode)) {
		ereport(FATAL, (errcode(ERRCODE_INTERNAL_ERROR), errmsg("auth_permission_dialog.dialog_executable_path is not a file")));
	}
	
	sockaddr_size = sizeof(local_sockaddr_storage);
	if (getsockname(port->sock, local_sockaddr, &sockaddr_size) == -1) {
		const char *errstr = strerror(errno);
		ereport(FATAL, (errcode(ERRCODE_INTERNAL_ERROR), errmsg("auth_permission_dialog: getsockname(): %s", errstr)));
	}
	
	if (local_sockaddr->sa_family == AF_UNIX) {
		// unix socket
		char *socket_path;
		struct xucred peercred;
		socklen_t peercred_len;
		int uid, gid;
		socklen_t pidlen;
		char *quoted_executable_path;
		char *quoted_socket_path;

		socket_path = ((struct sockaddr_un*)local_sockaddr)->sun_path;
		
		peercred_len = sizeof(peercred);
		if (getsockopt(port->sock, 0, LOCAL_PEERCRED, &peercred, &peercred_len) != 0 || peercred_len != sizeof(peercred) || peercred.cr_version != XUCRED_VERSION) {
			ereport(FATAL, (errcode(ERRCODE_INTERNAL_ERROR), errmsg("auth_permission_dialog: getsockopt(LOCAL_PEERCRED) failed")));
		}
		uid = peercred.cr_uid;
		gid = peercred.cr_gid;
		
		pidlen = sizeof(pid);
		if (getsockopt(port->sock, 0, LOCAL_PEERPID, &pid, &pidlen) != 0 || pidlen != sizeof(pid)) {
			ereport(FATAL, (errcode(ERRCODE_INTERNAL_ERROR), errmsg("auth_permission_dialog: getsockopt(LOCAL_PEERPID) failed")));
		}
		
		quoted_executable_path = ashqu(dialog_executable_path);
		quoted_socket_path = ashqu(socket_path);
		asprintf(&command, "'%s' --socket-path '%s' --client-pid %d --client-uid %d --client-gid %d", dialog_executable_path, socket_path, pid, uid, gid);
		free(quoted_executable_path);
		free(quoted_socket_path);
	} else {
		// tcp socket
		struct sockaddr_storage remote_sockaddr_storage;
		struct sockaddr *remote_sockaddr = (struct sockaddr*)&remote_sockaddr_storage;
		char server_host[40], client_host[40]; // max length of IPv6 addr = 32 hex characters + 7 colons + trailing NULL
		char server_port[6], client_port[6]; // max port (65535) has 5 digits + trailing NULL
		int gai_result;
		char *quoted_executable_path;

		gai_result = getnameinfo(local_sockaddr, sockaddr_size, server_host, 40, server_port, 6, NI_NUMERICHOST | NI_NUMERICSERV);
		if (gai_result != 0) {
			const char *errstr = gai_strerror(gai_result);
			ereport(FATAL, (errcode(ERRCODE_INTERNAL_ERROR), errmsg("auth_permission_dialog: getnameinfo(local_sockaddr): %s", errstr)));
		}

		sockaddr_size = sizeof(struct sockaddr_storage);
		if (getpeername(port->sock, remote_sockaddr, &sockaddr_size) == -1) {
			char *errstr = strerror(errno);
			ereport(FATAL, (errcode(ERRCODE_INTERNAL_ERROR), errmsg("auth_permission_dialog: getpeername(): %s", errstr)));
		}
		
		gai_result = getnameinfo(remote_sockaddr, sockaddr_size, client_host, 40, client_port, 6, NI_NUMERICHOST | NI_NUMERICSERV);
		if (gai_result != 0) {
			const char *errstr = gai_strerror(gai_result);
			ereport(FATAL, (errcode(ERRCODE_INTERNAL_ERROR), errmsg("auth_permission_dialog: getnameinfo(remote_sockaddr): %s", errstr)));
		}
		
		pid = pid_for_tcp_local_remote(remote_sockaddr, local_sockaddr);
		
		quoted_executable_path = ashqu(dialog_executable_path);
		asprintf(&command, "'%s' --server-addr %s --server-port %s --client-addr %s --client-port %s --client-pid %d", quoted_executable_path, server_host, server_port, client_host, client_port, pid);
		free(quoted_executable_path);
	}
	
	system_st = system(command);

	if (system_st == -1) {
		char *errstr = strerror(errno);
		free(command);
		ereport(FATAL, (errcode(ERRCODE_INTERNAL_ERROR), errmsg("auth_permission_dialog: system: %s", errstr)));
	}
	
	free(command);
	
	if (system_st != 0) {
		ereport(FATAL, (errcode(ERRCODE_INTERNAL_ERROR), errmsg("auth_permission_dialog: dialog_executable_path return status %d", system_st)));
	}
}

/*
 * Module Load Callback
 */
void
_PG_init(void)
{
	DefineCustomStringVariable("auth_permission_dialog.dialog_executable_path",
							   gettext_noop("Command to show a dialog."),
							   NULL,
							   &dialog_executable_path,
							   "",
							   PGC_SIGHUP,
							   0,
							   NULL, NULL, NULL);

	MarkGUCPrefixReserved("auth_permission_dialog");

	/* Install Hooks */
	original_client_auth_hook = ClientAuthentication_hook;
	ClientAuthentication_hook = auth_permission_dialog;
}
