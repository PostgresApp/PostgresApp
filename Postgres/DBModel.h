//
//  DBModel.h
//  Postgres
//
//  Created by Chris on 06/06/16.
//
//

#import <Cocoa/Cocoa.h>

@interface DBModel : NSObject<NSCopying>

@property NSString *name;
@property (readonly, nonatomic) NSImage *image;

- (id)initWithName:(NSString *)name;

@end
