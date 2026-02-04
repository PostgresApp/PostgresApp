//
//  PostgresPermissionDialog-Bridging-Header.h
//  Postgres
//
//  Created by Jakob Egger on 24.05.23.
//  Copyright © 2023 postgresapp. All rights reserved.
//
#import <AppKit/AppKit.h>

#import <libproc.h>

CFURLRef __nullable SecTranslocateCreateOriginalPathForURL(CFURLRef translocatedPath, CFErrorRef* __nullable error)
__OSX_AVAILABLE(10.12);
