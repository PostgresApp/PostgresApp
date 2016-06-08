//
//  IconViewSection.h
//  Postico
//
//  Created by Jakob Egger on 02.02.15.
//  Copyright (c) 2015 Egger Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IconView;

@interface IconViewSection : NSObject<NSCopying>

@property id item;
@property NSArray *containedItems;
@property BOOL highlightedSectionHeader;

@property(weak) IconView *iconView;

@end
