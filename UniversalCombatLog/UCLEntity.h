//
//  UCLEntity.h
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-07-19.
//  Copyright (c) 2012 Gordon Tyler. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    Nobody = 0,
    Player = 1,
    NonPlayer = 2
} EntityType ;

typedef enum {
    NoRelation = 0,
    Self = 1,
    Group = 2,
    Raid = 3,
    Other = 4
} EntityRelationship;

@interface UCLEntity : NSObject <NSCopying>

@property (readonly, nonatomic) uint64_t idNum;
@property (readonly, nonatomic) EntityType type;
@property (readonly, nonatomic) EntityRelationship relationship;
@property (readonly, weak, nonatomic) UCLEntity* owner;
@property (readonly, strong, nonatomic) NSString* name;

- (id)initWithIdNum:(uint64_t)idNum type:(EntityType)type
       relationship:(EntityRelationship)relationship
              owner:(UCLEntity*)owner name:(NSString*)name;

- (BOOL)isEqualToEntity:(UCLEntity*)entity;

- (BOOL)isPlayerOrPet;

+ (UCLEntity*)entityWithIdNum:(uint64_t)idNum type:(EntityType)type
                 relationship:(EntityRelationship)relationship
                        owner:(UCLEntity*)owner name:(NSString*)name;

@end
