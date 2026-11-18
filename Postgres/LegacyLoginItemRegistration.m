//
//  LegacyLoginItemRegistration.m
//  Postgres
// 
// 
// Created by Jakob Egger on 05.05.26.
// This code is released under the terms of the PostgreSQL License.
// 


#import <Foundation/Foundation.h>

void RegisterLegacyLoginItem(CFURLRef url) {
	LSSharedFileListRef loginItemsList = LSSharedFileListCreate( nil, kLSSharedFileListSessionLoginItems, nil);
	LSSharedFileListInsertItemURL(loginItemsList, kLSSharedFileListItemLast, nil, nil, url, nil, nil);
	CFRelease(loginItemsList);
}

BOOL IsLoginItemRegistered(CFURLRef url) {
	LSSharedFileListRef loginItemsList = LSSharedFileListCreate( nil, kLSSharedFileListSessionLoginItems, nil);
	CFArrayRef loginItems = LSSharedFileListCopySnapshot(loginItemsList, nil);
	CFIndex count = CFArrayGetCount(loginItems);
	BOOL foundMatch = NO;
	for (CFIndex i=0; i<count; i++) {
		LSSharedFileListItemRef item = CFArrayGetValueAtIndex(loginItems, i);
		CFURLRef itemURL = LSSharedFileListItemCopyResolvedURL(item, 0, nil);
		if (itemURL) {
			foundMatch = CFEqual(itemURL, url);
			CFRelease(itemURL);
		}
		if (foundMatch) break;
	}
	CFRelease(loginItems);
	CFRelease(loginItemsList);
	return foundMatch;
}

void UnregisterLegacyLoginItem(CFURLRef url) {
	LSSharedFileListRef loginItemsList = LSSharedFileListCreate(nil, kLSSharedFileListSessionLoginItems, nil);
	CFArrayRef loginItems = LSSharedFileListCopySnapshot(loginItemsList, nil);
	CFIndex count = CFArrayGetCount(loginItems);
	for (CFIndex i=0; i<count; i++) {
		LSSharedFileListItemRef item = CFArrayGetValueAtIndex(loginItems, i);
		CFURLRef itemURL = LSSharedFileListItemCopyResolvedURL(item, 0, nil);
		if (itemURL) {
			BOOL foundMatch = CFEqual(itemURL, url);
			CFRelease(itemURL);
			if (foundMatch) {
				LSSharedFileListItemRemove(loginItemsList, item);
				break;
			}
		}
	}
	CFRelease(loginItems);
	CFRelease(loginItemsList);
}
