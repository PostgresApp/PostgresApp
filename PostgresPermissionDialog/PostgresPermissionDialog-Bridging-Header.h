//
//  PostgresPermissionDialog-Bridging-Header.h
//  Postgres
//
//  Created by Jakob Egger on 24.05.23.
//  This code is released under the terms of the PostgreSQL License.
//
#import <AppKit/AppKit.h>

#import <libproc.h>

CFURLRef __nullable SecTranslocateCreateOriginalPathForURL(CFURLRef translocatedPath, CFErrorRef* __nullable error)
__OSX_AVAILABLE(10.12);
