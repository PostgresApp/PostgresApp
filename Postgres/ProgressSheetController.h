//
//  ProgressSheetController.h
//  Postgres
//
//  Created by Chris on 08/06/16.
//
//

#import <Cocoa/Cocoa.h>

@protocol ProgressSheetControllerDelegate <NSObject>

- (void)progressSheetCancel:(id)sender;

@end


@interface ProgressSheetController : NSWindowController

@property NSString *message;
@property BOOL animateProgressBar;
@property id <ProgressSheetControllerDelegate> delegate;

- (IBAction)cancel:(id)sender;

@end
