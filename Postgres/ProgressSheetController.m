//
//  ProgressSheetController.m
//  Postgres
//
//  Created by Chris on 08/06/16.
//
//

#import "ProgressSheetController.h"

@implementation ProgressSheetController

- (void)windowDidLoad {
	[super windowDidLoad];
	self.animateProgressBar = YES;
}


- (IBAction)cancel:(id)sender {
	[self.delegate progressSheetCancel:self];
}

@end
