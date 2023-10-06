---
redirect_from:
  - /l/app-permissions/
title: Client App Permissions 
---


PostgreSQL Client App Permissions
=================================

By default, PostgreSQL accepts connections from apps on your computer without a password.
This is called the "trust" authentication method.

Permission Dialogs
------------------

To improve the security of PostgreSQL on your Mac, Postgres.app 2.7 and later shows a permission dialog before allowing a client app to connect without a password.

For example, if you use Postico to connect to Postgres.app, you may see a warning like this:

> “Postico” wants to connect to Postgres.app without using a password
>
> [Don't Allow] [OK]

If you click "OK", then Postgres.app will allow the app to connect. Your choice will be remembered in Postgres.app settings, so you will see the dialog only the first time you connect.

If you click "Don't Allow", then Postgres.app will refuse the connection. The client app will show a warning similar to the following:

> FATAL:  Postgres.app rejected "trust" authentication
> DETAIL:  auth_permission_dialog: system('/Applications/Postgres.app/Contents/MacOS/PostgresPermissionDialog' --server-addr ::1 --server-port 5432 --client-addr ::1 --client-port 12345 --client-pid 1234) returned 256
> HINT:  Try resetting app permissions in Postgres.app, or change hba.conf to require a password.

Resetting Client App Permissions
--------------------------------

If you change your mind, and want to allow future connections from an app, you can reset Postgres.app client permissions:

1. Open Postgres.app
2. Choose "Settings" from the "Postgres" menu
3. Click the "Reset App Permission" button
4. The next time the app tries to connect, the alert will be shown again

Unknown Processes
-----------------

In some cases, Postgres.app might not be able to identify the source of a connection attempt.

If that happens, Postgres.app automatically blocks the passwordless authentication attempt. A warning is shown in the UI, and a message is written to the PostgreSQL server log.

To allow these unknown processes to connect to Postgres.app, we recommend to configure password authentication.

Disabling Permission Dialogs
----------------------------

This will reduce the security of your Mac. We recommend to configure password authentication instead of disabling permission dialogs.

You can disable the permission dialogs in Postgres.app settings:

1. Open Postgres.app
2. Choose "Settings" from the "Postgres" menu
3. Uncheck the box labelled "Ask for permission when apps connect without password"
4. Postgres.app will now allow passwordless authentication (if allowed in pg_hba.conf)

This will also allow unknown processes to connect to Postgres.app without using a password.