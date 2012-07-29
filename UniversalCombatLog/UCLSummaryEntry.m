//
//  UCLSummaryEntry.m
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-07-29.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UCLSummaryEntry.h"

@implementation UCLSummaryEntry

@synthesize name=_name, amount=_amount;

- (id)initWithName:(NSString*)name amount:(NSNumber*)amount
{
    self = [super init];
    if (self) {
        _name = name;
        _amount = amount;
    }
    return self;
}

@end
