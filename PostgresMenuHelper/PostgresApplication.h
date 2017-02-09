/*
 * PostgresApplication.h
 */

#import <AppKit/AppKit.h>
#import <ScriptingBridge/ScriptingBridge.h>

/*
 * Standard Suite
 */

@interface  SBApplication(PostgresApplication)

- (BOOL) openPreferences;  // Opens the Preferences.
- (BOOL) checkForUpdates;  // Checks for updates.

@end
