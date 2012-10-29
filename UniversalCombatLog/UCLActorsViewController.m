//
//  UCLActorsViewController.m
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-08-01.
//  Copyright (c) 2012 Gordon Tyler. All rights reserved.
//

#import "UCLActorsViewController.h"
#import "UCLSummaryTypesViewController.h"
#import "UCLSummaryEntry.h"

@implementation UCLActorsViewController
{
    __weak UIPopoverController* _popoverController;
    __strong NSArray* _summary;
}

#pragma mark - Properties

@synthesize actorViewController = _actorViewController;
@synthesize fight = _fight;
@synthesize summaryType = _summaryType;
@synthesize summaryTypeButton = _summaryTypeButton;

-(void)setFight:(UCLFight *)fight
{
    _fight = fight;
    [self configureView];
}

- (void)setSummaryType:(NSString *)summaryType
{
    if (_popoverController) {
        [_popoverController dismissPopoverAnimated:YES];
    }
    _summaryType = summaryType;
    self.summaryTypeButton.title = summaryType;
    [self configureView];
}

#pragma mark - View methods

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Set default summary type, which then configures the view.
    self.summaryType = @"DPS";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.summaryTypeButton = nil;
    self.fight = nil;

    _summary = nil;
    _popoverController = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (_popoverController) {
        [_popoverController dismissPopoverAnimated:YES];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

# pragma mark - Private methods

-(void)configureView
{
    if (self.fight != nil) {
        UCLLogEventPredicate predicate = NULL;
        if ([self.summaryType isEqualToString:@"DPS"]) {
            predicate = ^BOOL(UCLLogEvent* event) {
                return event.actor != nil && event.actor.type == Player && [event isDamage];
            };
        }
        else if ([self.summaryType isEqualToString:@"HPS"]) {
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
    NSMutableDictionary* temp = [NSMutableDictionary dictionary];
    
    for (UCLLogEvent* event in _fight.events) {
        if (predicate != NULL && predicate(event)) {
            NSNumber* amount = [temp objectForKey:event.actor];
            if (amount == nil) {
                amount = event.amount;
            }
            else {
                amount = [NSNumber numberWithLong:([amount longValue] + [event.amount longValue])];
            }
            [temp setObject:amount forKey:event.actor];
        }
    }
    
    for (id item in [temp allKeys]) {
        double value = ([[temp objectForKey:item] doubleValue] / self.fight.duration);
        [temp setObject:[NSNumber numberWithLong:value] forKey:item];
    }
    
    NSArray* sortedItems = [temp keysSortedByValueUsingComparator:^(NSNumber* val1, NSNumber* val2) {
        if ([val1 longValue] > [val2 longValue]) {
            return NSOrderedAscending;
        }
        if ([val1 longValue] < [val2 longValue]) {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
    
    NSMutableArray* result = [NSMutableArray arrayWithCapacity:[temp count]];
    for (id item in sortedItems) {
        [result addObject:[[UCLSummaryEntry alloc] initWithItem:item amount:[temp objectForKey:item]]];
    }
    
    return [NSArray arrayWithArray:result];
    
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_summary count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ActorCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    UCLSummaryEntry* summaryEntry = [_summary objectAtIndex:indexPath.row];
    UCLEntity* actor = summaryEntry.item;
    cell.textLabel.text = actor.name;
    cell.detailTextLabel.text = [summaryEntry.amount stringValue];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UCLSummaryEntry* summaryEntry = [_summary objectAtIndex:indexPath.row];
    UCLEntity* actor = summaryEntry.item;
    [self.actorViewController setActor:actor fight:self.fight];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SummaryTypes"]) {
        _popoverController = [(UIStoryboardPopoverSegue*)segue popoverController];
        UCLSummaryTypesViewController* vc = [segue destinationViewController];
        vc.actorsViewController = self;
    }
}

#pragma mark - Actions

- (IBAction)showSummaryTypes:(id)sender {
    if (_popoverController) {
        [_popoverController dismissPopoverAnimated:YES];
    }
    else {
        [self performSegueWithIdentifier:@"SummaryTypes" sender:sender];
    }
}


@end
