//
//  UCLProtocol.m
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-09-30.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UCLProtocol.h"

#import <arpa/inet.h>

@implementation UCLProtocol
{
    NSInputStream* readStream;
//    NSOutputStream* writeStream;
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    if ([[[request URL] scheme] caseInsensitiveCompare:@"ucl"] == NSOrderedSame) {
        return YES;
    }
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

- (void)startLoading
{
    NSURL* url = [self.request URL];
    NSURLResponse* response = [[NSURLResponse alloc] initWithURL:url 
                                                        MIMEType:@"application/octet-stream" 
                                           expectedContentLength:-1 
                                                textEncodingName:nil];
//    CFHostRef host = CFHostCreateWithName(NULL, (__bridge CFStringRef)self.request.URL.host);
    struct sockaddr_in sockAddress;
    memset(&sockAddress, 0, sizeof(sockAddress));
    sockAddress.sin_family = AF_INET;
    const char* hostName = [[url host] cStringUsingEncoding:NSUTF8StringEncoding];
    if (!inet_aton(hostName, &sockAddress.sin_addr)) {
        NSError* error = [NSError errorWithDomain:@"inet_aton" code:errno userInfo:nil];
        NSLog(@"inet_aton: %s", strerror(errno));
        [self.client URLProtocol:self didFailWithError:error];
    }
    CFDataRef addressData = CFDataCreate(NULL, (const UInt8*)&sockAddress, sizeof(sockAddress));
    CFHostRef host = CFHostCreateWithAddress(NULL, addressData);
    CFReadStreamRef cfReadStream = NULL;
//    CFWriteStreamRef cfWriteStream = NULL;
    CFStreamCreatePairWithSocketToCFHost(NULL, host, [[url port] intValue], &cfReadStream, NULL);

    readStream = (__bridge_transfer NSInputStream*)cfReadStream;
    readStream.delegate = self;
//    writeStream = (__bridge_transfer NSOutputStream*)cfWriteStream;
//    writeStream.delegate = self;

    [readStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
//        [writeStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [readStream open];
//        [writeStream open];
    
    [self.client URLProtocol:self didReceiveResponse:response 
          cacheStoragePolicy:NSURLCacheStorageAllowedInMemoryOnly];

    CFRelease(addressData);
    CFRelease(host);
}

#define BUFFER_SIZE 1024*1024

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    if (aStream == readStream) {
        if (eventCode == NSStreamEventHasBytesAvailable) {
            uint8_t *buffer = malloc(BUFFER_SIZE);
            NSInteger bytesRead = [readStream read:buffer maxLength:BUFFER_SIZE];
            if (bytesRead < 0) {
                NSError* error = [readStream streamError];
                NSLog(@"Stream error: %@", [error localizedDescription]);
                [self.client URLProtocol:self didFailWithError:error];
                [self close];
            }
            else if (bytesRead == 0) {
                [self.client URLProtocolDidFinishLoading:self];
                [self close];
            }
            else {
                [self.client URLProtocol:self didLoadData:[NSData dataWithBytes:buffer length:bytesRead]];
            }
            free(buffer);
        }
        else if (eventCode == NSStreamEventEndEncountered) {
            [self.client URLProtocolDidFinishLoading:self];
            [self close];
        }
    }
}

- (void)stopLoading
{
    [self close];
}

- (void)close
{
    if (readStream) {
        [readStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        readStream.delegate = nil;
        [readStream close];
        readStream = nil;
    }
//    if (writeStream) {
//        [writeStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];        
//        writeStream.delegate = nil;
//        [writeStream close];
//        writeStream = nil;
//    }
}

@end
