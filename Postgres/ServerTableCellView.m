//
//  ServerTableCellView.m
//  Postgres
//
//  Created by Chris on 17/05/16.
//
//

#import "ServerTableCellView.h"
#import "PostgresServer.h"


@implementation ServerTableCellView

- (void)awakeFromNib {
	[self addObserver:self forKeyPath:@"objectValue.isRunning" options:NSKeyValueObservingOptionNew context:(void*)self];
}


-(void)dealloc {
	[self removeObserver:self forKeyPath:@"objectValue.isRunning" context:(void*)self];
}


- (void)drawRect:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
	
	NSColor *bgColor = ((PostgresServer*)[self objectValue]).isRunning ? [NSColor greenColor] : [NSColor redColor];
	[bgColor setFill];
	
	NSRect rect = NSMakeRect(140, 20, 10, 10);
	NSBezierPath *circlePath = [NSBezierPath bezierPath];
	[circlePath appendBezierPathWithOvalInRect:rect];
	[circlePath stroke];
	[circlePath fill];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
	[self setNeedsDisplay:YES];
}

@end
