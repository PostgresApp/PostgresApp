//
//  DatabasesViewController.m
//  Postgres
//
//  Created by Chris on 06/06/16.
//
//

#import "DatabasesViewController.h"
#import "PostgresServer.h"
#import "IconView.h"
#import "DBModel.h"

@implementation DatabasesViewController

-(void)setServer:(PostgresServer *)server {
	if (!server) {
		return;
	}
	
	_server = server;
	
	self.databases = [[NSMutableArray alloc] init];
	for (NSString *dbName in server.databases) {
		[self.databases addObject:[[DBModel alloc] initWithName:dbName]];
	}
	
	[self.iconView reloadData];
	if (self.databases.count > 0) {
		[self.iconView selectItem:self.databases[0] byExtendingSelection:NO];
	}
}



#pragma mark - NSOutlineViewDataSource

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(nullable id)item {
	if (item == nil) {
		return self.databases.count;
	}
	return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(nullable id)item {
	return [self.databases objectAtIndex:index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
	if (item == nil) {
		return YES;
	}
	return NO;
}



#pragma mark - Custom properties

- (NSString *)selectedDBName {
	return ((DBModel*)(self.iconView.selectedItemArray.firstObject)).name;
}

@end
