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

#define CHECK_LENGTH(l) \
    if (_cursor - _data + l > _length) { \
        NSString* reason = [NSString stringWithFormat:@"Cannot read %u bytes at position %u", l, (_cursor - _data)]; \
        @throw [NSException exceptionWithName:NSRangeException reason:reason userInfo:nil]; \
    }

@implementation UCLLogFileLoader
{
    const void* _data;
    NSUInteger _length;
    void* _cursor;
}

- (id)initWithData:(NSData*)data
{
    self = [super init];
    if (self) {
        _data = [data bytes];
        _length = [data length];
        _cursor = (void *)_data;
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

        EntityType type;
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
        
        EntityRelationship rel;
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

        uint64_t ownerIDNum = [self readUInt64];
        UCLEntity* owner = [entityIndex objectForKey:@(ownerIDNum)];
        NSString* name = [self readUTF8asNSString];
        
        UCLEntity* entity = [UCLEntity entityWithIdNum:idNum type:type relationship:rel owner:owner name:name];
        [entityIndex setObject:entity forKey:@(idNum)];
        
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
        NSString* name = [self readUTF8asNSString];
        
        UCLSpell* spell = [UCLSpell spellWithIdNum:idNum name:name];
        [spellIndex setObject:spell forKey:@(idNum)];
        
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
        NSString* title = [self readUTF8asNSString];
                
        uint32_t eventCount = [self readUInt32];
        UCLLogEvent* events = malloc(eventCount * sizeof(UCLLogEvent));
        UCLLogEvent* event = events;

        for (uint32_t i = 0; i < eventCount; i++, event++) {
            event->time = [self readUInt64];
            event->eventType = [self readUInt8];
            event->actorID = [self readUInt64];
            event->targetID = [self readUInt64];
            event->spellID = [self readUInt64];
            event->amount = [self readUInt64];
            event->text = [self readUTF8];
        }

        [fights addObject:[UCLFight fightWithEvents:events count:eventCount title:title entityIndex:entityIndex spellIndex:spellIndex]];
        
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

- (NSString*)readUTF8asNSString
{
    uint16_t length = [self readUInt16];
    
    CHECK_LENGTH(length)
    
    NSString* string = [[NSString alloc] initWithBytes:_cursor length:length encoding:NSUTF8StringEncoding];
    _cursor += length;
    return string;
}

- (char*)readUTF8
{
    uint16_t length = [self readUInt16];

    CHECK_LENGTH(length)

    char* s = malloc(length+1);
    strlcpy(s, _cursor, length+1);
    _cursor += length;
    return s;
}

+ (UCLLogFile *)loadFromData:(NSData *)data
{
    return [[[UCLLogFileLoader alloc] initWithData:data] load];
}

@end
