//
//  OpenURLAsLoginItem.m
//  Postgres
// 
// 
// Created by Jakob Egger on 06.05.26.
// This code is released under the terms of the PostgreSQL License.
// 

#import <Foundation/Foundation.h>

BOOL OpenURLAsLoginItem(CFURLRef url) {
	struct LSLaunchURLSpec launchSpec = {};
	launchSpec.appURL = url;
	struct AEDesc launchAsLoginItem = {};
	AEKeyword launchAsLoginItemKeyword = keyAELaunchedAsLogInItem;
	OSErr err = AECreateDesc(typeEnumerated, &launchAsLoginItemKeyword, 4, &launchAsLoginItem);
	if (err != noErr) {
		NSLog(@"AECreateDesc() return OSErr %d", (int)err);
		return NO;
	}
	NSLog(@"AECreateDesc: %d", (int)err);
	launchSpec.passThruParams = &launchAsLoginItem;
	CFURLRef launchedURL = NULL;
	OSStatus status = LSOpenFromURLSpec(&launchSpec, &launchedURL);
	AEDisposeDesc(&launchAsLoginItem);
	if (status != noErr) {
		NSLog(@"LSOpenFromURLSpec() return OSStatus %d", (int)status);
		return NO;
	}
	return YES;
}
