// compile with:
// swiftc -sdk /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk -import-objc-header bridging-header.h -L$(pg_config --libdir) -I$(pg_config --includedir) -lpq main.swift

import Foundation
let conn = PQconnectdb("postgresql://localhost".cString(using: .utf8))
if PQstatus(conn) == CONNECTION_OK {
    let result = PQexec(conn, "SELECT datname FROM pg_database WHERE datallowconn")
    for i in 0 ..< PQntuples(result) {
        guard let value = PQgetvalue(result, i, 0) else { continue }
        let dbname = String(cString: value)
        print(dbname)
    }
    PQclear(result)
}
PQfinish(conn)
