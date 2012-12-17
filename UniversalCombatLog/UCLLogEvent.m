//
//  UCLLogEvent.m
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-07-19.
//  Copyright (c) 2012 Gordon Tyler. All rights reserved.
//

#import "UCLLogEvent.h"

BOOL UCLLogEventIsDamage(UCLLogEvent* event)
{
    switch (event->eventType) {
        case ETDirectDamage:
        case ETDamageOverTime:
        case ETCritDamage:
        case ETEnvDamage:
            return YES;

        default:
            return NO;
    }
}

BOOL UCLLogEventIsHealing(UCLLogEvent* event)
{
    switch (event->eventType) {
        case ETHeal:
        case ETCritHeal:
            return YES;

        default:
            return NO;
    }
}

BOOL UCLLogEventIsMiss(UCLLogEvent* event)
{
    switch (event->eventType) {
        case ETMiss:
        case ETResist:
        case ETDodge:
        case ETParry:
        case ETImmune:
            return YES;

        default:
            return NO;
    }
}

BOOL UCLLogEventIsCrit(UCLLogEvent* event)
{
    switch (event->eventType) {
        case ETCritDamage:
        case ETCritHeal:
            return YES;

        default:
            return NO;
    }
}
