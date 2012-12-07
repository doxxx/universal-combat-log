//
//  UCLActorsViewController.m
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-08-01.
//  Copyright (c) 2012 Gordon Tyler. All rights reserved.
//

#import "UCLActorsViewController.h"
#import "UCLSummaryTypesViewController.h"
#import "UCLFight+Filtering.h"
#import "UCLFight+Summarizing.h"

#pragma mark - UCLSummaryEntry

@interface UCLSummaryEntry : NSObject <NSCopying>

@property (readonly, nonatomic) id item;
@property (readonly, nonatomic) NSNumber* amount;

- (id)initWithItem:(id)item amount:(NSNumber*)amount;

- (BOOL)isEqualToSummaryEntry:(UCLSummaryEntry*)summaryEntry;

@end

@implementation UCLSummaryEntry

@synthesize item=_item, amount=_amount;

- (id)initWithItem:(id)item amount:(NSNumber*)amount
{
    self = [super init];
    if (self) {
        _item = item;
        _amount = amount;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if ([object class] != [self class]) {
        return NO;
    }
    return [self isEqualToSummaryEntry:object];
}

- (BOOL)isEqualToSummaryEntry:(UCLSummaryEntry*)summaryEntry
{
    return [self.item isEqual:summaryEntry.item] && [self.amount isEqualToNumber:summaryEntry.amount];
}

- (id)copyWithZone:(NSZone *)zone
{
    // Immutable class, can return original instead of copying.
    return self;
}

- (NSUInteger)hash
{
    return 31 ^ [self.item hash] ^ [self.amount hash];
}

@end



#pragma mark - UCLActorsViewController

@implementation UCLActorsViewController
{
    NSArray* _summary;
}

#pragma mark - Properties

@synthesize fight = _fight;
@synthesize summaryType = _summaryType;
@synthesize delegate;
@synthesize selectedActor;

-(void)setFight:(UCLFight *)fight
{
    _fight = fight;
    self.selectedActor = nil;
    [self configureView];
}

- (void)setSummaryType:(UCLSummaryType)summaryType
{
    _summaryType = summaryType;
    [self configureView];
}

- (void)setFight:(UCLFight *)fight summaryType:(UCLSummaryType)summaryType
{
    _fight = fight;
    _summaryType = summaryType;
    self.selectedActor = nil;
    [self configureView];
}

#pragma mark - View methods

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.clearsSelectionOnViewWillAppear = NO;
    self.summaryType = 0;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.fight = nil;
    self.selectedActor = nil;

    _summary = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.selectedActor) {
        NSUInteger index = [_summary indexOfObjectPassingTest:^(UCLSummaryEntry* obj, NSUInteger idx, BOOL* stop) {
            return [[obj item] isEqualToEntity:self.selectedActor];
        }];
        if (index == NSNotFound) {
            return;
        }
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] 
                                    animated:YES 
                              scrollPosition:UITableViewScrollPositionMiddle];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

# pragma mark - Private methods

-(void)configureView
{
    if (self.fight != nil) {
        UCLLogEventPredicate predicate = nil;
        if (self.summaryType == UCLSummaryDPS) {
            predicate = ^BOOL(UCLLogEvent* event) {
                return event.actor != nil && event.actor.type == Player && [event isDamage];
            };
        }
        else if (self.summaryType == UCLSummaryHPS) {
            predicate = ^BOOL(UCLLogEvent* event) {
                return event.actor != nil && event.actor.type == Player && [event isHealing];
            };
        }
        _summary = [self summarizeActorsUsingPredicate:predicate];
    }
    else {
        _summary = nil;
    }
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (NSArray*)summarizeActorsUsingPredicate:(UCLLogEventPredicate)predicate
{
    NSDictionary* amounts = [_fight sumAmountsPerActorWithPredicate:predicate];
    
    NSArray* sortedActors = [amounts keysSortedByValueUsingComparator:^(NSNumber* val1, NSNumber* val2) {
        if ([val1 longValue] > [val2 longValue]) {
            return NSOrderedAscending;
        }
        if ([val1 longValue] < [val2 longValue]) {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
    
    NSMutableArray* result = [NSMutableArray arrayWithCapacity:[amounts count]];
    for (UCLEntity* actor in sortedActors) {
        NSNumber* amountPerSecond = [NSNumber numberWithInt:round([[amounts objectForKey:actor] doubleValue] / _fight.duration)];
        [result addObject:[[UCLSummaryEntry alloc] initWithItem:actor amount:amountPerSecond]];
    }
    
    return [NSArray arrayWithArray:result];
    
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_summary count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"ActorCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    UCLSummaryEntry* summaryEntry = [_summary objectAtIndex:indexPath.row];
    UCLEntity* actor = summaryEntry.item;
    cell.textLabel.text = actor.name;
    cell.detailTextLabel.text = summaryEntry.amount.stringValue;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UCLSummaryEntry* summaryEntry = [_summary objectAtIndex:indexPath.row];
    self.selectedActor = summaryEntry.item;
    [self.delegate actorsView:self didSelectActor:self.selectedActor];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UCLSummaryEntry* summaryEntry = [_summary objectAtIndex:indexPath.row];
    [self.delegate actorsView:self didDeselectActor:summaryEntry.item];
}

@end
