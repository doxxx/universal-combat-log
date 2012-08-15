//
//  UCLFight.m
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-07-20.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UCLFight.h"
#import "UCLLogEvent.h"

@implementation UCLFight

@synthesize events=_events, title=_title;

- (id)initWithEvents:(NSArray*)theEvents title:(NSString*)theTitle
{
    self = [super init];
    if (self) {
        _events = theEvents;
        _title = theTitle;
    }
    return self;
}

- (NSDate*)startTime
{
    UCLLogEvent* first = [self.events objectAtIndex:0];
    return [first time];
}

- (NSDate*)endTime
{
    UCLLogEvent* last = [self.events lastObject];
    return [last time];
}

- (NSTimeInterval)duration
{
    return [[self endTime] timeIntervalSinceDate:[self startTime]];
}

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

+ (UCLFight*)fightWithEvents:(NSArray*)theEvents title:(NSString*)theTitle
{
    return [[UCLFight alloc] initWithEvents:theEvents title:theTitle];
}


@end
