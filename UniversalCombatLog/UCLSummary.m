//
//  UCLFightAnalyzer.m
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-07-29.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UCLSummary.h"
#import "UCLLogEvent.h"

@interface UCLSummary ()
        
- (NSArray*)calculateDPS;
- (NSArray *)calculateHPS;

@end

@implementation UCLSummary

@synthesize fight=_fight, result=_result;

-(id)initWithFight:(UCLFight *)fight type:(enum SummaryType)type
{
    self = [super init];
    if (self) {
        _fight = fight;
        switch (type) {
            case DPS:
                _result = [self calculateDPS];
                break;
                
            case HPS:
                _result = [self calculateHPS];
                break;
                
            default:
                break;
        }
    }
    return self;
}

-(NSArray *)calculateDPS
{
    NSMutableDictionary* temp = [NSMutableDictionary dictionary];
    
    for (UCLLogEvent* event in _fight.events) {
        if (event.actor == nil || event.actor.name == nil) {
            continue;
        }
        if ([event isDamage]) {
            NSNumber* amount = [temp objectForKey:event.actor.name];
            if (amount == nil) {
                amount = event.amount;
            }
            else {
                amount = [NSNumber numberWithLong:([amount longValue] + [event.amount longValue])];
            }
            [temp setObject:amount forKey:event.actor.name];
        }
    }
    
    for (NSString* name in [temp allKeys]) {
        double dps = ([[temp objectForKey:name] doubleValue] / self.fight.duration);
        [temp setObject:[NSNumber numberWithLong:dps] forKey:name];
    }
    
    NSArray* sortedNames = [temp keysSortedByValueUsingComparator:^(id obj1, id obj2) {
        if ([obj1 longValue] > [obj2 longValue]) {
            return NSOrderedAscending;
        }
        if ([obj1 longValue] < [obj2 longValue]) {
            return NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    NSMutableArray* result = [NSMutableArray arrayWithCapacity:[temp count]];
    for (NSString* name in sortedNames) {
        [result addObject:[[UCLSummaryEntry alloc] initWithName:name amount:[temp objectForKey:name]]];
    }
    
    return result;
}

-(NSArray *)calculateHPS
{
#pragma warn IMPLEMENT THIS METHOD!
    return nil;
}

+(UCLSummary *)summaryWithFight:(UCLFight *)fight type:(enum SummaryType)type
{
    return [[UCLSummary alloc] initWithFight:fight type:type];
}


@end
