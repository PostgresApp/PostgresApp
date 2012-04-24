// main.m
//
// Created by Mattt Thompson (http://mattt.me/)
// Copyright (c) 2012 Heroku (http://heroku.com/)
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#include <xpc/xpc.h>
#include <Foundation/Foundation.h>

static void postgres_service_peer_event_handler(xpc_connection_t peer, xpc_object_t event) {
	xpc_type_t type = xpc_get_type(event);
	if (type == XPC_TYPE_ERROR) {
		if (event == XPC_ERROR_CONNECTION_INVALID) {
			// The client process on the other end of the connection has either
			// crashed or cancelled the connection. After receiving this error,
			// the connection is in an invalid state, and you do not need to
			// call xpc_connection_cancel(). Just tear down any associated state
			// here.
		} else if (event == XPC_ERROR_TERMINATION_IMMINENT) {
			// Handle per-connection termination cleanup.
		}
	} else {
		assert(type == XPC_TYPE_DICTIONARY);

        NSString *command = [NSString stringWithUTF8String:xpc_dictionary_get_string(event, "command")];

        
        NSMutableArray *mutableArguments = [NSMutableArray array];
        xpc_array_apply(xpc_dictionary_get_value(event, "arguments"), ^_Bool(size_t index, xpc_object_t obj) {
            const char *string = xpc_string_get_string_ptr(obj);
            [mutableArguments addObject:[NSString stringWithUTF8String:string]];
            return true;
        });

        NSTask *task = [[NSTask alloc] init];
        task.launchPath = command;
        task.arguments = mutableArguments;

        __block xpc_object_t reply = xpc_dictionary_create_reply(event);
        task.terminationHandler = ^(NSTask *task) {
            xpc_dictionary_set_string(reply, "command", [[task launchPath] UTF8String]);
            xpc_dictionary_set_int64(reply, "status", [task terminationStatus]);
            xpc_dictionary_set_int64(reply, "pid", [task processIdentifier]);
            xpc_connection_send_message(peer, reply);
        };
        [task launch];
	}
}

static void postgres_service_event_handler(xpc_connection_t peer)  {
	// By defaults, new connections will target the default dispatch
	// concurrent queue.
	xpc_connection_set_event_handler(peer, ^(xpc_object_t event) {
		postgres_service_peer_event_handler(peer, event);
	});
	
	// This will tell the connection to begin listening for events. If you
	// have some other initialization that must be done asynchronously, then
	// you can defer this call until after that initialization is done.
	xpc_connection_resume(peer);
}

int main(int argc, const char *argv[]) {
	xpc_main(postgres_service_event_handler);
	return 0;
}
