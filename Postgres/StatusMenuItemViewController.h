//
//  StatusMenuItemViewController.h
//  Postgres
//
//  Created by Chris on 05/06/16.
//
//

#import <Cocoa/Cocoa.h>

@interface StatusMenuItemViewController : NSViewController

@property (readonly, nonatomic) NSMutableArray *servers;
@property IBOutlet NSPopover *popover;

@end
