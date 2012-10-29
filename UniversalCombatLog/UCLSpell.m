//
//  UCLSpell.m
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-07-19.
//  Copyright (c) 2012 Gordon Tyler. All rights reserved.
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

- (BOOL)isEqual:(id)object
{
    if ([object class] != [self class]) {
        return NO;
    }
    return [self isEqualToSpell:object];
}

- (BOOL)isEqualToSpell:(UCLSpell *)spell
{
    return self.idNum == spell.idNum;
}

- (id)copyWithZone:(NSZone *)zone
{
    // Immutable class, can return original instead of copying.
    return self;
}

- (NSUInteger)hash
{
    return 31 ^ _idNum ^ [_name hash];
}

+ (UCLSpell*)spellWithIdNum:(uint64_t)theIdNum name:(NSString*)theName
{
    return [[UCLSpell alloc] initWithIdNum:theIdNum name:theName];
}


@end
