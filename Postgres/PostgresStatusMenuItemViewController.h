//
//  PostgresStatusMenuItemViewController.h
//  Postgres
//
//  Created by Mattt Thompson on 12/04/16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PostgresStatusMenuItemViewController : NSViewController

@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (weak) IBOutlet NSTextField *titleTextField;

- (void)startAnimatingWithTitle:(NSString *)title;
- (void)stopAnimatingWithTitle:(NSString *)title wasSuccessful:(BOOL)successful;

@end
