//
//  UCLFight+Summarizing.m
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-12-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UCLFight+Summarizing.h"

@implementation UCLFight (Summarizing)

- (NSDictionary*)sumActorAmountsWithPredicate:(UCLLogEventPredicate)predicate 
{
    NSMutableDictionary* amounts = [NSMutableDictionary dictionary];
    
    for (UCLLogEvent* event in self.events) {
        if (predicate != NULL && predicate(event)) {
            NSNumber* amount = [amounts objectForKey:event.actor];
            if (amount == nil) {
                amount = event.amount;
            }
            else {
                amount = [NSNumber numberWithLong:([amount longValue] + [event.amount longValue])];
            }
            [amounts setObject:amount forKey:event.actor];
        }
    }
    
    return amounts;
}

- (NSDictionary*)sumActorAmountsPerSecondWithPredicate:(UCLLogEventPredicate)predicate
{
    NSDictionary* amounts = [self sumActorAmountsWithPredicate:predicate];
    NSMutableDictionary* amountsPerSecond = [NSMutableDictionary dictionaryWithCapacity:amounts.count];

    for (UCLEntity* actor in [amounts allKeys]) {
        double value = ([[amounts objectForKey:actor] doubleValue] / self.duration);
        [amountsPerSecond setObject:[NSNumber numberWithLong:value] forKey:actor];
    }

    return amountsPerSecond;
}

- (NSArray*)amountsPerSecondUsingWindowSize:(NSUInteger)windowSize withPredicate:(UCLLogEventPredicate)predicate
{
    NSDate* startTime = self.startTime;
    NSUInteger duration = ceil(self.duration);
    double* totals = malloc(sizeof(double) * duration);

    for (NSUInteger i = 0; i < duration; i++) {
        totals[i] = 0;
    }

    for (UCLLogEvent* event in self.events) {
        uint32_t index = floor([event.time timeIntervalSinceDate:startTime]);
        if (predicate(event)) {
            totals[index] = totals[index] + [event.amount doubleValue];
        }
    }

    NSMutableArray* amounts = [NSMutableArray arrayWithCapacity:duration];

    for (NSUInteger i = 0; i < duration; i++) {
        double value = 0;
        NSUInteger actualWindowSize = MIN(windowSize, i + 1);
        for (NSInteger j = i - actualWindowSize + 1; j <= i; j++) {
            value += totals[j];
        }
        [amounts addObject:[NSNumber numberWithDouble:(value / actualWindowSize)]];
    }

    free(totals);

    return amounts;
}

- (NSDictionary *)spellBreakdownWithPredicate:(UCLLogEventPredicate)predicate
{
    NSMutableDictionary* spellBreakdown = [NSMutableDictionary dictionary];

    for (UCLLogEvent* event in self.events) {
        if (predicate(event)) {
                NSNumber* amount = [spellBreakdown objectForKey:event.spell];
                if (amount == nil) {
                    [spellBreakdown setObject:event.amount forKey:event.spell];
                }
                else {
                    long eventAmount = [event.amount longValue];
                    long currentAmount = amount.longValue;
                    long newAmount = eventAmount + currentAmount;
                    [spellBreakdown setObject:[NSNumber numberWithLong:newAmount] forKey:event.spell];
                }
            }
    }
    
    return spellBreakdown;
}



@end
