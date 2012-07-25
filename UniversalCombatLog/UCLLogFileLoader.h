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

- (uint8_t)readUInt8;
- (uint16_t)readUInt16;
- (uint32_t)readUInt32;
- (uint64_t)readUInt64;
- (NSString*)readUTF8;

- (UCLLogFile*)load;

+ (UCLLogFile*)loadFromURL:(NSURL*)url;

@end
