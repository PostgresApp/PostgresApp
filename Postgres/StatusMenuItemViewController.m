//
//  StatusMenuItemViewController.m
//  Postgres
//
//  Created by Chris on 05/06/16.
//
//

#import "StatusMenuItemViewController.h"
#import "ServerManager.h"

@implementation StatusMenuItemViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self.view addTrackingArea:[[NSTrackingArea alloc] initWithRect:self.view.bounds
															options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways
															  owner:self
														   userInfo:nil
								]
	];
}


- (void)mouseEntered:(NSEvent *)theEvent {
	[self.popover showRelativeToRect:self.view.bounds ofView:self.view preferredEdge:NSMaxYEdge];
}


- (void)mouseExited:(NSEvent *)theEvent {
	[self.popover close];
}



#pragma mark - Custom properties

- (NSMutableArray *)servers {
	return [ServerManager sharedManager].servers;
}

@end
