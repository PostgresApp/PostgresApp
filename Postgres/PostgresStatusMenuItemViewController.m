//
//  PostgresStatusMenuItemViewController.m
//  Postgres
//
//  Created by Mattt Thompson on 12/04/16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PostgresStatusMenuItemViewController.h"

@implementation PostgresStatusMenuItemViewController
@synthesize progressIndicator;
@synthesize titleTextField;

- (void)startAnimatingWithTitle:(NSString *)title {
    self.titleTextField.stringValue = title;
    [self.progressIndicator startAnimation:self];
}

- (void)stopAnimatingWithTitle:(NSString *)title wasSuccessful:(BOOL)successful {
    self.titleTextField.stringValue = title;
    [self.progressIndicator stopAnimation:self];
}

@end
