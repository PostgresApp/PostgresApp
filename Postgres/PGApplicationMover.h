//
//  PGApplicationMover.h
//  Postgres
//
//  Created by Jakob Egger on 18.12.13.
//
//

#import <Foundation/Foundation.h>

@interface PGApplicationMover : NSObject

@property NSString *targetFolder;
@property NSString *targetName;

+(id)sharedApplicationMover;
-(void)validateApplicationPath;


@end
