//
//  UCLSummaryEntry.m
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-07-29.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UCLSummaryEntry.h"

@implementation UCLSummaryEntry

@synthesize item=_item, amount=_amount;

- (id)initWithItem:(id)item amount:(NSNumber*)amount
{
    self = [super init];
    if (self) {
        _item = item;
        _amount = amount;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if ([object class] != [self class]) {
        return FALSE;
    }
    return [self isEqualToSummaryEntry:object];
}

- (BOOL)isEqualToSummaryEntry:(UCLSummaryEntry*)summaryEntry
{
    return [self.item isEqual:summaryEntry.item] && [self.amount isEqualToNumber:summaryEntry.amount];
}

- (id)copyWithZone:(NSZone *)zone
{
    // Immutable class, can return original instead of copying.
    return self;
}

- (NSUInteger)hash
{
    return 31 ^ [self.item hash] ^ [self.amount hash];
}


@end
