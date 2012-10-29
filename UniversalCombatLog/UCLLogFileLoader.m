//
//  UCLLogFileLoader.m
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-07-23.
//  Copyright (c) 2012 Gordon Tyler. All rights reserved.
//

#import "UCLLogFileLoader.h"
#import "UCLEntity.h"
#import "UCLSpell.h"
#import "UCLFight.h"
#import "UCLLogEvent.h"

#define CHECK_LENGTH(l) \
    if (_cursor - _data + l > _length) { \
        NSString* reason = [NSString stringWithFormat:@"Cannot read %u bytes at position %u", l, (_cursor - _data)]; \
        @throw [NSException exceptionWithName:NSRangeException reason:reason userInfo:nil]; \
    }

@implementation UCLLogFileLoader
{
    const void* _data;
    NSUInteger _length;
    const void* _cursor;
}

- (id)initWithData:(NSData*)data
{
    self = [super init];
    if (self) {
        _data = [data bytes];
        _length = [data length];
        _cursor = _data;
    }
    return self;
}

- (UCLLogFile*)load
{
    if ([self readUInt32] != 'UCL1') {
        @throw [NSException exceptionWithName:@"UCLInvalidFileMarkerException" 
                                       reason:@"expected file marker 'UCL1'" 
                                     userInfo:nil];
    }
    
    NSMutableDictionary* entityIndex = NULL;
    NSMutableDictionary* spellIndex = NULL;
    NSMutableArray* fights = NULL;

    if ([self readUInt32] != 'ENT1') {
        @throw [NSException exceptionWithName:@"UCLInvalidSectionMarkerException" 
                                       reason:@"excepted section marker 'ENT1'" 
                                     userInfo:nil];
    }
    
    uint32_t entityCount = [self readUInt32];
    entityIndex = [NSMutableDictionary dictionaryWithCapacity:entityCount];
    
    while (entityCount > 0) {
        uint64_t idNum = [self readUInt64];

        enum EntityType type;
        switch ([self readUInt8]) {
            case 'P':
                type = Player;
                break;
                
            case 'N':
                type = NonPlayer;
                break;
                
            default:
                type = Nobody;
                break;
        }
        
        enum EntityRelationship rel;
        switch ([self readUInt8]) {
            case 'C':
                rel = Self;
                break;
                
            case 'G':
                rel = Group;
                break;
                
            case 'R':
                rel = Raid;
                break;
                
            case 'O':
                rel = Other;
                break;
                
            default:
                rel = NoRelation;
                break;
        }
        
        UCLEntity* owner = [entityIndex objectForKey:[NSNumber numberWithLongLong:[self readUInt64]]];
        NSString* name = [self readUTF8];
        
        UCLEntity* entity = [UCLEntity entityWithIdNum:idNum type:type relationship:rel owner:owner name:name];
        [entityIndex setObject:entity forKey:[NSNumber numberWithLongLong:idNum]];
        
        entityCount--;
    }
    
    if ([self readUInt32] != 'SPL1') {
        @throw [NSException exceptionWithName:@"UCLInvalidSectionMarkerException" 
                                       reason:@"excepted section marker 'SPL1'" 
                                     userInfo:nil];
    }
    
    uint32_t spellCount = [self readUInt32];
    spellIndex = [NSMutableDictionary dictionaryWithCapacity:spellCount];
    
    while (spellCount > 0) {
        uint64_t idNum = [self readUInt64];
        NSString* name = [self readUTF8];
        
        UCLSpell* spell = [UCLSpell spellWithIdNum:idNum name:name];
        [spellIndex setObject:spell forKey:[NSNumber numberWithLongLong:idNum]];
        
        spellCount--;
    }
    
    if ([self readUInt32] != 'FIT1') {
        @throw [NSException exceptionWithName:@"UCLInvalidSectionMarkerException" 
                                       reason:@"excepted section marker 'FIT1'" 
                                     userInfo:nil];
    }
    
    uint32_t fightCount = [self readUInt32];
    fights = [NSMutableArray arrayWithCapacity:fightCount];
    
    while (fightCount > 0) {
        NSString* name = [self readUTF8];
                
        uint32_t eventCount = [self readUInt32];
        NSMutableArray* events = [NSMutableArray arrayWithCapacity:eventCount];
        
        while (eventCount > 0) {
            NSDate* time = [NSDate dateWithTimeIntervalSince1970:([self readUInt64] / 1000.0)];
            enum EventType type = [self readUInt8];
            UCLEntity* actor = [entityIndex objectForKey:[NSNumber numberWithLongLong:[self readUInt64]]];
            UCLEntity* target = [entityIndex objectForKey:[NSNumber numberWithLongLong:[self readUInt64]]];
            UCLSpell* spell = [spellIndex objectForKey:[NSNumber numberWithLongLong:[self readUInt64]]];
            uint64_t amount = [self readUInt64];
            NSString* text = [self readUTF8];

            [events addObject:[UCLLogEvent logEventWithTime:time eventType:type actor:actor target:target 
                                                      spell:spell amount:[NSNumber numberWithLongLong:amount] 
                                                       text:text]];
            
            eventCount--;
        }
        
        [fights addObject:[UCLFight fightWithEvents:events title:name]];
        
        fightCount--;
    }
    
    return [UCLLogFile logFileWithFights:fights];
}

#pragma mark - Private methods

- (uint8_t)readUInt8
{
    CHECK_LENGTH(1)
    uint8_t value = *((uint8_t*)_cursor);
    _cursor++;
    return value;
}

- (uint16_t)readUInt16
{
    CHECK_LENGTH(2)
    uint16_t value = NSSwapBigShortToHost(*((uint16_t*)_cursor));
    _cursor += 2;
    return value;
}

- (uint32_t)readUInt32
{
    CHECK_LENGTH(4)
    uint32_t value = NSSwapBigIntToHost(*((uint32_t*)_cursor));
    _cursor += 4;
    return value;
}

- (uint64_t)readUInt64
{
    CHECK_LENGTH(8)
    uint64_t value = NSSwapBigLongLongToHost(*((uint64_t*)_cursor));
    _cursor += 8;
    return value;
}

- (NSString*)readUTF8
{
    uint16_t length = [self readUInt16];
    
    CHECK_LENGTH(length)
    
    NSString* string = [[NSString alloc] initWithBytes:_cursor length:length encoding:NSUTF8StringEncoding];
    _cursor += length;
    return string;
}

+ (UCLLogFile *)loadFromData:(NSData *)data
{
    return [[[UCLLogFileLoader alloc] initWithData:data] load];
}

@end
