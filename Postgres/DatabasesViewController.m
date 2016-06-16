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
#import <libpq-fe.h>

@implementation DatabasesViewController

-(void)setServer:(PostgresServer *)server {
	if (!server) {
		return;
	}
	
	_server = server;
	self.databases = [[NSMutableArray alloc] init];
	
	NSString *connectionString = [NSString stringWithFormat:@"postgresql://:%lu", self.server.port];
	PGconn *conn = PQconnectdb(connectionString.UTF8String);
	PGresult *result = PQexec(conn, "SELECT datname FROM pg_database WHERE datallowconn ORDER BY LOWER(datname)");
	
	//ConnStatusType status = PQstatus(conn);
	
	for (int i=0; i<PQntuples(result); i++) {
		NSString *value = @(PQgetvalue(result, i, 0));
		DBModel *child = [[DBModel alloc] init];
		child.name = value;
		[self.databases addObject:child];
	}
	
	PQfinish(conn);
	
	[self.iconView reloadData];
	if (self.databases.count > 0) {
		[self.iconView selectItem:self.databases[0] byExtendingSelection:NO];
	}
	[self.iconView layoutSubtreeIfNeeded];
	[self.iconView scrollRectToVisible:NSMakeRect(0, 0, 1, 1)];
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
