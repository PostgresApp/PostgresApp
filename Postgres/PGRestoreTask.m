//
//  PGRestoreTask.m
//  Postgres
//
//  Created by Chris on 09/06/16.
//
//

#import "PGRestoreTask.h"
#import "PostgresServer.h"

@interface PGRestoreTask ()
@property NSTask *task;
@end


@implementation PGRestoreTask

- (void)startWithCompletionHandler:(PGRestoreTaskCompletionHandler)completionBlock {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSError *error = nil;
		BOOL success = [self executeWithError:&error];
		if (completionBlock) dispatch_async(dispatch_get_main_queue(), ^{ completionBlock(success, error); });
	});
}


- (BOOL)executeWithError:(NSError **)error {
	self.task = [[NSTask alloc] init];
	self.task.launchPath = [self.server.binPath stringByAppendingPathComponent:@"pg_restore"];
	self.task.arguments = @[
							@"-p", @(self.server.port).stringValue,
							@"-F", @"c",
							@"-d", self.dbName,
							self.filePath,
							];
	
	self.task.standardOutput = [[NSPipe alloc] init];
	self.task.standardError = [[NSPipe alloc] init];
	[self.task launch];
	NSString *description = [[NSString alloc] initWithData:[[self.task.standardError fileHandleForReading] readDataToEndOfFile] encoding:NSUTF8StringEncoding];
	[self.task waitUntilExit];
	
	if (self.task.terminationStatus != 0 && error) {
		NSMutableDictionary *errorUserInfo = [[NSMutableDictionary alloc] init];
		errorUserInfo[NSLocalizedDescriptionKey] = NSLocalizedString(@"Could not restore database", nil);
		if (description) errorUserInfo[@"RawCommandOutput"] = description;
		*error = [NSError errorWithDomain:@"com.postgresapp.Postgres.pg_restore" code:self.task.terminationStatus userInfo:errorUserInfo];
	}
		
	return self.task.terminationStatus == 0;
}


- (void)cancel {
	[self.task terminate];
	self.task = nil;
}

@end
