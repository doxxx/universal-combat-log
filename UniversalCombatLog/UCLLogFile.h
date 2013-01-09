//
//  UCLLogFile.h
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-07-20.
//  Copyright (c) 2012 Gordon Tyler. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UCLLogFile : NSObject

@property (readonly, strong, nonatomic) NSArray* fights;

- (id)initWithFights:(NSArray*)fights;

+ (UCLLogFile*)logFileWithFights:(NSArray*)fights;

@end
