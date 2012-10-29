//
//  UCLNetworkClient.m
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-09-25.
//  Copyright (c) 2012 Gordon Tyler. All rights reserved.
//

#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <fcntl.h>

#import "UCLNetworkClient.h"
#import "UCLLogFileLoader.h"
#import "SBJson/SBJson.h"

@implementation UCLNetworkClient
{
    int discoverySocket;
    dispatch_source_t dispatchSource;
}

@synthesize discoveryCallback = _discoveryCallback;

- (id)init
{
    self = [super init];
    if (self) {
        int sd = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
        const int option_broadcast = 1;
        if (setsockopt(sd, SOL_SOCKET, SO_BROADCAST, &option_broadcast, sizeof(option_broadcast)) < 0) {
            NSLog(@"Error setting broadcast option on socket: %s", strerror(errno));
            return nil;
        }
        discoverySocket = sd;
    }
    return self;
}

- (void)close
{
    if (dispatchSource) {
        dispatch_source_cancel(dispatchSource);
        dispatchSource = NULL;
    }
    
    close(discoverySocket);
}

- (void)setDiscoveryCallback:(ServerDiscoveryCallback)discoveryCallback
{
    if (dispatchSource) {
        dispatch_source_cancel(dispatchSource);
        dispatchSource = NULL;
    }
    
    _discoveryCallback = discoveryCallback;
    if (discoveryCallback == NULL) {
        return;
    }
    
    dispatchSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, discoverySocket, 0, dispatch_get_main_queue());
    if (dispatchSource == NULL) {
        NSLog(@"Could not create GCD dispatch source");
        return;
    }
    
    dispatch_source_set_event_handler(dispatchSource, ^void(void) {
        char data[50];
        struct sockaddr_in remote_address;
        socklen_t remote_address_len;
        ssize_t bytes = recvfrom(discoverySocket, &data, 50, 0, (struct sockaddr*)&remote_address, &remote_address_len);
        if (bytes < 0) {
            NSLog(@"Error receiving discovery reply packet: %s", strerror(errno));
        }
        else {
            data[bytes] = 0; // ensure null-terminated
            NSString* discoveryReply = [NSString stringWithCString:data encoding:NSUTF8StringEncoding];
            NSLog(@"Received discovery reply: %@", discoveryReply);
            discoveryCallback([NSURL URLWithString:discoveryReply]);
        }
    });

    // Wait for reply
    dispatch_resume(dispatchSource);
}

- (void)discoverServers
{
    // Send discovery packet
    struct sockaddr_in address;
    memset(&address, 0, sizeof(address));
    address.sin_family = AF_INET;
    address.sin_addr.s_addr = inet_addr("255.255.255.255");
    address.sin_port = htons(5555);
    char* discover_msg = "UCLDISCOVER";
    size_t discover_msg_len = strlen(discover_msg);
    ssize_t bytes_sent = sendto(discoverySocket, discover_msg, discover_msg_len, 0, (struct sockaddr*)&address, sizeof(address));
    if (bytes_sent < 0) {
        NSLog(@"Error sending discovery packet: %s", strerror(errno));
        return;
    }
}

- (void)listLogFilesAtURL:(NSURL *)url withCallback:(LogFileListCallack)callback
{
    void (^handler)(NSURLResponse* response, NSData* data, NSError* error) = ^(NSURLResponse* response, NSData* data, NSError* error) {
        if (data == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"UCL" 
                                            message:[error localizedDescription] 
                                           delegate:nil 
                                  cancelButtonTitle:@"OK" 
                                  otherButtonTitles:nil] show];
            });
        }
        else {
            NSString* json = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
            NSLog(@"Received JSON: %@", json);
            NSArray* jsonArray = [json JSONValue];
            NSMutableArray* entries = [NSMutableArray arrayWithCapacity:[jsonArray count]];
            for (NSDictionary* jsonEntry in jsonArray) {
                NSDictionary* entry = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [jsonEntry objectForKey:@"title"], @"title", 
                                       [NSURL URLWithString:[jsonEntry objectForKey:@"url"]], @"url", 
                                       nil];
                [entries addObject:entry];
            }
            callback(entries);
        }
    };
    NSURL* logFilesURL = [NSURL URLWithString:@"logfiles" relativeToURL:url];
    NSLog(@"log files URL = %@", [logFilesURL absoluteString]);
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:logFilesURL] 
                                       queue:[NSOperationQueue mainQueue] 
                           completionHandler:handler];
}

@end
