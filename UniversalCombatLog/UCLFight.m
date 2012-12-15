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

@synthesize events=_events, count=_count, title=_title;

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

+ (UCLFight*)fightWithEvents:(UCLLogEvent*)events count:(uint32_t)count title:(NSString*)title entityIndex:(NSDictionary*)entityIndex spellIndex:(NSDictionary*)spellIndex;
{
    return [[UCLFight alloc] initWithEvents:events count:count title:title entityIndex:entityIndex spellIndex:spellIndex];
}


@end
