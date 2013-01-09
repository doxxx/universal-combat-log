//
//  UCLEntity.m
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-07-19.
//  Copyright (c) 2012 Gordon Tyler. All rights reserved.
//

#import "UCLEntity.h"

@implementation UCLEntity

- (id)initWithIdNum:(uint64_t)idNum type:(EntityType)type
       relationship:(EntityRelationship)relationship
              owner:(UCLEntity*)owner name:(NSString*)name
{
    self = [super init];
    if (self) {
        _idNum = idNum;
        _type = type;
        _relationship = relationship;
        _owner = owner;
        _name = name;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if ([object class] != [self class]) {
        return NO;
    }
    return [self isEqualToEntity:object];
}

- (BOOL)isEqualToEntity:(UCLEntity*)entity
{
    return _idNum == entity.idNum;
}

- (BOOL)isPlayerOrPet
{
    return _type == Player || (_type == NonPlayer && _owner != nil && _owner.type == Player);
}

- (id)copyWithZone:(NSZone *)zone
{
    // Immutable class, can return original instead of copying.
    return self;
}

- (NSUInteger)hash
{
    return 31 ^ _idNum ^ _type ^ _relationship ^ [_owner hash] ^ [_name hash];
}

+ (UCLEntity*)entityWithIdNum:(uint64_t)idNum type:(EntityType)type
                 relationship:(EntityRelationship)relationship
                        owner:(UCLEntity*)owner name:(NSString*)name
{
    return [[UCLEntity alloc] initWithIdNum:idNum type:type relationship:relationship owner:owner
                                       name:name];
}


@end
