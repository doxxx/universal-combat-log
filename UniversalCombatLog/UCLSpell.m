//
//  UCLSpell.m
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-07-19.
//  Copyright (c) 2012 Gordon Tyler. All rights reserved.
//

#import "UCLSpell.h"

@implementation UCLSpell

- (id)initWithIdNum:(uint64_t)idNum name:(NSString*)name
{
    self = [super init];
    if (self) {
        _idNum = idNum;
        _name = name;
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
    return (NSUInteger) (31 ^ _idNum ^ [_name hash]);
}

+ (UCLSpell*)spellWithIdNum:(uint64_t)idNum name:(NSString*)name
{
    return [[UCLSpell alloc] initWithIdNum:idNum name:name];
}


@end
