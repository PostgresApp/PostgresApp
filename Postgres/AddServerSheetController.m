//
//  AddServerSheetController.m
//  Postgres
//
//  Created by Chris on 24/05/16.
//
//

#import "AddServerSheetController.h"
#import "NSFileManager+DirectoryLocations.h"

@interface AddServerSheetController ()
@property PostgresServer *server;
@end

@implementation AddServerSheetController

- (id)initWithWindowNibName:(NSString *)windowNibName {
	self = [super initWithWindowNibName:windowNibName];
	if (self) {
		[self loadVersions];
		self.varPath = [[[NSFileManager defaultManager] applicationSupportDirectory] stringByAppendingFormat:@"/var-%@", self.version];
		self.port = kPostgresAppDefaultPort;
		[self addObserver:self forKeyPath:@"selectedVersionIndex" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
		[self addObserver:self forKeyPath:@"varPath" options:NSKeyValueObservingOptionNew context:nil];
	}
	return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
}

- (void)dealloc {
	[self removeObserver:self forKeyPath:@"selectedVersionIndex"];
	[self removeObserver:self forKeyPath:@"varPath"];
}



#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
	if ([keyPath isEqualToString:@"selectedVersionIndex"]) {
		
		///
		// replace old version with the new one if path contains old version
		///
		NSNumber *old = change[NSKeyValueChangeOldKey];
		NSNumber *new = change[NSKeyValueChangeNewKey];
		if ([old isKindOfClass:[NSNumber class]] && [new isKindOfClass:[NSNumber class]]) {
			NSUInteger oldIndex = old.unsignedIntegerValue;
			NSUInteger newIndex = new.unsignedIntegerValue;
			NSString *oldVersion = [self.versions objectAtIndex:oldIndex];
			NSString *newVersion = [self.versions objectAtIndex:newIndex];
			if ([self.varPath localizedCaseInsensitiveContainsString:oldVersion]) {
				self.varPath = [self.varPath stringByReplacingOccurrencesOfString:oldVersion withString:newVersion];
			}
		}
	}
	else if ([keyPath isEqualToString:@"varPath"]) {
		
		///
		// select version in popup if popup contains string in PG_VERSION
		///
		NSString *pgVerPath = [self.varPath stringByAppendingPathComponent:@"/PG_VERSION"];
		if ([[NSFileManager defaultManager] fileExistsAtPath:pgVerPath]) {
			NSString *contents = [NSString stringWithContentsOfFile:pgVerPath encoding:NSUTF8StringEncoding error:nil];
			NSArray *lines = [contents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
			if (lines.count > 0) {
				[self.versionsPopup selectItemWithTitle:[lines objectAtIndex:0]];
				//[self.versionsPopup setEnabled:NO];
			}
		}
		else {
			[self.versionsPopup setEnabled:YES];
		}
	}
}



#pragma mark - IBActions
- (IBAction)openChooseFolder:(id)sender {
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	openPanel.allowsMultipleSelection = NO;
	openPanel.canChooseFiles = NO;
	openPanel.canChooseDirectories = YES;
	openPanel.canCreateDirectories = YES;
	openPanel.directoryURL = [NSURL fileURLWithPath:[[NSFileManager defaultManager] applicationSupportDirectory]];
	[openPanel beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
		if (returnCode == NSModalResponseOK) {
			NSString *varTmp = openPanel.URL.path;
			
			///
			// append string in PG_VERSION to path
			///
			NSString *pgVerPath = [varTmp stringByAppendingPathComponent:@"/PG_VERSION"];
			if (! [[NSFileManager defaultManager] fileExistsAtPath:pgVerPath]) {
				self.varPath = [varTmp stringByAppendingFormat:@"/var-%@", self.version];
			} else {
				self.varPath = varTmp;
			}

		}
	}];
}


- (IBAction)ok:(id)sender {
	if (![self.window makeFirstResponder:nil]) {
		NSBeep();
		return;
	}
	
	self.server = [[PostgresServer alloc] initWithName:self.name
											   version:self.version
												  port:self.port
											   varPath:self.varPath];
	[self.window.sheetParent endSheet:self.window returnCode:NSModalResponseOK];
}


- (IBAction)cancel:(id)sender {
	[self.window.sheetParent endSheet:self.window returnCode:NSModalResponseCancel];
}




- (void)loadVersions {
	NSString *versionsPath = [BUNDLE_PATH stringByAppendingPathComponent:@"/Contents/Versions"];
	
	if (! [[NSFileManager defaultManager] fileExistsAtPath:versionsPath]) {
		NSLog(@"The folder %@ doesn't exist", versionsPath);
		return;
	}
	
	NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtURL:[NSURL URLWithString:versionsPath]
														  includingPropertiesForKeys:@[NSURLIsSymbolicLinkKey, NSURLIsDirectoryKey]
																			 options:NSDirectoryEnumerationSkipsHiddenFiles | NSDirectoryEnumerationSkipsSubdirectoryDescendants
																		errorHandler:nil
									  ];
	NSMutableArray *result = [[NSMutableArray alloc] init];
	for (NSURL *currURL in dirEnum) {
		NSNumber *isDir;
		NSNumber *isAlias;
		[currURL getResourceValue:&isDir forKey:NSURLIsDirectoryKey error:nil];
		[currURL getResourceValue:&isAlias forKey:NSURLIsSymbolicLinkKey error:nil];
		if ([isDir boolValue] && ![isAlias boolValue]) {
			[result addObject:[currURL lastPathComponent]];
		}
	}
	
	self.versions = result;
}



#pragma mark - Custom properties

- (NSString *)version {
	return [self.versions objectAtIndex:self.selectedVersionIndex];
}

@end
