//
//  UCLSpell.h
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-07-19.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UCLSpell : NSObject

@property (readonly, nonatomic) long idNum;
@property (readonly, strong, nonatomic) NSString* name;

- (id)initWithIdNum:(long)theIdNum name:(NSString*)theName;

+ (UCLSpell*)spellWithIdNum:(long)theIdNum name:(NSString*)theName;

@end
