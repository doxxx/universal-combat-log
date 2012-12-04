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

@end
