//
//  RecoveryAttempter.m
//  Postgres
//
//  Created by Jakob Egger on 22.09.14.
//
//

#import "RecoveryAttempter.h"

@implementation RecoveryAttempter

-(BOOL)attemptRecoveryFromError:(NSError *)error optionIndex:(NSUInteger)recoveryOptionIndex {
	NSDictionary *userInfo = error.userInfo;
	NSNumber *serverLogRecoveryOptionIndex = [userInfo objectForKey:@"ServerLogRecoveryOptionIndex"];
	
	if (serverLogRecoveryOptionIndex && recoveryOptionIndex == [serverLogRecoveryOptionIndex unsignedIntegerValue]) {
		[[NSWorkspace sharedWorkspace] openFile:userInfo[@"ServerLogPath"] withApplication:@"Console"];
	}
	
	return NO;
}

-(void)attemptRecoveryFromError:(NSError *)error optionIndex:(NSUInteger)recoveryOptionIndex delegate:(id)delegate didRecoverSelector:(SEL)didRecoverSelector contextInfo:(void *)contextInfo {
	[self attemptRecoveryFromError:error optionIndex:recoveryOptionIndex];
	if (delegate) {
		NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[delegate methodSignatureForSelector:didRecoverSelector]];
		[inv setTarget:delegate];
		[inv setSelector:didRecoverSelector];
		BOOL no = NO;
		[inv setArgument:&no atIndex:2];
		[inv setArgument:&contextInfo atIndex:3];
		[inv invoke];
	}
}

@end
