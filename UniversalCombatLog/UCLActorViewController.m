//
//  UCLActorViewController.m
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-08-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UCLActorViewController.h"

#import "UCLLogEvent.h"

#define DPS_WINDOW_SIZE 5

@interface UCLActorViewController ()

@property (strong, nonatomic) UIPopoverController *masterPopoverController;

- (void)configureView;
- (NSArray*)calculateDamage;
- (NSArray*)calculateDPS;
- (NSDictionary*)calculateSpellBreakdown;

@end

@implementation UCLActorViewController
{
    NSArray* _spellBreakdownColors;
    NSDictionary* _spellBreakdown;
    NSArray* _sortedSpells;
    NSArray* _sortedSpellValues;
    double _spellBreakdownSum;
}

@synthesize actor = _actor;
@synthesize fight = _fight;

@synthesize lineChartView = _lineChartView;
@synthesize pieChartView = _pieChartView;
@synthesize tableView = _tableView;

@synthesize masterPopoverController = _masterPopoverController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.pieChartView.delegate = self;
    
    NSMutableArray* colors = [NSMutableArray arrayWithCapacity:[_sortedSpells count]];
    [colors addObjectsFromArray:[NSArray arrayWithObjects:
                                        [UIColor colorWithRed:1 green:0 blue:0 alpha:1], 
                                        [UIColor colorWithRed:1 green:0.5 blue:0 alpha:1], 
                                        [UIColor colorWithRed:1 green:1 blue:0 alpha:1], 
                                        [UIColor colorWithRed:0.5 green:1 blue:0 alpha:1], 
                                        [UIColor colorWithRed:1 green:0 blue:0.5 alpha:1], 
                                        [UIColor colorWithRed:1 green:61.0/255.0 blue:61.0/255.0 alpha:1], 
                                        [UIColor colorWithRed:1 green:122.0/255.0 blue:122.0/255.0 alpha:1], 
                                        [UIColor colorWithRed:0 green:1 blue:0 alpha:1], 
                                        [UIColor colorWithRed:1 green:0 blue:1 alpha:1], 
                                        [UIColor colorWithRed:122.0/255.0 green:1 blue:1 alpha:1],
                                        [UIColor colorWithRed:61.0/255.0 green:1 blue:1 alpha:1],
                                        [UIColor colorWithRed:0 green:1 blue:0.5 alpha:1],
                                        [UIColor colorWithRed:0.5 green:0 blue:1 alpha:1],
                                        [UIColor colorWithRed:0 green:0 blue:1 alpha:1],
                                        [UIColor colorWithRed:0 green:0.5 blue:1 alpha:1],
                                        [UIColor colorWithRed:0 green:1 blue:1 alpha:1],
                                        [UIColor colorWithRed:1 green:1 blue:61.0/255.0 alpha:1],
                                        [UIColor colorWithRed:1 green:1 blue:122.0/255.0 alpha:1],
                                        [UIColor colorWithRed:1 green:122.0/255.0 blue:61.0/255.0 alpha:1],
                                        [UIColor colorWithRed:61.0/255.0 green:61.0/255.0 blue:1 alpha:1],
                                        nil]];
    
    _spellBreakdownColors = [NSArray arrayWithArray:colors];
}

- (void)viewDidUnload
{
    self.lineChartView = nil;

    [self setPieChartView:nil];
    [self setTableView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)setActor:(UCLEntity *)actor fight:(UCLFight *)fight
{
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
    
    _actor = actor;
    _fight = fight;
    
    _spellBreakdown = [self calculateSpellBreakdown];
    _sortedSpells = [_spellBreakdown keysSortedByValueUsingComparator:^(NSNumber* amount1, NSNumber* amount2) {
        return [amount2 compare:amount1];
    }];
    
    NSMutableArray* sortedSpellValues = [NSMutableArray arrayWithCapacity:[_sortedSpells count]];
    for (UCLSpell* spell in _sortedSpells) {
        [sortedSpellValues addObject:[_spellBreakdown objectForKey:spell]];
    }
    _sortedSpellValues = [NSArray arrayWithArray:sortedSpellValues];
    
    double sum = 0;
    for (NSNumber* value in [_spellBreakdown allValues]) {
        sum += [value doubleValue];
    }
    _spellBreakdownSum = sum;

    [self configureView];
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Fights", @"Fights");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

- (void)configureView
{
    [self navigationItem].title = self.actor.name;
    
    self.lineChartView.data = [self calculateDPS];
    
    self.pieChartView.data = _sortedSpellValues;
    [self.tableView reloadData];
}

- (NSArray *)calculateDamage
{
    NSArray* events = [self.fight allEventsForEntity:self.actor];
    NSUInteger duration = ceil(self.fight.duration);
    NSDate* start = self.fight.startTime;
    double* data = malloc(sizeof(double)*duration);
    
    for (NSUInteger i = 0; i < duration; i++) {
        data[i] = 0;
    }
    
    for (UCLLogEvent* event in events) {
        if ([event isDamage] && [event.actor isEqualToEntity:self.actor]) {
            uint32_t index = floor([event.time timeIntervalSinceDate:start]);
            data[index] = data[index] + [event.amount doubleValue];
        }
    }
    
    NSMutableArray* numbers = [NSMutableArray arrayWithCapacity:duration];
    for (NSUInteger i = 0; i < duration; i++) {
        [numbers addObject:[NSNumber numberWithDouble:data[i]]];
    }
    
    free(data);
    
    return numbers;
}

- (NSArray *)calculateDPS
{
    NSArray* damage = [self calculateDamage];
    NSUInteger duration = [damage count];
    NSMutableArray* dps = [NSMutableArray arrayWithCapacity:duration];
    
    for (NSUInteger i = 0; i < duration; i++) {
        double value = 0;
        NSUInteger windowSize = MIN(DPS_WINDOW_SIZE, i + 1);
        for (NSInteger j = i - windowSize + 1; j <= i; j++) {
            value += [[damage objectAtIndex:j] doubleValue];
        }
        [dps addObject:[NSNumber numberWithDouble:(value / windowSize)]];
    }
    
    return dps;
}

- (NSDictionary *)calculateSpellBreakdown
{
    NSMutableDictionary* spellBreakdown = [NSMutableDictionary dictionary];
    
    NSArray* events = [self.fight allEventsForEntity:self.actor];
    for (UCLLogEvent* event in events) {
        if ([event isDamage] && [event.actor isEqualToEntity:self.actor]) {
            NSNumber* amount = [spellBreakdown objectForKey:event.spell];
            if (amount == nil) {
                [spellBreakdown setObject:event.amount forKey:event.spell];
            }
            else {
                long newAmount = [event.amount longValue] + [amount longValue];
                [spellBreakdown setObject:[NSNumber numberWithLong:newAmount] forKey:event.spell];
            }
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:spellBreakdown];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_spellBreakdown != nil) {
        return [_spellBreakdown count];
    }
    else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    UCLSpell* spell = [_sortedSpells objectAtIndex:indexPath.row];
    NSNumber* value = [_spellBreakdown objectForKey:spell];
    cell.textLabel.text = spell.name;
    cell.textLabel.textColor = [_spellBreakdownColors objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f%%", 
                                 ([value doubleValue] / _spellBreakdownSum * 100)];
    cell.detailTextLabel.textColor = [_spellBreakdownColors objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.pieChartView selectSegment:indexPath.row];
}

- (void)pieChartView:(UCLPieChartView *)pieChartView didSelectSegmentAtIndex:(NSUInteger)segmentIndex
{
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:segmentIndex inSection:0]
                                animated:TRUE scrollPosition:UITableViewScrollPositionMiddle];
}

- (UIColor *)pieChartView:(UCLPieChartView *)pieChartView colorForSegment:(NSUInteger)segmentIndex
{
    if (segmentIndex >= [_spellBreakdownColors count]) {
        return [UIColor whiteColor];
    }
    return [_spellBreakdownColors objectAtIndex:segmentIndex];
}

@end
