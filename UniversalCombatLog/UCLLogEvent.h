//
//  UCLLogEvent.h
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-07-19.
//  Copyright (c) 2012 Gordon Tyler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UCLEntity.h"
#import "UCLSpell.h"

enum EventType {
    ETUnknown = 0,
    ETBeginCasting = 1,
    ETInterrupted = 2,
    ETDirectDamage = 3,
    ETDamageOverTime = 4,
    ETHeal = 5,
    ETBuffGain = 6,
    ETBuffFade = 7,
    ETDebuffGain = 8,
    ETDebuffFade = 9,
    ETMiss = 10,
    ETSlain = 11,
    ETDied = 12,
    ETUnknown13 = 13,
    ETEnvDamage = 14,
    ETDodge = 15,
    ETParry = 16,
    ETUnknown17 = 17,
    ETUnknown18 = 18,
    ETResist = 19,
    ETUnknown20 = 20,
    ETUnknown21 = 21,
    ETUnknown22 = 22,
    ETCritDamage = 23,
    ETFavorGain = 24,
    ETImmune = 26,
    ETPowerGain = 27,
    ETCritHeal = 28,
};

@interface UCLLogEvent : NSObject

@property (readonly, strong, nonatomic) NSDate* time;
@property (readonly, nonatomic) enum EventType eventType;
@property (readonly, strong, nonatomic) UCLEntity* actor;
@property (readonly, strong, nonatomic) UCLEntity* target;
@property (readonly, strong, nonatomic) UCLSpell* spell;
@property (readonly, strong, nonatomic) NSNumber* amount;
@property (readonly, strong, nonatomic) NSString* text;

- (id)initWithTime:(NSDate*)theTime eventType:(enum EventType)theEventType 
             actor:(UCLEntity*)theActor target:(UCLEntity*)theTarget 
             spell:(UCLSpell*)theSpell amount:(NSNumber*)theAmount text:(NSString*)theText;

- (BOOL)isDamage;
- (BOOL)isHealing;
- (BOOL)isMiss;
- (BOOL)isCrit;

+ (UCLLogEvent*)logEventWithTime:(NSDate*)theTime eventType:(enum EventType)theEventType 
                           actor:(UCLEntity*)theActor target:(UCLEntity*)theTarget 
                           spell:(UCLSpell*)theSpell amount:(NSNumber*)theAmount text:(NSString*)theText;


@end
