//
//  UCLFight+Summarizing.h
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-12-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UCLFight.h"
#import "UCLFight+Filtering.h"

@interface UCLFight (Summarizing)

- (NSDictionary*)sumAmountsPerActorWithPredicate:(UCLLogEventPredicate)predicate;
- (NSArray*)amountsPerSecondUsingWindowSize:(NSUInteger)windowSize withPredicate:(UCLLogEventPredicate)predicate;
- (NSDictionary *)spellBreakdownWithPredicate:(UCLLogEventPredicate)predicate;

@end
