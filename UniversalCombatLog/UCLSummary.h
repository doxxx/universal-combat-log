//
//  UCLFightAnalyzer.h
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-07-29.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UCLFight.h"
#import "UCLSummaryEntry.h"

enum SummaryType {
    DPS = 1,
    HPS = 2,
};

@interface UCLSummary : NSObject

@property (readonly, nonatomic) UCLFight* fight;
@property (readonly, nonatomic) NSArray* result;

- (id)initWithFight:(UCLFight*)fight type:(enum SummaryType)type;

+ (UCLSummary*)summaryWithFight:(UCLFight*)fight type:(enum SummaryType)type;

@end
