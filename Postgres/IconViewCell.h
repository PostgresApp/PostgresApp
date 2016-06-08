//
//  IconViewCell.h
//  Postico
//
//  Created by Jakob Egger on 03.02.15.
//  Copyright (c) 2015 Egger Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IconViewCell : NSObject

@property id item;
@property NSArray<NSValue*> *highlightedRanges;
@property BOOL selected;
@property BOOL isInForeground;

-(void)drawWithFrame:(NSRect)frame inView:(NSView *)controlView;
-(void)getIconRect:(NSRect*)iconRect textRect:(NSRect*)textRect forFrame:(NSRect)frame;

@end
