//
//  UCLLogFile.h
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-07-20.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UCLLogFile : NSObject

@property (readonly, strong, nonatomic) NSString* title;
@property (readonly, strong, nonatomic) NSArray* fights;

- (id)initWithFights:(NSArray*)theFights;

+ (UCLLogFile*)logFileWithFights:(NSArray*)theFights;

@end
