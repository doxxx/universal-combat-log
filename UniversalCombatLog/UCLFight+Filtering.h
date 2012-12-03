//
//  UCLFight+Summaries.h
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-12-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UCLFight.h"

typedef BOOL (^UCLLogEventPredicate)(UCLLogEvent* event);

@interface UCLFight (Filtering)

- (NSArray*)filterEventsUsingPredicate:(UCLLogEventPredicate)predicate;

@end
