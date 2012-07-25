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
{
    const void* _data;
    NSUInteger _length;
    const void* _cursor;
}

- (id)initWithURL:(NSURL*)url;

- (UCLLogFile*)load;

+ (UCLLogFile*)loadFromURL:(NSURL*)url;

@end
