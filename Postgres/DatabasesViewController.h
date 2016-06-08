//
//  DatabasesViewController.h
//  Postgres
//
//  Created by Chris on 06/06/16.
//
//

#import <Cocoa/Cocoa.h>

@class PostgresServer, IconView;

@interface DatabasesViewController : NSViewController <NSOutlineViewDataSource, NSOutlineViewDelegate>

@property NSMutableArray *databases;
@property (nonatomic) PostgresServer *server;
@property (nonatomic, readonly) NSString *selectedDBName;

@property IBOutlet IconView *iconView;

@end
