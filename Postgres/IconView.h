//
//  IconView.h
//  Postico
//
//  Created by Jakob Egger on 02.02.15.
//  Copyright (c) 2015 Egger Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IconViewCell.h"

@class IconViewSection, IconView;

@protocol IconViewDelegate <NSObject>
@optional
-(void)iconView:(IconView*)iconView didAbortRenameForItem:(id)item;
@end

@interface IconView : NSView {
	IconViewSection *mainSection;
	NSInteger numColumns;
	
	NSMutableDictionary<id,NSValue*> *itemRects, *sectionRects;
	
	BOOL isFirstResponder;
	__weak id lastSelectItem;
	
	id currentlyRenamingItem;
	NSTextField *renameField;
}

@property(readonly) NSMutableSet *selectedItems;
@property(readonly) NSMutableSet *expandedItems;

@property(weak) IBOutlet id<IconViewDelegate> delegate;
@property(weak) IBOutlet id<NSOutlineViewDataSource> datasource;


@property(weak) id target;
@property SEL doubleAction;

@property NSSize iconSize;
@property NSSize iconSpacing;

@property IconViewCell *cell;

@property BOOL allowEmptySelection;
@property BOOL allowMultipleSelection;

-(void)reloadData;
-(NSArray*)selectedItemArray;

-(void)selectItem:(id)newSelectedItem byExtendingSelection:(BOOL)extend;
-(NSRect)rectOfItem:(id)item;
-(void)beginRenamingItem:(id)item;

@end
