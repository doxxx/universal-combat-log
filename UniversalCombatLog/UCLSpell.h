//
//  UCLSpell.h
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-07-19.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UCLSpell : NSObject

@property (readonly, nonatomic) uint64_t idNum;
@property (readonly, strong, nonatomic) NSString* name;

- (id)initWithIdNum:(uint64_t)theIdNum name:(NSString*)theName;

+ (UCLSpell*)spellWithIdNum:(uint64_t)theIdNum name:(NSString*)theName;

@end
