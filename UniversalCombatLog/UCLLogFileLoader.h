//
//  UCLLogFileLoader.h
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-07-23.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UCLLogFile.h"

@interface UCLLogFileLoader : NSObject

- (id)initWithData:(NSData*)data;

- (UCLLogFile*)load;

+ (UCLLogFile*)loadFromData:(NSData*)data;

@end
