//
//  PGApplicationMover.m
//  Postgres
//
//  Created by Jakob Egger on 18.12.13.
//
//  Heavily influenced by "LetsMove", created by Andy Kim at Potion Factory LLC on 9/17/09
//  See https://github.com/potionfactory/LetsMove
//

#import "PGApplicationMover.h"

@implementation PGApplicationMover

+(id)sharedApplicationMover {
	static PGApplicationMover *sharedApplicationMover = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
		sharedApplicationMover = [[PGApplicationMover alloc] init];
		sharedApplicationMover.targetFolder = @"/Applications";
		sharedApplicationMover.targetName = @"Postgres.app";
    });
    return sharedApplicationMover;

}

-(void)validateApplicationPath {
	// just a sanity check
	if (_targetFolder.length==0 || ![[_targetName pathExtension] isEqualToString:@"app"]) {
		[NSException raise:@"InvalidSettingsException" format:@"[PGApplicationMover validateApplicationPath] called with invalid settings: %@, %@", _targetFolder, _targetName];
	}
	
	NSString *bundlePath = [NSBundle mainBundle].bundlePath;
	NSString *targetPath = [_targetFolder stringByAppendingPathComponent:_targetName];

	if ([bundlePath isEqualToString:targetPath]) {
		// everything just like it should be, nothing to do
		return;
	}
	
	NSFileManager *fm = [[NSFileManager alloc] init];
	
	// check if this app is already in the applications folder
	if ([fm contentsEqualAtPath:bundlePath andPath:targetPath]) {
		NSAlert *alert = [NSAlert alertWithMessageText:@"Open copy in Applications folder?"
										 defaultButton:@"Open Copy"
									   alternateButton:@"Quit"
										   otherButton:nil
							 informativeTextWithFormat:@"This copy of Postgres.app can't be started because it is not inside the Applications folder. There is an identical copy inside the Applications folder. Do you want to open that copy instead?"];
		NSInteger returnCode = [alert runModal];
		if (returnCode == NSAlertDefaultReturn) {
			[self terminateAndLaunchTarget];
		}
		exit(1);
	}
	
	// check if the app is even on the same volume as the application folder
	id bundleVolume = [[NSURL fileURLWithPath:bundlePath] resourceValuesForKeys:@[NSURLVolumeIdentifierKey] error:nil][NSURLVolumeIdentifierKey];
	id targetVolume = [[NSURL fileURLWithPath:_targetFolder] resourceValuesForKeys:@[NSURLVolumeIdentifierKey] error:nil][NSURLVolumeIdentifierKey];
	if (![bundleVolume isEqual:targetVolume]) {
		NSString *sideEffects = @"";
		if ([fm fileExistsAtPath:targetPath]) {
			sideEffects = [NSString stringWithFormat:@"\n\nThe version currently in your applications folder would be renamed to %@",self.replacementPathForExistingTarget.lastPathComponent];
		}
		NSAlert *alert = [NSAlert alertWithMessageText:@"Copy to Applications folder?"
										 defaultButton:@"Copy"
									   alternateButton:@"Quit"
										   otherButton:nil
							 informativeTextWithFormat:@"Postgres.app needs to be inside your Applications folder to work properly. Do you want to copy it automatically?%@", sideEffects];
		NSInteger returnCode = [alert runModal];
		if (returnCode != NSAlertDefaultReturn) exit(1);
		[self copyApplicationAndRelaunch];
	}
	
	
	
	NSString *currentFolder = bundlePath.stringByDeletingLastPathComponent;
	if (![currentFolder isEqualToString:_targetFolder]) {
		NSString *sideEffects = @"";
		if ([fm fileExistsAtPath:targetPath]) {
			sideEffects = [NSString stringWithFormat:@"\n\nThe version currently in your applications folder would be renamed to %@",self.replacementPathForExistingTarget.lastPathComponent];
		}
		NSAlert *alert = [NSAlert alertWithMessageText:@"Move to Applications folder?"
										 defaultButton:@"Move"
									   alternateButton:@"Quit"
										   otherButton:nil
							 informativeTextWithFormat:@"Postgres.app needs to be inside your Applications folder to work properly. Do you want to move it automatically?%@", sideEffects];
		NSInteger returnCode = [alert runModal];
		if (returnCode != NSAlertDefaultReturn) exit(1);
		[self moveApplicationAndRelaunch];
	}

	NSString *currentName = bundlePath.lastPathComponent;
	if (![currentName isEqualToString:_targetName]) {
		NSString *sideEffects = @"";
		if ([fm fileExistsAtPath:targetPath]) {
			sideEffects = [NSString stringWithFormat:@"\n\nThe application currently named %@ would be renamed to %@",_targetName,self.replacementPathForExistingTarget.lastPathComponent];
		}
		NSAlert *alert = [NSAlert alertWithMessageText:@"Rename to Postgres.app?"
										 defaultButton:@"Rename"
									   alternateButton:@"Quit"
										   otherButton:nil
							 informativeTextWithFormat:@"Postgres.app must be named ‘Postgres.app’ to function properly. Do you want to rename it automatically?%@", sideEffects];
		NSInteger returnCode = [alert runModal];
		if (returnCode != NSAlertDefaultReturn) exit(1);
		[self moveApplicationAndRelaunch];
	}
	
	return;
}

-(NSString*)replacementPathForExistingTarget {
	NSFileManager *fm = [[NSFileManager alloc] init];
	NSString *targetPath = [_targetFolder stringByAppendingPathComponent:_targetName];
	NSString *shortVersionString = [[NSBundle bundleWithPath:targetPath] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	NSString *replacementPath;
	if (shortVersionString) {
		replacementPath = [NSString stringWithFormat:@"%@/%@-%@.app", _targetFolder, _targetName.stringByDeletingPathExtension, shortVersionString];
		unsigned i = 1;
		while ([fm fileExistsAtPath:replacementPath]) {
			i++;
			replacementPath = [NSString stringWithFormat:@"%@/%@-%@-%u.app", _targetFolder, _targetName.stringByDeletingPathExtension, shortVersionString, i];
		}
	}
	else {
		unsigned i = 1;
		 do {
			i++;
			replacementPath = [NSString stringWithFormat:@"%@/%@-%u.app", _targetFolder, _targetName.stringByDeletingPathExtension, i];
		 } while ([fm fileExistsAtPath:replacementPath]);
	}
	return replacementPath;
}

-(void)moveApplicationAndRelaunch {
	NSFileManager *fm = [[NSFileManager alloc] init];
	NSString *bundlePath = [NSBundle mainBundle].bundlePath;
	NSString *targetPath = [_targetFolder stringByAppendingPathComponent:_targetName];
	NSError *error = nil;
	
	[self renameExistingApplication];
	
	BOOL didMove = [fm moveItemAtPath:bundlePath toPath:targetPath error:&error];
	if (!didMove) {
		if (!didMove) [self presentErrorAndTerminate:error];
	}
	
	[self terminateAndLaunchTarget];
}

-(void)copyApplicationAndRelaunch {
	NSFileManager *fm = [[NSFileManager alloc] init];
	NSString *bundlePath = [NSBundle mainBundle].bundlePath;
	NSString *targetPath = [_targetFolder stringByAppendingPathComponent:_targetName];
	NSError *error = nil;
	
	[self renameExistingApplication];
	
	BOOL didCopy = [fm copyItemAtPath:bundlePath toPath:targetPath error:&error];
	if (!didCopy) {
		if (!didCopy) [self presentErrorAndTerminate:error];
	}

	[self terminateAndLaunchTarget];
}

-(void)renameExistingApplication {
	NSFileManager *fm = [[NSFileManager alloc] init];
	NSString *targetPath = [_targetFolder stringByAppendingPathComponent:_targetName];
	NSError *error = nil;
	
	if ([fm fileExistsAtPath:targetPath]) {
		for (NSRunningApplication *runningApplication in [[NSWorkspace sharedWorkspace] runningApplications]) {
			NSString *executablePath = [[runningApplication executableURL] path];
			if ([executablePath hasPrefix:targetPath]) {
				NSAlert *alert = [NSAlert alertWithMessageText:@"Application running" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Postgres.app could not be moved to the Applications folder because the old version is still running."];
				[alert runModal];
				exit(1);
			}
		}

		BOOL didMove = [fm moveItemAtPath:targetPath toPath:self.replacementPathForExistingTarget error:&error];
		if (!didMove) [self presentErrorAndTerminate:error];
	}
}

-(void)presentErrorAndTerminate:(NSError*)error {
	[[NSAlert alertWithError:error] runModal];
	exit(1);
}

-(void)terminateAndLaunchTarget {
	// The shell script waits until the original app process terminates.
	// This is done so that the relaunched app opens as the front-most app.
	int pid = [[NSProcessInfo processInfo] processIdentifier];
	
	// Command run just before running open /final/path
	NSString *preOpenCmd = @"";
	
	NSString *targetPath = [_targetFolder stringByAppendingPathComponent:_targetName];
	NSString *quotedTargetPath = [NSString stringWithFormat:@"'%@'", [targetPath stringByReplacingOccurrencesOfString:@"'" withString:@"'\\''"]];
	
	// Before we launch the new app, clear xattr:com.apple.quarantine to avoid
	// duplicate "scary file from the internet" dialog.
	preOpenCmd = [NSString stringWithFormat:@"/usr/bin/xattr -d -r com.apple.quarantine %@", quotedTargetPath];
	
	NSString *script = [NSString stringWithFormat:@"(while /bin/kill -0 %d >&/dev/null; do /bin/sleep 0.1; done; %@; /usr/bin/open %@) &", pid, preOpenCmd, quotedTargetPath];
	
	[NSTask launchedTaskWithLaunchPath:@"/bin/sh" arguments:[NSArray arrayWithObjects:@"-c", script, nil]];
	
	exit(1);
}

@end