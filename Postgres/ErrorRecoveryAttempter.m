//
//  ErrorRecoveryAttempter.m
//  App Maker
//
//  Created by Jakob Egger on 07/04/16.
//  Copyright © 2016 Egger Apps. All rights reserved.
//

#import "ErrorRecoveryAttempter.h"
#import <objc/message.h>

@implementation ErrorRecoveryAttempter

-(instancetype _Nonnull)initWithRecoveryAttempter:(BOOL(^_Nonnull)(NSError  * _Nonnull error, NSInteger optionIndex))ra;
{
	self = [super init];
	if (self) {
		recoveryAttempter = ra;
	}
	return self;
}

-(void)attemptRecoveryFromError:(NSError *)error optionIndex:(NSUInteger)recoveryOptionIndex delegate:(id)delegate didRecoverSelector:(SEL)didRecoverSelector contextInfo:(void *)contextInfo {
	BOOL didRecover = recoveryAttempter(error, recoveryOptionIndex);
	if (delegate && didRecoverSelector) ((void(*)(id, SEL, BOOL, void*))objc_msgSend)(delegate, didRecoverSelector, didRecover, contextInfo);
}

-(BOOL)attemptRecoveryFromError:(NSError *)error optionIndex:(NSUInteger)recoveryOptionIndex {
	return recoveryAttempter(error, recoveryOptionIndex);
}

@end
