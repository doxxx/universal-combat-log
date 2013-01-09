//
//  UCLLogFile.m
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-07-20.
//  Copyright (c) 2012 Gordon Tyler. All rights reserved.
//

#import "UCLLogFile.h"

@implementation UCLLogFile

- (id)initWithFights:(NSArray*)fights
{
    self = [super init];
    if (self) {
        _fights = fights;
    }
    return self;
}

+ (UCLLogFile*)logFileWithFights:(NSArray*)fights
{
    return [[UCLLogFile alloc] initWithFights:fights];
}

@end
