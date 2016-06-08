//
//  IconView.m
//  Postico
//
//  Created by Jakob Egger on 02.02.15.
//  Copyright (c) 2015 Egger Apps. All rights reserved.
//

#import "IconView.h"
#import "IconViewSection.h"

#define TOP_PADDING 30
#define SECTION_HEADER_HEIGHT 28
#define SECTION_PADDING_TOP 0
#define SECTION_PADDING_AFTER_HEADER 12
#define SECTION_PADDING_BOTTOM 0
#define BOTTOM_PADDING 30

@interface IconView () <NSTextFieldDelegate> {
	NSTimeInterval typeNavigationLastKeypress;
	NSMutableString *typeNavigationPrefix;
	id typeNavigationStartItem;
}
@end

@implementation IconView

-(BOOL)isOpaque {
	return YES;
}

-(BOOL)isFlipped {
	return YES;
}

- (void)drawRect:(NSRect)dirtyRect {
	if (!mainSection) [self reloadData];
	[[NSColor whiteColor] set];
	NSRectFill(dirtyRect);
	[self drawRect:dirtyRect ofSection:mainSection atVerticalOffset:TOP_PADDING];
}

-(void)awakeFromNib {
	self.cell = [[IconViewCell alloc] init];
	self.iconSize = NSMakeSize(126, 115);
	self.iconSpacing = NSMakeSize(5, 0);
	_selectedItems = [[NSMutableSet alloc] init];
	_expandedItems = [[NSMutableSet alloc] init];
}

-(void)viewWillMoveToWindow:(NSWindow *)newWindow {
	NSWindow *oldWindow = self.window;
	if (newWindow != oldWindow) {
		if (oldWindow) {
			[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidBecomeMainNotification object:oldWindow];
			[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResignMainNotification object:oldWindow];
		}
		if (newWindow) {
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noteKeyStatusChanged:) name:NSWindowDidBecomeMainNotification object:newWindow];
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noteKeyStatusChanged:) name:NSWindowDidResignMainNotification object:newWindow];
		}
	}
}

-(BOOL)acceptsFirstResponder {
	return YES;
}

-(BOOL)becomeFirstResponder {
	if ([super becomeFirstResponder]) {
		isFirstResponder = YES;
		if (!_selectedItems.count) {
			for (id element in mainSection.containedItems) {
				id item = element;
				while ([item isKindOfClass:[IconViewSection class]]) item = [item containedItems].firstObject;
				if (item) { [_selectedItems addObject:item]; lastSelectItem = item; break; }
			}
		}
		[self noteKeyStatusChanged:nil];
		return YES;
	} else {
		return NO;
	}
}

-(BOOL)resignFirstResponder {
	if ([super resignFirstResponder]) {
		isFirstResponder = NO;
		[self noteKeyStatusChanged:nil];
		return YES;
	} else {
		return NO;
	}
}

-(void)noteKeyStatusChanged:(NSNotification*)note {
	for (id item in _selectedItems) {
		NSValue *rectObject = [itemRects objectForKey:item];
		if (rectObject) [self setNeedsDisplayInRect:NSInsetRect(rectObject.rectValue,-4,-4)];
	}
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) setFrameSize:(NSSize)newSize {
	[super setFrameSize:newSize];
	NSInteger newNumColumns = (newSize.width - self.iconSpacing.width) / (self.iconSpacing.width + self.iconSize.width);
	if (newNumColumns<1) newNumColumns = 1;
	if (newNumColumns != numColumns) {
		numColumns = newNumColumns;
		[self reflow];
	}
}

-(void)reloadData {
	mainSection = [[IconViewSection alloc] init];
	[self loadItem:nil intoSection:mainSection fromDatasource:self.datasource];
	[self reflow];
}

-(void)loadItem:(id)item intoSection:(IconViewSection*)section fromDatasource:(id<NSOutlineViewDataSource>)source {
	section.item = item;
	if (item==nil || [_expandedItems containsObject:item]) {
		NSInteger numItems = [source outlineView:(id)self numberOfChildrenOfItem:item];
		NSMutableArray *containedItems = [[NSMutableArray alloc] initWithCapacity:numItems];
		NSMutableArray *specialItems = [[NSMutableArray alloc] initWithCapacity:1];
		for (NSInteger i = 0; i<numItems; i++) {
			id subItem = [source outlineView:(id)self child:i ofItem:item];
			if ([source outlineView:(id)self isItemExpandable:subItem]) {
				IconViewSection *subSection = [[IconViewSection alloc] init];
				[self loadItem:subItem intoSection:subSection fromDatasource:source];
				[containedItems addObject:subSection];
			} else if (subItem) {
				if (isFirstResponder && !_selectedItems.count) {[_selectedItems addObject:subItem]; lastSelectItem = subItem; }
				[containedItems addObject:subItem];
			}
		}
		if (specialItems.count) {
			IconViewSection *subSection = [[IconViewSection alloc] init];
			subSection.containedItems = specialItems;
			[containedItems insertObject:subSection atIndex:0];
		}
		section.containedItems = containedItems;
	}
}

-(CGFloat)heightOfSection:(IconViewSection*)section {
	NSValue *val = [sectionRects objectForKey:section];
	if (!val && mainSection) {
		[self layoutSection:mainSection atVerticalOffset:TOP_PADDING];
		val = [sectionRects objectForKey:section];
	}
	return val ? val.rectValue.size.height : 0;
}

-(void)layoutSection:(IconViewSection*)section atVerticalOffset:(CGFloat)y {
	
	NSRect sectionRect = NSMakeRect(0, y, NSWidth(self.bounds), 0);
	
	y += SECTION_PADDING_TOP;
	
	if (section.item) y += SECTION_HEADER_HEIGHT;
	if (section.item && [_expandedItems containsObject:section.item]) y+= SECTION_PADDING_AFTER_HEADER;

	CGFloat x = self.iconSpacing.width;
	if (!section.item || [_expandedItems containsObject:section.item]) {
		int itemsInColumn = 0;
		for (id subItem in section.containedItems) {
			if ([subItem isKindOfClass:[IconViewSection class]]) {
				if (itemsInColumn) {
					itemsInColumn = 0;
					y += self.iconSize.height + self.iconSpacing.height;
				}
				[self layoutSection:subItem atVerticalOffset:y];
				NSRect subItemRect = [[sectionRects objectForKey:subItem] rectValue];
				y += NSHeight(subItemRect);
			}
			else {
				if (itemsInColumn==numColumns) {
					itemsInColumn = 0;
					y += self.iconSize.height + self.iconSpacing.height;
				}
				NSRect iconRect = NSMakeRect(x + itemsInColumn*(self.iconSize.width+self.iconSpacing.width), y + 0.5*self.iconSpacing.height, self.iconSize.width, self.iconSize.height);
				if (!itemRects) itemRects = [[NSMutableDictionary alloc] init];
				[itemRects setObject:[NSValue valueWithRect:iconRect] forKey:subItem];
				itemsInColumn++;
			}
		}
		if (itemsInColumn) {
			y += self.iconSize.height + self.iconSpacing.height;
		}
	}
	
	y += SECTION_PADDING_BOTTOM;
	
	sectionRect.size.height = y - sectionRect.origin.y;
	if (!sectionRects) sectionRects = [[NSMutableDictionary alloc] init];
	[sectionRects setObject:[NSValue valueWithRect:sectionRect] forKey:section];
}

-(NSRect)rectOfItem:(id)item {
	NSValue *rectObject;
	rectObject= itemRects[item];
	if (!rectObject) [self layoutSection:mainSection atVerticalOffset:TOP_PADDING];
	rectObject = itemRects[item];
	if (!item) return NSZeroRect;
	return rectObject.rectValue;
}

-(void)drawRect:(NSRect)dirtyRect ofSection:(IconViewSection*)section atVerticalOffset:(CGFloat)y {
	CGFloat height = [self heightOfSection:section];
	NSRect sectionRect = NSMakeRect(0, y, NSWidth(self.bounds), height);
	if (!NSIntersectsRect(dirtyRect, sectionRect)) return;
	
	y += SECTION_PADDING_TOP;
	
	if (section.item) {
		
		if (section.highlightedSectionHeader) {
			[[NSColor colorWithCalibratedWhite:0.9 alpha:1.0] setFill];
			[[NSBezierPath bezierPathWithRoundedRect:NSMakeRect(NSMinX(self.bounds)+2, y, NSWidth(self.bounds)-4, SECTION_HEADER_HEIGHT) xRadius:3 yRadius:3] fill];
		}

		NSBezierPath *triangle = [NSBezierPath bezierPath];
		if ([_expandedItems containsObject:section.item]) {
			[triangle moveToPoint:NSMakePoint(3, 5)];
			[triangle lineToPoint:NSMakePoint(13, 5)];
			[triangle lineToPoint:NSMakePoint(8, 12)];
		} else {
			[triangle moveToPoint:NSMakePoint(5, 3)];
			[triangle lineToPoint:NSMakePoint(5, 13)];
			[triangle lineToPoint:NSMakePoint(12, 8)];
		}
		[[NSColor colorWithCalibratedWhite:0.5 alpha:1.0] setFill];
		NSAffineTransform *tf = [NSAffineTransform transform];
		[tf translateXBy:10 yBy:y+round(0.5*SECTION_HEADER_HEIGHT-8)];
		[[tf transformBezierPath:triangle] fill];
		
		
		NSRect iconRect = NSMakeRect(28, y+round(0.5*SECTION_HEADER_HEIGHT-8), 16, 16);
		NSImage *image = [section.item respondsToSelector:@selector(image)] ? [section.item image] : nil;
		[image drawInRect:iconRect fromRect:NSMakeRect(0, 0, image.size.width, image.size.height) operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
		
		NSString *name = [section.item respondsToSelector:@selector(name)] ? [section.item name] : nil;

		NSMutableParagraphStyle *parStyle = [[NSMutableParagraphStyle alloc] init];
		NSDictionary *attributes = @{
									 NSFontAttributeName: [NSFont systemFontOfSize:[NSFont systemFontSize]],
									 NSParagraphStyleAttributeName: parStyle
									 };
		NSSize textSize = [name sizeWithAttributes:attributes];
		NSRect textRect = NSMakeRect(28+16+5, y+0.5*(SECTION_HEADER_HEIGHT-textSize.height)-2, self.bounds.size.width, 20);
		
		[name drawInRect:textRect withAttributes:attributes];
		
		y += SECTION_HEADER_HEIGHT;
		if ([_expandedItems containsObject:section.item]) y+= SECTION_PADDING_AFTER_HEADER;
		
		
		
	}
	
	CGFloat x = self.iconSpacing.width;
	if (!section.item || [_expandedItems containsObject:section.item]) {
		int itemsInColumn = 0;
		for (id subItem in section.containedItems) {
			if ([subItem isKindOfClass:[IconViewSection class]]) {
				if (itemsInColumn) {
					itemsInColumn = 0;
					y += self.iconSize.height + self.iconSpacing.height;
				}
				[self drawRect:dirtyRect ofSection:subItem atVerticalOffset:y];
				y += [self heightOfSection:subItem];
			}
			else {
				if (itemsInColumn==numColumns) {
					itemsInColumn = 0;
					y += self.iconSize.height + self.iconSpacing.height;
				}
				NSRect iconRect = NSMakeRect(x + itemsInColumn*(self.iconSize.width+self.iconSpacing.width), y + 0.5*self.iconSpacing.height, self.iconSize.width, self.iconSize.height);
				if (NSIntersectsRect(dirtyRect, iconRect)) {
					IconViewCell *cell = self.cell;
					cell.item = subItem;
					cell.selected = [_selectedItems containsObject:subItem];
					cell.isInForeground = isFirstResponder && self.window.mainWindow;
					cell.highlightedRanges = nil;
					[cell drawWithFrame:iconRect inView:self];
				}
				itemsInColumn++;
			}
		}
		if (itemsInColumn==numColumns) {
			y += self.iconSize.height + self.iconSpacing.height;
		}
	}
}

-(NSSize)intrinsicContentSize {
	if (!numColumns) numColumns = 4;
	return NSMakeSize(numColumns * (self.iconSize.width + self.iconSpacing.width) + self.iconSpacing.width, TOP_PADDING + [self heightOfSection:mainSection] + BOTTOM_PADDING );
}

/* mouse handling */
-(id)itemAtPoint:(NSPoint)point returnRect:(NSRect*)outRect {
	id clickedItem = nil;
	NSRect clickedItemRect = NSZeroRect;
	for (id item in itemRects.keyEnumerator) {
		NSRect itemRect = [[itemRects objectForKey:item] rectValue];
		if([self mouse:point inRect: itemRect]) {
			clickedItem = item;
			clickedItemRect = itemRect;
			break;
		}
	}
	if (clickedItem) {
		self.cell.item = clickedItem;
		NSRect iconRect = NSZeroRect, textRect = NSZeroRect;
		[self.cell getIconRect:&iconRect textRect:&textRect forFrame:clickedItemRect];
		if ([self mouse:point inRect: iconRect] || [self mouse:point inRect: textRect]) {
			if (outRect) *outRect = clickedItemRect;
			return clickedItem;
		}
	}
	return nil;
}

-(IconViewSection*)sectionWithHeaderAtPoint:(NSPoint)point headerRect:(NSRect*)headerRect {
	for (IconViewSection *section in sectionRects) {
		if (!section.item) continue;
		NSRect sectionRect = [sectionRects[section] rectValue];
		NSRect sectionHeaderRect = sectionRect;
		sectionHeaderRect.origin.y += SECTION_PADDING_TOP;
		sectionHeaderRect.size.height = SECTION_HEADER_HEIGHT;
		if ([self mouse:point inRect:sectionHeaderRect]) {
			if (headerRect) *headerRect = sectionHeaderRect;
			return section;
		}
	}
	return nil;
}

-(void)reflow {
	itemRects = nil;
	sectionRects = nil;
	[self invalidateIntrinsicContentSize];
	[self setNeedsDisplay:YES];
	[self layoutRenameField];
}

-(void)mouseDown:(NSEvent *)theEvent {
	NSPoint locationInView = [self convertPoint:theEvent.locationInWindow fromView:nil];
	
	NSRect sectionHeaderRect;
	IconViewSection *section = [self sectionWithHeaderAtPoint:locationInView headerRect:&sectionHeaderRect];
	if (section) {
		section.highlightedSectionHeader = YES;
		[self setNeedsDisplayInRect:sectionHeaderRect];

		BOOL mouseDown = YES;
		BOOL isInside = YES;
		NSPoint mouseLoc;
		
		while (mouseDown) {
			NSEvent *nextEvent = [self.window nextEventMatchingMask: NSLeftMouseDraggedMask | NSLeftMouseUpMask];
			mouseLoc = [self convertPoint:nextEvent.locationInWindow fromView:nil];
			isInside = [self mouse:mouseLoc inRect:sectionHeaderRect];
			
			switch ([nextEvent type]) {
				case NSLeftMouseDragged:
					if (section.highlightedSectionHeader != isInside) {
						section.highlightedSectionHeader = isInside;
						[self setNeedsDisplayInRect:sectionHeaderRect];
					}
					break;
				case NSLeftMouseUp:
					if (isInside) {
						if ([_expandedItems containsObject:section.item]) [_expandedItems removeObject:section.item];
						else {
							[_expandedItems addObject:section.item];
							[self loadItem:section.item intoSection:section fromDatasource:self.datasource];
						}
						[self reflow];
					}
					if (section.highlightedSectionHeader) {
						section.highlightedSectionHeader = NO;
						[self setNeedsDisplayInRect:sectionHeaderRect];
					}
					mouseDown = NO;
					break;
				default:
					/* Ignore any other kind of event. */
					break;
			}
			
		}
		return;
	}
	
	NSRect clickedItemRect = NSZeroRect;
	id clickedItem = [self itemAtPoint:locationInView returnRect:&clickedItemRect];
	BOOL multiSelectMode = NO;
	if (theEvent.modifierFlags & NSShiftKeyMask) multiSelectMode = YES;
	if (theEvent.modifierFlags & NSCommandKeyMask && self.window.isKeyWindow) multiSelectMode = YES;
	if (multiSelectMode) {
		if (clickedItem) {
			if (![_selectedItems containsObject:clickedItem]) {
				[self selectItem:clickedItem byExtendingSelection:YES];
			} else {
				[self deselectItem:clickedItem];
			}
		}
	}
	else {
		[self selectItem:clickedItem byExtendingSelection:NO];
	}
}

-(void)selectItem:(id)newSelectedItem byExtendingSelection:(BOOL)extend {
	if (!extend) {
		for (id item in _selectedItems) {
			NSValue *rectObject = [itemRects objectForKey:item];
			if (rectObject) [self setNeedsDisplayInRect:NSInsetRect(rectObject.rectValue,-4,-4)];
		}
		[_selectedItems removeAllObjects];
	}
	if (newSelectedItem && ![_selectedItems containsObject:newSelectedItem]) {
		[_selectedItems addObject:newSelectedItem];
		NSValue *rectObject = [itemRects objectForKey:newSelectedItem];
		if (rectObject) [self setNeedsDisplayInRect:NSInsetRect(rectObject.rectValue,-4,-4)];
	}
	lastSelectItem = newSelectedItem;
}

-(void)deselectItem:(id)item {
	if ([_selectedItems containsObject:item]) {
		[_selectedItems removeObject:item];
		NSValue *rectObject = [itemRects objectForKey:item];
		if (rectObject) [self setNeedsDisplayInRect:NSInsetRect(rectObject.rectValue,-4,-4)];
	}
	lastSelectItem = item;
}

-(void)mouseUp:(NSEvent *)theEvent {
	if (theEvent.clickCount == 2) {
		id clickedItem = [self itemAtPoint:[self convertPoint:theEvent.locationInWindow fromView:nil] returnRect:NULL];
		if  (clickedItem && [_selectedItems containsObject:clickedItem]) {
			if (self.doubleAction) [NSApp sendAction:self.doubleAction to:self.target from:self];
		}
	}
}

-(void)keyDown:(NSEvent *)theEvent {
	if (theEvent.keyCode == 123) { //left
		if (lastSelectItem) {
			NSValue *rectValue = itemRects[lastSelectItem];
			if (rectValue) {
				NSRect lastSelectedRect = rectValue.rectValue;
				id nextSelectedItem = nil;
				NSRect nextSelectedRect;
				for (id otherItem in itemRects) {
					NSRect otherItemRect = [itemRects[otherItem] rectValue];
					if (NSMinX(otherItemRect)<NSMinX(lastSelectedRect) && NSMinY(lastSelectedRect) < NSMaxY(otherItemRect) && NSMinY(otherItemRect) < NSMaxY(lastSelectedRect)) {
						if (!nextSelectedItem || NSMaxX(otherItemRect) > NSMaxX(nextSelectedRect)) { nextSelectedRect = otherItemRect; nextSelectedItem = otherItem; }
					}
				}
				if (nextSelectedItem) {
					[self selectItem:nextSelectedItem byExtendingSelection:theEvent.modifierFlags & NSShiftKeyMask ? YES : NO];
					[self scrollRectToVisible:nextSelectedRect];
				}
			}
		}
	}
	else if (theEvent.keyCode == 124) { //right
		if (lastSelectItem) {
			NSValue *rectValue = itemRects[lastSelectItem];
			if (rectValue) {
				NSRect lastSelectedRect = rectValue.rectValue;
				id nextSelectedItem = nil;
				NSRect nextSelectedRect;
				for (id otherItem in itemRects) {
					NSRect otherItemRect = [itemRects[otherItem] rectValue];
					if (NSMaxX(otherItemRect)>NSMaxX(lastSelectedRect) && NSMinY(lastSelectedRect) < NSMaxY(otherItemRect) && NSMinY(otherItemRect) < NSMaxY(lastSelectedRect)) {
						if (!nextSelectedItem || NSMinX(otherItemRect) < NSMinX(nextSelectedRect)) { nextSelectedRect = otherItemRect; nextSelectedItem = otherItem; }
					}
				}
				if (nextSelectedItem) {
					[self selectItem:nextSelectedItem byExtendingSelection:theEvent.modifierFlags & NSShiftKeyMask ? YES : NO];
					[self scrollRectToVisible:nextSelectedRect];
				}
			}
		}
	}
	else if (theEvent.keyCode == 125) { //down
		if (lastSelectItem) {
			NSValue *rectValue = itemRects[lastSelectItem];
			if (rectValue) {
				NSRect lastSelectedRect = rectValue.rectValue;
				id nextSelectedItem = nil;
				NSRect nextSelectedRect;
				for (id otherItem in itemRects) {
					NSRect otherItemRect = [itemRects[otherItem] rectValue];
					if (NSMaxY(otherItemRect)>NSMaxY(lastSelectedRect) && NSMinX(lastSelectedRect) < NSMaxX(otherItemRect) && NSMinX(otherItemRect) < NSMaxX(lastSelectedRect)) {
						if (!nextSelectedItem || NSMinY(otherItemRect) < NSMinY(nextSelectedRect)) { nextSelectedRect = otherItemRect; nextSelectedItem = otherItem; }
					}
				}
				if (nextSelectedItem) {
					[self selectItem:nextSelectedItem byExtendingSelection:theEvent.modifierFlags & NSShiftKeyMask ? YES : NO];
					[self scrollRectToVisible:nextSelectedRect];
				}
			}
		}
	}
	else if (theEvent.keyCode == 126) { //up
		if (lastSelectItem) {
			NSValue *rectValue = itemRects[lastSelectItem];
			if (rectValue) {
				NSRect lastSelectedRect = rectValue.rectValue;
				id nextSelectedItem = nil;
				NSRect nextSelectedRect;
				for (id otherItem in itemRects) {
					NSRect otherItemRect = [itemRects[otherItem] rectValue];
					if (NSMinY(otherItemRect)<NSMinY(lastSelectedRect) && NSMinX(lastSelectedRect) < NSMaxX(otherItemRect) && NSMinX(otherItemRect) < NSMaxX(lastSelectedRect)) {
						if (!nextSelectedItem || NSMaxY(otherItemRect) > NSMaxY(nextSelectedRect)) { nextSelectedRect = otherItemRect; nextSelectedItem = otherItem; }
					}
				}
				if (nextSelectedItem) {
					[self selectItem:nextSelectedItem byExtendingSelection:theEvent.modifierFlags & NSShiftKeyMask ? YES : NO];
					[self scrollRectToVisible:nextSelectedRect];
				}
			}
		}
	}
	else if (theEvent.type == NSKeyDown && !(theEvent.modifierFlags & (NSControlKeyMask|NSCommandKeyMask)) && theEvent.characters.length && [theEvent.characters characterAtIndex:0]>=' ') {
		[self processTypeNavigationEvent:theEvent];
	}
	else {
		[self.nextResponder keyDown:theEvent];
	}
}

-(void)processTypeNavigationEvent:(NSEvent*)evt {
	if (evt.timestamp-typeNavigationLastKeypress > 1.0) {
		typeNavigationPrefix = [[NSMutableString alloc] init];
		typeNavigationStartItem = lastSelectItem;
	}
	typeNavigationLastKeypress = evt.timestamp;
	[typeNavigationPrefix appendString:evt.characters];
	id newSelectedItem = nil;
	NSRect newSelectedItemRect;
	NSRect typeNavigationStartItemRect;
	if (typeNavigationStartItem) typeNavigationStartItemRect = itemRects[typeNavigationStartItem].rectValue;
	for (id item in itemRects) {
		if (item==typeNavigationStartItem) continue;
		if (![item respondsToSelector:@selector(name)] || [[item name] rangeOfString:typeNavigationPrefix options:NSAnchoredSearch|NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch].length == 0) continue;
		NSRect itemRect = itemRects[item].rectValue;
		if (newSelectedItem) {
			BOOL newIsPreferred = typeNavigationStartItem ? [self compareRect:typeNavigationStartItemRect withRect:newSelectedItemRect]==NSOrderedAscending : NO;
			BOOL itemIsPreferred = typeNavigationStartItem ? [self compareRect:typeNavigationStartItemRect withRect:itemRect]==NSOrderedAscending : NO;
			if (newIsPreferred && !itemIsPreferred) {
				continue;
			} else if ((newIsPreferred && itemIsPreferred) || (!newIsPreferred && !itemIsPreferred)) {
				if ([self compareRect:newSelectedItemRect withRect:itemRect]==NSOrderedAscending) {
					continue;
				}
			} else {
				// go!
			}
		}
		newSelectedItem = item;
		newSelectedItemRect = itemRect;
	}
	if (newSelectedItem) {
		[self selectItem:newSelectedItem byExtendingSelection:NO];
		[self scrollRectToVisible:newSelectedItemRect];
	} else {
		NSBeep();
	}
}

-(NSComparisonResult)compareRect:(NSRect)rectA withRect:(NSRect)rectB {
	// first compare vertically
	if (NSMaxY(rectA)<NSMinY(rectB)) return NSOrderedAscending;
	if (NSMaxY(rectB)<NSMinY(rectA)) return NSOrderedDescending;
	//then compare horizontally
	if (NSMinX(rectA)<NSMinX(rectB)) return NSOrderedAscending;
	if (NSMinX(rectA)>NSMinX(rectB)) return NSOrderedDescending;
	if (NSMaxX(rectA)<NSMaxX(rectB)) return NSOrderedAscending;
	if (NSMaxX(rectA)>NSMaxX(rectB)) return NSOrderedAscending;
	return NSOrderedSame;
}

-(NSArray*)selectedItemArray {
	NSMutableSet *existingSelectedItems = [[NSMutableSet alloc] initWithArray:itemRects.allKeys];
	[existingSelectedItems intersectSet:_selectedItems];
	return existingSelectedItems.allObjects;
}

#pragma mark -
#pragma mark Context menu

-(NSMenu *)menuForEvent:(NSEvent *)event {
	if (![self.window makeFirstResponder:self]) return nil;
	
	NSPoint locationInView = [self convertPoint:event.locationInWindow fromView:nil];
	id item = [self itemAtPoint:locationInView returnRect:NULL];
	if (![_selectedItems containsObject:item]) [self selectItem:item byExtendingSelection:NO];
	
	return self.menu;
}

#pragma mark - Renaming

-(void)beginRenamingItem:(id)item {
	if (![item respondsToSelector:@selector(name)]) {
		NSBeep();
		return;
	}
	if (![self.window makeFirstResponder:nil]) {
		NSBeep();
		return;
	}
	currentlyRenamingItem = item;
	NSRect textRect;
	IconViewCell *cell = self.cell;
	cell.item = item;
	NSRect itemRect = [self rectOfItem:item];
	[cell getIconRect:NULL textRect:&textRect forFrame:itemRect];
	renameField = [[NSTextField alloc] initWithFrame:textRect];
	renameField.cell.alignment = NSCenterTextAlignment;
	renameField.cell.bordered = NO;
	renameField.stringValue = [item name];
	renameField.delegate = self;
	renameField.frame = textRect;
	[self addSubview:renameField];
	[self.window makeFirstResponder:renameField];
	[self layoutSubtreeIfNeeded];
	[self scrollRectToVisible:itemRect];
}

-(void)layoutRenameField {
	if (currentlyRenamingItem) {
		IconViewCell *cell = self.cell;
		cell.item = currentlyRenamingItem;
		NSRect textRect;
		NSRect itemRect = [self rectOfItem:currentlyRenamingItem];
		[cell getIconRect:NULL textRect:&textRect forFrame:itemRect];
		renameField.frame = textRect;
		[self layoutSubtreeIfNeeded];
		[self scrollRectToVisible:itemRect];
	}
}

-(void)controlTextDidEndEditing:(NSNotification *)note {
	if (note.object == renameField) {
		if ([self.datasource respondsToSelector:@selector(outlineView:setObjectValue:forTableColumn:byItem:)]) {
			[self.datasource outlineView:(NSOutlineView*)self setObjectValue:renameField.stringValue forTableColumn:[[NSTableColumn alloc] initWithIdentifier:@"name"] byItem:currentlyRenamingItem];
		}
		currentlyRenamingItem = nil;
		[renameField removeFromSuperview];
		renameField = nil;
		[self.window makeFirstResponder:self];
	}
}

-(BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
	if (commandSelector==@selector(complete:)) {
		[control abortEditing];
		if (control==renameField) {
			if ([self.delegate respondsToSelector:@selector(iconView:didAbortRenameForItem:)]) {
				[self.delegate iconView:self didAbortRenameForItem:currentlyRenamingItem];
			}
			currentlyRenamingItem = nil;
			[renameField removeFromSuperview];
			renameField = nil;
			[self.window makeFirstResponder:self];
		}
		return YES;
	}
	return NO;
}

@end
