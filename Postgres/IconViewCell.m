//
//  IconViewCell.m
//  Postico
//
//  Created by Jakob Egger on 03.02.15.
//  Copyright (c) 2015 Egger Apps. All rights reserved.
//

#import "IconViewCell.h"

#import "PGETable.h"

@implementation IconViewCell

-(NSImage*)image {
	id item = self.item;
	NSImage *image = [item respondsToSelector:@selector(bigImage)] ? [item bigImage] : [item respondsToSelector:@selector(image)] ? [item image] : nil;
	return image;
}

-(NSString*)name {
	id item = self.item;
	NSString *name = [item respondsToSelector:@selector(name)] ? [item name] : nil;
	return name;
}


-(void)getIconRect:(NSRect*)iconRect textRect:(NSRect*)textRect forFrame:(NSRect)frame {
	[self drawWithFrame:frame inView:nil getIconRect:iconRect textRect:textRect];
}

-(void)drawWithFrame:(NSRect)frame inView:(NSView *)controlView {
	[self drawWithFrame:frame inView:controlView getIconRect:NULL textRect:NULL];
}

-(void)drawWithFrame:(NSRect)frame inView:(NSView *)controlView getIconRect:(NSRect*)iconRectOut textRect:(NSRect*)textRectOut {
	NSImage *image = [self image];
	NSString *name = [self name];
	name = [name stringByReplacingOccurrencesOfString:@"_" withString:@"_​"]; // add zero width space after underscore to mark it as a line break point
	
	NSFont *font = [NSFont systemFontOfSize:[NSFont systemFontSize]];
	if ([self.item respondsToSelector:@selector(isNew)] && [self.item isNew]) {
		NSFontManager *fontManager = [NSFontManager sharedFontManager];
		NSFont *italicSystemFont = [fontManager fontWithFamily: font.familyName traits: NSItalicFontMask weight:5 size:[NSFont systemFontSize]];
		if (italicSystemFont) font = italicSystemFont;
	}
	
	NSMutableParagraphStyle *parStyle = [[NSMutableParagraphStyle alloc] init];
	parStyle.alignment = NSCenterTextAlignment;
	
	NSColor *textColor;
	if (self.selected) {
		if (_isInForeground) {
			textColor = [NSColor alternateSelectedControlTextColor];
		} else {
			textColor = [NSColor colorWithCalibratedWhite:0.3 alpha:1.0];
		}
	} else {
		textColor = [NSColor blackColor];
	}
	NSDictionary *attributes = @{
								 NSFontAttributeName: font,
								 NSParagraphStyleAttributeName: parStyle,
								 NSForegroundColorAttributeName: textColor
								 };
	NSRect testBounds = [@"X\nX\nX" boundingRectWithSize:frame.size options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine attributes:attributes];
	
	
	NSRect maxImageRect = frame;
	maxImageRect.size.height -= NSHeight(testBounds) + 8;
	CGFloat scaleFactor = MIN(1,MIN(NSWidth(maxImageRect)/image.size.width, NSHeight(maxImageRect)/image.size.height));
	CGFloat left = round(NSMidX(maxImageRect)-0.5*image.size.width*scaleFactor);
	CGFloat top = round(NSMaxY(maxImageRect)-image.size.height*scaleFactor);
	NSRect imageTargetRect = NSMakeRect(left, top, round(image.size.width*scaleFactor), round(image.size.height*scaleFactor));
	
	NSRect textRect = NSMakeRect(NSMinX(frame), NSMaxY(frame)-NSHeight(testBounds), NSWidth(frame), NSHeight(testBounds));
	if (iconRectOut) *iconRectOut = NSMakeRect(NSMinX(imageTargetRect),NSMinY(imageTargetRect), NSWidth(imageTargetRect), NSMinY(textRect)-NSMinY(imageTargetRect));
	
	if (self.selected || textRectOut) {
		NSRect boundingRect = [name boundingRectWithSize:NSMakeSize(NSWidth(textRect), NSHeight(textRect)) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine attributes:attributes];
		CGFloat width = round(NSWidth(boundingRect)/2)*2 + 6;
		NSRect highlightRect = NSMakeRect(NSMidX(textRect)-0.5*width, NSMinY(textRect), width, NSHeight(boundingRect)+1);
		if (textRectOut) *textRectOut = highlightRect;
		if (controlView && self.selected) {
			NSBezierPath *textBackgroundPath = [NSBezierPath bezierPathWithRoundedRect:highlightRect xRadius:3 yRadius:3];
			[_isInForeground ? [NSColor alternateSelectedControlColor] : [NSColor colorWithCalibratedWhite:0.9 alpha:1.0] setFill];
			[textBackgroundPath fill];
			NSRect imageHighlightRect = NSInsetRect(imageTargetRect, -4, -4);
			NSBezierPath *imageHighlightPath = [NSBezierPath bezierPathWithRoundedRect:imageHighlightRect xRadius:3 yRadius:3];
			[[NSColor colorWithCalibratedWhite:0.9 alpha:1.0] setFill];
			[imageHighlightPath fill];
		}
	}
	
	if (controlView) {
		if (_highlightedRanges.count) {
			NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[self name] attributes:attributes];
			for (NSValue *rangeObject in _highlightedRanges) {
				NSRange highlightedRange = rangeObject.rangeValue;
				[attrString addAttribute:NSBackgroundColorAttributeName value:[NSColor colorWithCalibratedRed:1 green:1 blue:0 alpha:0.5] range:highlightedRange];
			}
			[attrString.mutableString replaceOccurrencesOfString:@"_" withString:@"_​" options:0 range:NSMakeRange(0, attrString.mutableString.length)];
			[attrString drawWithRect:textRect options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine];
		} else {
			[name drawWithRect:textRect options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine attributes:attributes];
		}

		NSRect imageSourceRect = NSMakeRect(0, 0, image.size.width, image.size.height);
		[image drawInRect:imageTargetRect fromRect:imageSourceRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
	}
}


@end
