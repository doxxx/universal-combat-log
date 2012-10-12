//
//  UCLNetworkClient.h
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-09-25.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ServerDiscoveryCallback)(NSURL*);
typedef void (^LogFileListCallack)(NSArray*);

@interface UCLNetworkClient : NSObject

@property (strong, nonatomic) ServerDiscoveryCallback discoveryCallback;

- (void)discoverServers;
- (void)listLogFilesAtURL:(NSURL*)url withCallback:(LogFileListCallack)callback;

@end
