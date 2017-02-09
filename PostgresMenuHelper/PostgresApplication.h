/*
 * Postgres-AppleScript.h
 */

#import <AppKit/AppKit.h>
#import <ScriptingBridge/ScriptingBridge.h>


@class PostgresApplication;



/*
 * Standard Suite
 */

@interface PostgresApplication : SBApplication

- (BOOL) openPreferences;  // Opens the Preferences.
- (BOOL) checkForUpdates;  // Checks for updates.

@end
