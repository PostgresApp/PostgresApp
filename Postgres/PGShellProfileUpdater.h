//
//  PGShellProfileUpdater.h
//  Postgres
//
//  Created by Jakob Egger on 18.12.13.
//
//

#import <Foundation/Foundation.h>

@interface PGShellProfileUpdater : NSObject

@property NSArray *profilePaths;
@property NSArray *oldPaths;
@property NSString *currentPath;


+(PGShellProfileUpdater*)sharedUpdater;
-(void)checkProfiles;

@end
