//
//  UCLLogEvent.m
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-07-19.
//  Copyright (c) 2012 Gordon Tyler. All rights reserved.
//

#import "UCLLogEvent.h"

BOOL isLogEventDamage(UCLLogEvent* event)
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

BOOL isLogEventHealing(UCLLogEvent* event)
{
    switch (event->eventType) {
        case ETHeal:
        case ETCritHeal:
            return YES;

        default:
            return NO;
    }
}

BOOL isLogEventMiss(UCLLogEvent* event)
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

BOOL isLogEventCrit(UCLLogEvent* event)
{
    switch (event->eventType) {
        case ETCritDamage:
        case ETCritHeal:
            return YES;

        default:
            return NO;
    }
}
