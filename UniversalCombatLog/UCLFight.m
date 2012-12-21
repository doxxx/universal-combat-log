//
//  UCLFight.m
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-07-20.
//  Copyright (c) 2012 Gordon Tyler. All rights reserved.
//

#import "UCLFight.h"
#import "UCLLogEvent.h"

@implementation UCLFight
{
    NSDictionary* _entityIndex;
    NSDictionary* _spellIndex;
}

- (id)initWithEvents:(UCLLogEvent*)events count:(uint32_t)count title:(NSString*)title entityIndex:(NSDictionary*)entityIndex spellIndex:(NSDictionary*)spellIndex
{
    self = [super init];
    if (self) {
        _events = events;
        _count = count;
        _title = title;
        _entityIndex = entityIndex;
        _spellIndex = spellIndex;
    }
    return self;
}

- (void)dealloc
{
    UCLLogEvent* event = _events;
    for (uint32_t i = 0; i < _count; i++, event++) {
        free(event->text);
    }
    free(_events);
}

- (uint64_t)startTime
{
    return _events->time;
}

- (uint64_t)endTime
{
    UCLLogEvent* last = _events + (_count - 1);
    return last->time;
}

- (uint64_t)duration
{
    return self.endTime - self.startTime;
}

- (UCLEntity*)entityForID:(uint64_t)entityID
{
    return [_entityIndex objectForKey:@(entityID)];
}

- (UCLSpell*)spellForID:(uint64_t)spellID
{
    return [_spellIndex objectForKey:@(spellID)];
}

- (NSRange)indexRangeForTimeRange:(NSRange)timeRange
{
    uint64_t startTime = self.startTime;
    NSUInteger start = timeRange.location;
    NSUInteger end = timeRange.location + timeRange.length;
    NSUInteger loc = 0, length = 0;

    UCLLogEvent* event = self.events;

    // find start
    uint32_t count = self.count;
    for (uint32_t i = 0; i < count; i++, event++) {
        uint64_t timeSinceStart = event->time - startTime;
        NSUInteger index = timeSinceStart / 1000;
        if (index < start) {
            continue;
        }
        loc = i;
        break;
    }

    // find end
    length = count - loc;
    for (uint32_t i = loc; i < count; i++, event++) {
        uint64_t timeSinceStart = event->time - startTime;
        NSUInteger index = timeSinceStart / 1000;
        if (index < end) {
            continue;
        }
        length = i - loc;
        break;
    }

    return NSMakeRange(loc, length);
}

+ (UCLFight*)fightWithEvents:(UCLLogEvent*)events count:(uint32_t)count title:(NSString*)title entityIndex:(NSDictionary*)entityIndex spellIndex:(NSDictionary*)spellIndex;
{
    return [[UCLFight alloc] initWithEvents:events count:count title:title entityIndex:entityIndex spellIndex:spellIndex];
}


@end
