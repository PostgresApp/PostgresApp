/*
  compile with the following command:
  clang main.c -I`pg_config --includedir` -L`pg_config --libdir` -lpq
*/

#include <libpq-fe.h>

int main() {
	PGconn *conn = PQconnectdb("postgresql://localhost");
	if (PQstatus(conn) == CONNECTION_OK) {
	    PGresult *result = PQexec(conn, "SELECT datname FROM pg_database");
	    for (int i = 0; i < PQntuples(result); i++) {
	        char *value = PQgetvalue(result, i, 0);
	        if (value) printf("%s\n", value);
	    }
	    PQclear(result);
	}
	PQfinish(conn);
}