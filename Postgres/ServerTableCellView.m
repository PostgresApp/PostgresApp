//
//  ServerTableCellView.m
//  Postgres
//
//  Created by Chris on 17/05/16.
//
//

#import "ServerTableCellView.h"
#import "PostgresServer.h"


#define RED [NSColor colorWithRed:252/255.0f green:96/255.0f blue:92/255.0f alpha:1.0f]
#define GREEN [NSColor colorWithRed:53/255.0f green:202/255.0f blue:74/255.0f alpha:1.0f]


@implementation ServerTableCellView

- (void)awakeFromNib {
	[self addObserver:self forKeyPath:@"objectValue.isRunning" options:NSKeyValueObservingOptionNew context:nil];
}


-(void)dealloc {
	[self removeObserver:self forKeyPath:@"objectValue.isRunning"];
}


- (void)drawRect:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
	
	NSColor *color = ((PostgresServer*)[self objectValue]).isRunning ? GREEN : RED;
	[color setFill];
	
	NSRect rect = NSMakeRect(10, 20, 10, 10);
	NSBezierPath *circlePath = [NSBezierPath bezierPath];
	[circlePath appendBezierPathWithOvalInRect:rect];
	[circlePath stroke];
	[circlePath fill];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
	[self setNeedsDisplay:YES];
}

@end
