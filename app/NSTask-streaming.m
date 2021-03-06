/*
 * Copyright (c) 2008-2012 Martin Hedenfalk <martin@vicoapp.com>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "NSTask-streaming.h"
#include "logging.h"

@implementation NSTask (streaming)

- (ViBufferedStream *)scheduledStreamWithStandardInput:(NSData *)stdinData captureStandardError:(BOOL)captureStderr
{
	if (stdinData)
		[self setStandardInput:[NSPipe pipe]];
	else
		[self setStandardInput:[NSFileHandle fileHandleWithNullDevice]];

	NSPipe *stdout = [NSPipe pipe];
	[self setStandardOutput:stdout];
	if (captureStderr)
		[self setStandardError:stdout];

        DEBUG(@"launching %@ with arguments %@", [self launchPath], [self arguments]);
        [self launch];
        DEBUG(@"launched task with pid %li", [self processIdentifier]);

	ViBufferedStream *stream = [ViBufferedStream streamWithTask:self];
	if (stdinData)
		[stream writeData:stdinData];

        [stream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	return stream;
}

- (ViBufferedStream *)scheduledStreamWithStandardInput:(NSData *)stdinData
{
	return [self scheduledStreamWithStandardInput:stdinData captureStandardError:NO];
}

@end
