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

typedef struct s_UCLLogEvent {
    uint64_t time;
    enum EventType eventType;
    uint64_t actorID;
    uint64_t targetID;
    uint64_t spellID;
    uint64_t amount;
    char* text;
} UCLLogEvent;

UCLLogEvent* createLogEvent(uint64_t time, enum EventType eventType, uint64_t actorID, uint64_t targetID,
                            uint64_t spellID, uint64_t amount, char* text);

BOOL isLogEventDamage(UCLLogEvent* event);
BOOL isLogEventHealing(UCLLogEvent* event);
BOOL isLogEventMiss(UCLLogEvent* event);
BOOL isLogEventCrit(UCLLogEvent* event);
