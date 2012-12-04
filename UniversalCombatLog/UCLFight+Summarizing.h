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

- (NSDictionary*)sumActorAmountsWithPredicate:(UCLLogEventPredicate)predicate;
- (NSDictionary*)sumActorAmountsPerSecondWithPredicate:(UCLLogEventPredicate)predicate;

@end
