//
//  PGShellProfileUpdater.m
//  Postgres
//
//  Created by Jakob Egger on 18.12.13.
//
//

#import "PGShellProfileUpdater.h"
#import "PostgresServer.h"

#define xstr(a) str(a)
#define str(a) #a

static NSString *kIgnoredProfileFilesKey = @"IgnoredProfileFiles";

@implementation PGShellProfileUpdater

+(PGShellProfileUpdater*)sharedUpdater {
	static PGShellProfileUpdater *sharedProfileUpdater = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedProfileUpdater = [[PGShellProfileUpdater alloc] init];
		NSString *homeDirectory = NSHomeDirectory();
		sharedProfileUpdater.profilePaths = @[
											  [homeDirectory stringByAppendingPathComponent:@".profile"],
											  [homeDirectory stringByAppendingPathComponent:@".bashrc"],
											  [homeDirectory stringByAppendingPathComponent:@".zshenv"],
											  [homeDirectory stringByAppendingPathComponent:@".zshrc"],
											  [homeDirectory stringByAppendingPathComponent:@".zlogin"],
											  [homeDirectory stringByAppendingPathComponent:@".zprofile"],
											  [homeDirectory stringByAppendingPathComponent:@".bash_profile"],
											  [homeDirectory stringByAppendingPathComponent:@".tcshrc"],
											  [homeDirectory stringByAppendingPathComponent:@".cshrc"],
											  [homeDirectory stringByAppendingPathComponent:@".kshrc"]
											  ];
		sharedProfileUpdater.oldPaths = @[
										  @"/Applications/Postgres.app/Contents/MacOS/bin",
										  @"/Applications/Postgres93.app/Contents/MacOS/bin",
										  @"/Applications/Postgres.app/Contents/Versions/9.3/bin"
										  ];
		sharedProfileUpdater.currentPath = [NSString stringWithFormat:@"/Applications/Postgres.app/Contents/Versions/%s/bin", xstr(PG_MAJOR_VERSION)];
    });
	return sharedProfileUpdater;
}

-(void)checkProfiles {
	NSArray *ignoredKeys = [[NSUserDefaults standardUserDefaults] arrayForKey:kIgnoredProfileFilesKey];
	for (NSString* profilePath in _profilePaths) {
		if ([ignoredKeys containsObject:profilePath]) continue;
		NSString *profileString = [NSString stringWithContentsOfFile:profilePath usedEncoding:nil error:nil];
		NSArray *lines = [profileString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
		NSMutableArray *updatedLines = [[NSMutableArray alloc] init];
		NSMutableArray *changedOldLines = [[NSMutableArray alloc] init];
		NSMutableArray *changedNewLines = [[NSMutableArray alloc] init];
		for(NSString *line in lines) {
			NSString *trimmedLine = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
			NSString *newLine = line;
			if (trimmedLine.length && [trimmedLine characterAtIndex:0]!='#') {
				for (NSString *oldPath in _oldPaths) {
					if ([newLine rangeOfString:oldPath].length) {
						newLine = [newLine stringByReplacingOccurrencesOfString:oldPath withString:_currentPath];
					}
				}
				if (newLine!=line) {
					[changedOldLines addObject:line];
					[changedNewLines addObject:newLine];
				}
			}
			[updatedLines addObject:newLine];
		}
		if (changedOldLines.count) {
			NSAlert *alert = [NSAlert alertWithMessageText: @"Update profile file?"
											 defaultButton: @"Update"
										   alternateButton: @"Don't update & don't ask again"
											   otherButton: @"Don't update"
								 informativeTextWithFormat: @"The file %@ contains a path of an older version of Postgres. Do you want to update it automatically?\n\nOld:\n%@\n\nNew:\n%@", profilePath.lastPathComponent, [changedOldLines componentsJoinedByString:@"\n"], [changedNewLines componentsJoinedByString:@"\n"]
							  ];
			NSInteger returnCode = [alert runModal];
			if (returnCode==NSAlertDefaultReturn) {
				NSString *updatedProfileString = [updatedLines componentsJoinedByString:@"\n"];
				NSError *error;
				BOOL didUpdate = [updatedProfileString writeToFile:profilePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
				if (!didUpdate) {
					[[NSAlert alertWithError:error] runModal];
				}
			} else if (returnCode==NSAlertAlternateReturn) {
				ignoredKeys = ignoredKeys ? [ignoredKeys arrayByAddingObject:profilePath] : @[profilePath];
				[[NSUserDefaults standardUserDefaults] setObject:ignoredKeys forKey:kIgnoredProfileFilesKey];
			}
		}
	}
}

@end
