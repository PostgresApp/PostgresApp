//
//  DBModel.m
//  Postgres
//
//  Created by Chris on 06/06/16.
//
//

#import "DBModel.h"

@implementation DBModel

- (NSImage *)image {
	static NSImage *schemaImage = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		schemaImage = [NSImage imageWithSize:NSMakeSize(64, 63) flipped:NO drawingHandler:^BOOL(NSRect dstRect) {
			
			NSColor *baseColor = [NSColor colorWithCalibratedRed: 0.714 green: 0.823 blue: 0.873 alpha: 1];
			NSColor *frameColor = [baseColor shadowWithLevel: 0.4];
			NSColor *fillColor = [baseColor highlightWithLevel:0.7];
			
			[fillColor setFill];
			[frameColor setStroke];
			for (int i=0; i<4; i++) {
				NSBezierPath* oval2Path = [NSBezierPath bezierPathWithOvalInRect: NSMakeRect(0.5, 0.5+18*i, 63, 8)];
				[oval2Path fill];
				[oval2Path stroke];
				if (i<3) {
					NSRectFillUsingOperation(NSMakeRect(1, 4.5+18*i, 62, 16),NSCompositeCopy);
				}
			}
			
			[frameColor setFill];
			NSRectFillUsingOperation(NSMakeRect(0, 4.5, 1, 3*18), NSCompositeCopy);
			NSRectFillUsingOperation(NSMakeRect(63, 4.5, 1, 3*18), NSCompositeCopy);
			return YES;
		}];
	});
	return schemaImage;
}


-(id)copyWithZone:(NSZone *)zone {
	return self;
}

@end
