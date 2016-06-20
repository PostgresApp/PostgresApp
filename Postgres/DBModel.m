//
//  DBModel.m
//  Postgres
//
//  Created by Chris on 06/06/16.
//
//

#import "DBModel.h"

@implementation DBModel

- (id)initWithName:(NSString *)name {
	self = [super init];
	if (self) {
		self.name = name;
	}
	return self;
}


- (NSImage *)image {
	static NSImage *schemaImage = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		schemaImage = [NSImage imageWithSize:NSMakeSize(64, 63) flipped:NO drawingHandler:^BOOL(NSRect dstRect) {
			
			NSColor *baseColor = [NSColor colorWithCalibratedRed: 0.714 green: 0.823 blue: 0.873 alpha: 1];
			NSColor *frameColor = [baseColor shadowWithLevel: 0.4];
			NSColor *fillColor = [baseColor highlightWithLevel:0.7];
			
			CGFloat lineWidth = 1;
			
			[fillColor setFill];
			[frameColor setStroke];
			for (int i=0; i<4; i++) {
				NSBezierPath* oval2Path = [NSBezierPath bezierPathWithOvalInRect: NSMakeRect(0.5*lineWidth, 0.5*lineWidth+(63-lineWidth-8)/3*i, 64-lineWidth, 8)];
				[oval2Path fill];
				oval2Path.lineWidth = lineWidth;
				[oval2Path stroke];
				if (i<3) {
					NSRectFillUsingOperation(NSMakeRect(0.5*lineWidth, 4+0.5*lineWidth+(63-lineWidth-8)/3*i, 64-lineWidth, 16),NSCompositeCopy);
				}
			}
			
			[frameColor setFill];
			NSRectFillUsingOperation(NSMakeRect(0, 4+0.5*lineWidth, lineWidth, 3*(63-lineWidth-8)/3), NSCompositeCopy);
			NSRectFillUsingOperation(NSMakeRect(64-lineWidth, 4+0.5*lineWidth, lineWidth, 3*(63-lineWidth-8)/3), NSCompositeCopy);
			return YES;
		}];
	});
	return schemaImage;
}


-(id)copyWithZone:(NSZone *)zone {
	return self;
}

@end
