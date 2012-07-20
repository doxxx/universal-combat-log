//
//  UCLLogFile.m
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-07-20.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UCLLogFile.h"

@implementation UCLLogFile

@synthesize fights=_fights;

- (id)initWithFights:(NSArray*)theFights
{
    self = [super init];
    if (self) {
        _fights = theFights;
    }
    return self;
}

+ (UCLLogFile*)logFileWithFights:(NSArray*)theFights
{
    return [[UCLLogFile alloc] initWithFights:theFights];
}

@end
