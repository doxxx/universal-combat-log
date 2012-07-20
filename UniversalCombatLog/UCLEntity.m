//
//  UCLEntity.m
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-07-19.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UCLEntity.h"

@implementation UCLEntity

@synthesize idNum=_idNum, type=_type, relationship=_relationship, owner=_owner, name=_name;

- (id)initWithIdNum:(long)theIdNum type:(enum EntityType)theType 
       relationship:(enum EntityRelationship)theRelationship 
              owner:(UCLEntity*)theOwner name:(NSString*)theName
{
    self = [super init];
    if (self) {
        _idNum = theIdNum;
        _type = theType;
        _relationship = theRelationship;
        _owner = theOwner;
        _name = theName;
    }
    return self;
}

+ (UCLEntity*)entityWithIdNum:(long)theIdNum type:(enum EntityType)theType 
                 relationship:(enum EntityRelationship)theRelationship 
                        owner:(UCLEntity*)theOwner name:(NSString*)theName {
    return [[UCLEntity alloc] initWithIdNum:theIdNum type:theType relationship:theRelationship owner:theOwner 
                                       name:theName];
}


@end
