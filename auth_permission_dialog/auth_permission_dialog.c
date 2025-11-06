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

void		_PG_init(void);

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
	quoted = malloc(2 + len + 3*nticks +1);
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
	pid_t *allpids;
	int npids;
	
	// proc_listallpids and proc_pidinfo return the number of results
	// but they take the size of the buffer as argument (number of results * sizeof result)
	// when called with NULL argument, they return 20 more than necessary (in case number of results changes between the syscalls)
	// more info: https://zameermanji.com/blog/2021/8/1/counting-open-file-descriptors-on-macos/
	npids = proc_listallpids(NULL, 0);
	if (npids == -1) {
		const char *errstr = strerror(errno);
		ereport(FATAL, (errcode(ERRCODE_INTERNAL_ERROR), errmsg("auth_permission_dialog: proc_listallpids: %s", errstr)));
	}
	allpids = calloc(sizeof(pid_t), npids);
	npids = proc_listallpids(allpids, sizeof(pid_t)*npids);
	if (npids == -1) {
		const char *errstr = strerror(errno);
		free(allpids);
		ereport(FATAL, (errcode(ERRCODE_INTERNAL_ERROR), errmsg("auth_permission_dialog: proc_listallpids: %s", errstr)));
	}
	
	for (int i = 0; i<npids; i++) {
		int nfds;
		struct proc_fdinfo *fds;
		
		pid_t pid = allpids[i];
		nfds = proc_pidinfo(pid, PROC_PIDLISTFDS, 0, NULL, 0);
		if (nfds == -1) {
			const char *errstr = strerror(errno);
			free(allpids);
			ereport(FATAL, (errcode(ERRCODE_INTERNAL_ERROR), errmsg("auth_permission_dialog: proc_pidinfo(PROC_PIDLISTFDS): %s", errstr)));
		}
		fds = calloc(sizeof(struct proc_fdinfo), nfds);
		nfds = proc_pidinfo(pid, PROC_PIDLISTFDS, 0, fds, sizeof(struct proc_fdinfo)*nfds);
		if (nfds == -1) {
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

static const char* authentication_name(Port *port) {
	switch (port->hba->auth_method) {
		case uaTrust:
			return "\"trust\" authentication";
		case uaIdent:
			return "\"ident\" authentication";
		case uaPeer:
			return "\"peer\" authentication";
		default:
			return "authentication";
	}
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
	char *client_display_name = NULL;
	char *client_display_name_long = NULL;
	
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
		asprintf(&command, "%s --socket-path %s --client-pid %d --client-uid %d --client-gid %d", quoted_executable_path, quoted_socket_path, pid, uid, gid);
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
		
		if (pid <= 1 && strcmp(client_host, "::1")!=0 && strcmp(client_host, "127.0.0.1")!=0) client_display_name = strdup(client_host);
		
		quoted_executable_path = ashqu(dialog_executable_path);
		asprintf(&command, "%s --server-addr %s --server-port %s --client-addr %s --client-port %s --client-pid %d", quoted_executable_path, server_host, server_port, client_host, client_port, pid);
		free(quoted_executable_path);
	}
	
	system_st = system(command);

	if (WIFEXITED(system_st) && WEXITSTATUS(system_st) == 0) {
		// client connection is allowed
		// clean up and return
		if (client_display_name) free(client_display_name);
		free(command);
		return;
	}
	else {
		// client is denied or an error occurred
		// first collect info about the client that we need later
		
		pid_t ppid, tlpid;
		tlpid = 0;
		ppid = pid;
		while (ppid > 1) {
			struct proc_bsdshortinfo shortinfo;
			int status;
			tlpid = ppid;
			status = proc_pidinfo(ppid, PROC_PIDT_SHORTBSDINFO, 0, &shortinfo, sizeof(shortinfo));
			if (!status) break;
			ppid = shortinfo.pbsi_ppid;
		}
		if (tlpid) {
			char pidpath[PROC_PIDPATHINFO_SIZE] = {0};
			int status;
			status = proc_pidpath(tlpid, &pidpath, PROC_PIDPATHINFO_SIZE);
			if (status) {
				char *last_slash = strrchr(pidpath, '/');
				client_display_name = strdup(last_slash ? last_slash + 1 : pidpath);
				client_display_name_long = strdup(pidpath);
			} else {
				client_display_name = strdup("unknown process");
				client_display_name_long = strdup("unknown process");
			}
		}
		if (tlpid && tlpid != pid) {
			char pidpath[PROC_PIDPATHINFO_SIZE] = {0};
			int status;
			status = proc_pidpath(pid, &pidpath, PROC_PIDPATHINFO_SIZE);
			if (status && strcmp(client_display_name_long, pidpath)!=0) {
				char *client_display_name_very_long;
				
				asprintf(&client_display_name_very_long, "%s (via %s)", client_display_name_long, pidpath);
				free(client_display_name_long);
				client_display_name_long = client_display_name_very_long;
			}
		}
		if (!client_display_name) client_display_name = strdup("unknown process");
		if (!client_display_name_long) client_display_name_long = strdup(client_display_name);
		
		if (system_st == -1) {
			char *errstr = strerror(errno);
			ereport(FATAL,
					(errmsg("Postgres.app failed to verify %s", authentication_name(port)),
					 errdetail("An error occurred while running the helper application. For more information see https://postgresapp.com/l/app-permissions/"),
					 errdetail_log("auth_permission_dialog: %s is not allowed to connect without a password because system(%s) failed: %s. For more information see https://postgresapp.com/l/app-permissions/", client_display_name_long, command, errstr),
					 errhint("Please check the server log and submit an issue to https://github.com/PostgresApp/PostgresApp/issues")));
		}
		else if (WIFEXITED(system_st)) {
			int exit_st = WEXITSTATUS(system_st);
			if (exit_st == 1 || exit_st == 2) {
				ereport(FATAL,
						(errmsg("Postgres.app rejected %s", authentication_name(port)),
						 errdetail("You did not allow %s to connect without a password. For more information see https://postgresapp.com/l/app-permissions/", client_display_name),
						 errdetail_log("auth_permission_dialog: %s is not allowed to connect without a password because system(%s) returned with exit status %d. For more information see https://postgresapp.com/l/app-permissions/", client_display_name_long, command, exit_st),
						 errhint("Configure app permissions in Postgres.app settings")));
			}
			else if (exit_st == 3) {
				ereport(FATAL,
						(errmsg("Postgres.app rejected %s", authentication_name(port)),
						 errdetail("Unknown processes are not allowed to connect without a password. For more information see https://postgresapp.com/l/app-permissions/"),
						 errdetail_log("auth_permission_dialog: %s is not allowed to connect without a password because system(%s) returned with exit status %d. For more information see https://postgresapp.com/l/app-permissions/", client_display_name_long, command, exit_st),
						 errhint("Change pg_hba.conf to require a password")));
			}
			else if (exit_st == 4) {
				ereport(FATAL,
						(errmsg("Postgres.app failed to verify %s", authentication_name(port)),
						 errdetail("Postgres.app failed to show a dialog. This can happen when the user that started the server is no longer logged in. Try restarting the PostgreSQL server. For more information see https://postgresapp.com/l/app-permissions/"),
						 errdetail_log("auth_permission_dialog: %s is not allowed to connect without a password because system(%s) returned with exit status %d. For more information see https://postgresapp.com/l/app-permissions/", client_display_name_long, command, exit_st),
						 errhint("Change pg_hba.conf to require a password")));
			}
			else if (exit_st) {
				ereport(FATAL,
						(errmsg("Postgres.app failed to verify %s", authentication_name(port)),
						 errdetail("An error occurred while running the helper application. For more information see https://postgresapp.com/l/app-permissions/"),
						 errdetail_log("auth_permission_dialog: %s is not allowed to connect without a password because system(%s) returned with exit status %d. For more information see https://postgresapp.com/l/app-permissions/", client_display_name_long, command, exit_st),
						 errhint("Please check the server log and submit an issue to https://github.com/PostgresApp/PostgresApp/issues")));
			}
		}
		else if (WIFSIGNALED(system_st) && WTERMSIG(system_st) == 15) {
			int termsig = WTERMSIG(system_st);
			ereport(FATAL,
					(errmsg("Postgres.app failed to verify %s", authentication_name(port)),
					 errdetail("You did not confirm the permission dialog. For more information see https://postgresapp.com/l/app-permissions/"),
					 errdetail_log("auth_permission_dialog: %s is not allowed to connect without a password because system(%s) terminated with signal %d. For more information see https://postgresapp.com/l/app-permissions/", client_display_name_long, command, termsig),
					 errhint("Configure app permissions in Postgres.app settings")));
		}
		else if (WIFSIGNALED(system_st)) {
			int termsig = WTERMSIG(system_st);
			ereport(FATAL,
					(errmsg("Postgres.app failed to verify %s", authentication_name(port)),
					 errdetail("The helper application terminated with signal %d. For more information see https://postgresapp.com/l/app-permissions/", termsig),
					 errdetail_log("auth_permission_dialog: %s is not allowed to connect without a password because system(%s) terminated with signal %d. For more information see https://postgresapp.com/l/app-permissions/", client_display_name_long, command, termsig),
					 errhint("You may be able to connect by editing app permission in Postgres.app settings or by restarting the PostgreSQL server. Please report this error to https://github.com/PostgresApp/PostgresApp/issues")));
		}
		else {
			ereport(FATAL,
					(errmsg("Postgres.app failed to verify %s", authentication_name(port)),
					 errdetail("An error occurred while running the helper application. For more information see https://postgresapp.com/l/app-permissions/"),
					 errdetail_log("auth_permission_dialog: %s is not allowed to connect without a password because system(%s) returned %d. For more information see https://postgresapp.com/l/app-permissions/", client_display_name_long, command, system_st),
					 errhint("Please check the server log and submit an issue to https://github.com/PostgresApp/PostgresApp/issues")));
		}
		
	}
}

/*
 * Module Load Callback
 */
void
_PG_init(void)
{
	DefineCustomStringVariable("auth_permission_dialog.dialog_executable_path",
							   gettext_noop("Postgres.app uses this executable to show a permission dialog when a client tries to connect using trust, peer or ident authentication."),
							   NULL,
							   &dialog_executable_path,
							   "",
							   PGC_SIGHUP,
							   0,
							   NULL, NULL, NULL);

#if PG_VERSION_NUM >= 150000
	MarkGUCPrefixReserved("auth_permission_dialog");
#else
	EmitWarningsOnPlaceholders("auth_permission_dialog");
#endif

	/* Install Hooks */
	original_client_auth_hook = ClientAuthentication_hook;
	ClientAuthentication_hook = auth_permission_dialog;
}
