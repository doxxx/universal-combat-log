//
//  UCLFight+Summarizing.m
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-12-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UCLFight+Summarizing.h"

@implementation UCLFight (Summarizing)

- (NSDictionary*)sumAmountsPerActorWithPredicate:(UCLLogEventPredicate)predicate 
{
    NSMutableDictionary* amounts = [NSMutableDictionary dictionary];

    UCLLogEvent* event = self.events;
    for (uint32_t i = 0; i < self.count; i++, event++) {
        if (predicate != NULL && predicate(event)) {
            NSNumber* amount = [amounts objectForKey:@(event->actorID)];
            if (amount == nil) {
                amount = @(event->amount);
            }
            else {
                amount = @(amount.unsignedLongLongValue + event->amount);
            }
            [amounts setObject:amount forKey:@(event->actorID)];
        }
    }
    
    return amounts;
}

- (NSArray*)amountsPerSecondUsingWindowSize:(NSUInteger)windowSize withPredicate:(UCLLogEventPredicate)predicate
{
    uint64_t startTime = self.startTime;
    uint32_t durationSecs = ceil(self.duration/1000.0);
    uint64_t* totals = malloc(sizeof(uint64_t) * durationSecs);

    for (NSUInteger i = 0; i < durationSecs; i++) {
        totals[i] = 0;
    }

    UCLLogEvent* event = self.events;
    for (uint32_t i = 0; i < self.count; i++, event++) {
        uint32_t index = floor((event->time - startTime) / 1000.0);
        if (predicate(event)) {
            totals[index] = totals[index] + event->amount;
        }
    }

    NSMutableArray* amounts = [NSMutableArray arrayWithCapacity:durationSecs];

    for (NSUInteger i = 0; i < durationSecs; i++) {
        double value = 0;
        NSUInteger actualWindowSize = MIN(windowSize, i + 1);
        for (NSInteger j = i - actualWindowSize + 1; j <= i; j++) {
            value += totals[j];
        }
        [amounts addObject:@(value / actualWindowSize)];
    }

    free(totals);

    return amounts;
}

- (NSDictionary *)spellBreakdownWithPredicate:(UCLLogEventPredicate)predicate
{
    NSMutableDictionary* spellBreakdown = [NSMutableDictionary dictionary];

    UCLLogEvent* event = self.events;
    for (uint32_t i = 0; i < self.count; i++, event++) {
        if (predicate(event)) {
            NSNumber* key = @(event->spellID);
            NSNumber* currentAmount = [spellBreakdown objectForKey:key];
            if (currentAmount == nil) {
                [spellBreakdown setObject:@(event->amount) forKey:key];
            }
            else {
                uint64_t newAmount = event->amount + currentAmount.longLongValue;
                [spellBreakdown setObject:@(newAmount) forKey:key];
            }
        }
    }
    
    return spellBreakdown;
}

@end
