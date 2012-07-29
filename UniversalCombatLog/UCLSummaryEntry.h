//
//  UCLSummaryEntry.h
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-07-29.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UCLSummaryEntry : NSObject

@property (readonly, nonatomic) NSString* name;
@property (readonly, nonatomic) NSNumber* amount;

- (id)initWithName:(NSString*)name amount:(NSNumber*)amount;

@end
