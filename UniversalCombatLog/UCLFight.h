//
//  UCLFight.h
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-07-20.
//  Copyright (c) 2012 Gordon Tyler. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UCLEntity.h"
#import "UCLLogEvent.h"

@interface UCLFight : NSObject

@property (readonly, nonatomic) UCLLogEvent* events;
@property (readonly, nonatomic) uint32_t count;
@property (readonly, strong, nonatomic) NSString* title;

- (id)initWithEvents:(UCLLogEvent*)events count:(uint32_t)count title:(NSString*)title entityIndex:(NSDictionary*)entityIndex spellIndex:(NSDictionary*)spellIndex;

- (uint64_t)startTime;
- (uint64_t)endTime;
- (uint64_t)duration;
- (UCLEntity*)entityForID:(uint64_t)entityID;
- (UCLSpell*)spellForID:(uint64_t)spellID;
- (NSRange)indexRangeForTimeRange:(NSRange)timeRange;

+ (UCLFight*)fightWithEvents:(UCLLogEvent*)events count:(uint32_t)count title:(NSString*)title entityIndex:(NSDictionary*)entityIndex spellIndex:(NSDictionary*)spellIndex;

@end
