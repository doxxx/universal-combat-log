//
//  UCLFight+Summaries.m
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-12-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UCLFight+Filtering.h"

@implementation UCLFight (Filtering)

- (NSArray*)filterEventsUsingPredicate:(UCLLogEventPredicate)predicate
{
    NSMutableArray *result = [NSMutableArray array];
    for (UCLLogEvent* event in self.events) {
        if (predicate(event)) {
            [result addObject:event];
        }
    }
    return result;
}


@end
