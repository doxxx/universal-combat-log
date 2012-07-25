//
//  UCLSpell.m
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-07-19.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UCLSpell.h"

@implementation UCLSpell

@synthesize idNum=_idNum, name=_name;

- (id)initWithIdNum:(uint64_t)theIdNum name:(NSString*)theName
{
    self = [super init];
    if (self) {
        _idNum = theIdNum;
        _name = theName;
    }
    return self;
}

+ (UCLSpell*)spellWithIdNum:(uint64_t)theIdNum name:(NSString*)theName
{
    return [[UCLSpell alloc] initWithIdNum:theIdNum name:theName];
}


@end
