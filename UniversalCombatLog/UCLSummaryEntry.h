//
//  UCLSummaryEntry.h
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-07-29.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UCLSummaryEntry : NSObject <NSCopying>

@property (readonly, nonatomic) id item;
@property (readonly, nonatomic) NSNumber* amount;

- (id)initWithItem:(id)item amount:(NSNumber*)amount;

- (BOOL)isEqualToSummaryEntry:(UCLSummaryEntry*)summaryEntry;

@end
