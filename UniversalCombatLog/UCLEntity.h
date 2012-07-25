//
//  UCLEntity.h
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-07-19.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

enum EntityType {
    Nobody = 0,
    Player = 1,
    NonPlayer = 2
};

enum EntityRelationship {
    NoRelation = 0,
    Self = 1,
    Group = 2,
    Raid = 3,
    Other = 4
};

@interface UCLEntity : NSObject

@property (readonly, nonatomic) uint64_t idNum;
@property (readonly, nonatomic) enum EntityType type;
@property (readonly, nonatomic) enum EntityRelationship relationship;
@property (readonly, weak, nonatomic) UCLEntity* owner;
@property (readonly, strong, nonatomic) NSString* name;

- (id)initWithIdNum:(uint64_t)theIdNum type:(enum EntityType)theType 
       relationship:(enum EntityRelationship)theRelationship 
              owner:(UCLEntity*)theOwner name:(NSString*)theName;

+ (UCLEntity*)entityWithIdNum:(uint64_t)theIdNum type:(enum EntityType)theType 
                 relationship:(enum EntityRelationship)theRelationship 
                        owner:(UCLEntity*)theOwner name:(NSString*)theName;

@end
