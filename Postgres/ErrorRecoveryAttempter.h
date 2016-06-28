//
//  ErrorRecoveryAttempter.h
//  App Maker
//
//  Created by Jakob Egger on 07/04/16.
//  Copyright © 2016 Egger Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ErrorRecoveryAttempter : NSObject {
	BOOL (^recoveryAttempter)(NSError  * _Nonnull error, NSInteger optionIndex);
}
-(instancetype _Nonnull)initWithRecoveryAttempter:(BOOL(^_Nonnull)(NSError  * _Nonnull error, NSInteger optionIndex))ra;
@end
