//
//  UCLFight.h
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-07-20.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UCLEntity.h"
#import "UCLLogEvent.h"

typedef BOOL (^UCLLogEventPredicate)(UCLLogEvent* event);

@interface UCLFight : NSObject

@property (readonly, strong, nonatomic) NSArray* events;
@property (readonly, strong, nonatomic) NSString* title;

- (id)initWithEvents:(NSArray*)theEvents title:(NSString*)theTitle;

- (NSDate*)startTime;
- (NSDate*)endTime;
- (NSTimeInterval)duration;

- (NSArray*)filterEventsUsingPredicate:(UCLLogEventPredicate)predicate;

+ (UCLFight*)fightWithEvents:(NSArray*)theEvents title:(NSString*)theTitle;

@end
