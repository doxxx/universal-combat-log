//
//  UCLFightAnalyzer.m
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-07-29.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UCLSummarizer.h"
#import "UCLLogEvent.h"

@interface UCLSummarizer ()
        
- (NSArray*)calculateDPS;
- (NSArray *)calculateHPS;
- (NSArray*)calculateAmountsWithSelector:(SEL)selector;

@end

@implementation UCLSummarizer

@synthesize fight=_fight;

-(id)initWithFight:(UCLFight *)fight
{
    self = [super init];
    if (self) {
        _fight = fight;
    }
    return self;
}

-(NSArray *)summarizeForType:(enum SummaryType)type
{
    switch (type) {
        case DPS:
            return [self calculateDPS];
            break;
            
        case HPS:
            return [self calculateHPS];
            break;
            
        default:
            return nil;
    }
}

-(NSArray *)calculateDPS
{
    return [self calculateAmountsWithSelector:@selector(isDamage)];
}

-(NSArray *)calculateHPS
{
    return [self calculateAmountsWithSelector:@selector(isHealing)];
}

- (NSArray *)calculateAmountsWithSelector:(SEL)selector
{
    NSMutableDictionary* temp = [NSMutableDictionary dictionary];
    
    for (UCLLogEvent* event in _fight.events) {
        if (event.actor == nil || event.actor.name == nil) {
            continue;
        }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if ([event performSelector:selector]) {
#pragma clang diagnostic pop
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

+(UCLSummarizer *)summarizerForFight:(UCLFight *)fight
{
    return [[UCLSummarizer alloc] initWithFight:fight];
}


@end
