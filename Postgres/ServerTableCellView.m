//
//  ServerTableCellView.m
//  Postgres
//
//  Created by Chris on 17/05/16.
//
//

#import "ServerTableCellView.h"
#import "PostgresServer.h"

@interface ServerTableCellView ()
@property NSImage *statusImage;
@end


@implementation ServerTableCellView

- (void)awakeFromNib {
	[self addObserver:self forKeyPath:@"objectValue.isRunning" options:NSKeyValueObservingOptionNew context:nil];
}


-(void)dealloc {
	[self removeObserver:self forKeyPath:@"objectValue.isRunning"];
}


- (void)drawRect:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
	NSString *imgName = ((PostgresServer*)[self objectValue]).isRunning ? NSImageNameStatusAvailable : NSImageNameStatusUnavailable;
	self.statusImage = [NSImage imageNamed:imgName];
}

@end
