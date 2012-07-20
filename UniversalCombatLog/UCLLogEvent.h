//
//  UCLLogEvent.h
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-07-19.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UCLEntity.h"
#import "UCLSpell.h"

enum EventType {
    DirectDamage = 3,
    DamageOverTime = 4
};

@interface UCLLogEvent : NSObject

@property (readonly, strong, nonatomic) NSDate* time;
@property (readonly, nonatomic) enum EventType eventType;
@property (readonly, weak, nonatomic) UCLEntity* actor;
@property (readonly, weak, nonatomic) UCLEntity* target;
@property (readonly, weak, nonatomic) UCLSpell* spell;
@property (readonly, weak, nonatomic) NSNumber* amount;
@property (readonly, weak, nonatomic) NSString* text;

- (id)initWithTime:(NSDate*)theTime eventType:(enum EventType)theEventType 
             actor:(UCLEntity*)theActor target:(UCLEntity*)theTarget 
             spell:(UCLSpell*)theSpell amount:(NSNumber*)theAmount text:(NSString*)theText;

+ (UCLLogEvent*)logEventWithTime:(NSDate*)theTime eventType:(enum EventType)theEventType 
                           actor:(UCLEntity*)theActor target:(UCLEntity*)theTarget 
                           spell:(UCLSpell*)theSpell amount:(NSNumber*)theAmount text:(NSString*)theText;


@end
