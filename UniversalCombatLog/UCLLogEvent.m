//
//  UCLLogEvent.m
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-07-19.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UCLLogEvent.h"

@implementation UCLLogEvent

@synthesize time=_time, eventType=_eventType, actor=_actor, target=_target, spell=_spell, amount=_amount, text=_text;

- (id)initWithTime:(NSDate*)theTime eventType:(enum EventType)theEventType 
             actor:(UCLEntity*)theActor target:(UCLEntity*)theTarget 
             spell:(UCLSpell*)theSpell amount:(NSNumber*)theAmount text:(NSString*)theText
{
    self = [super init];
    if (self) {
        _time = theTime;
        _eventType = theEventType;
        _actor = theActor;
        _target = theTarget;
        _spell = theSpell;
        _amount = theAmount;
        _text = theText;
    }
    return self;
}

- (BOOL)isDamage
{
    BOOL result;
    switch (self.eventType) {
        case ETDirectDamage:
        case ETDamageOverTime:
        case ETCritDamage:
        case ETEnvDamage:
            result = TRUE;
            break;
            
        default:
            result = FALSE;
            break;
    }
    return result;
}

+ (UCLLogEvent*)logEventWithTime:(NSDate*)theTime eventType:(enum EventType)theEventType 
                           actor:(UCLEntity*)theActor target:(UCLEntity*)theTarget 
                           spell:(UCLSpell*)theSpell amount:(NSNumber*)theAmount text:(NSString*)theText
{
    return [[UCLLogEvent alloc] initWithTime:theTime eventType:theEventType actor:theActor 
                                      target:theTarget spell:theSpell amount:theAmount text:theText];
}

@end
