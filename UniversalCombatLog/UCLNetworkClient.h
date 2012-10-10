//
//  UCLNetworkClient.h
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-09-25.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ServerDiscoveryCallback)(NSURL*);

@interface UCLNetworkClient : NSObject

@property (strong, nonatomic) ServerDiscoveryCallback discoveryCallback;

- (void)discoverServers;

@end
