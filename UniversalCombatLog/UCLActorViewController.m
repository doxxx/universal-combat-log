//
//  UCLActorViewController.m
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-08-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UCLActorViewController.h"

#import "UCLLogEvent.h"

#define PER_SECOND_WINDOW_SIZE 5

@implementation UCLActorViewController
{
    UIPopoverController* _masterPopoverController;
    NSArray* _events;
    NSArray* _spellBreakdownColors;
    NSDictionary* _spellBreakdown;
    NSArray* _sortedSpells;
    NSArray* _sortedSpellValues;
    double _spellBreakdownSum;
    NSRange _range;
}

#pragma mark - View Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.lineChartView.delegate = self;
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
    self.pieChartView = nil;
    self.tableView = nil;
    
    _masterPopoverController = nil;
    _spellBreakdownColors = nil;
    _spellBreakdown = nil;
    _sortedSpells = nil;
    _sortedSpellValues = nil;

    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.lineChartView willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

#pragma mark - Properties

@synthesize actor = _actor;
@synthesize fight = _fight;

@synthesize lineChartView = _lineChartView;
@synthesize pieChartView = _pieChartView;
@synthesize tableView = _tableView;

- (void)setActor:(UCLEntity *)actor fight:(UCLFight *)fight
{
    if (_masterPopoverController != nil) {
        [_masterPopoverController dismissPopoverAnimated:YES];
    }
    
    _actor = actor;
    _fight = fight;
    
    _events = [fight filterEventsUsingPredicate:^BOOL(UCLLogEvent* event) {
        BOOL isActor = [event.actor isEqualToEntity:actor] || [event.target isEqualToEntity:actor];
        return (isActor) && [event isDamage];
    }];
    
    _range = NSMakeRange(0, ceil(_fight.duration));
    
    [self configureView];
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Fights", @"Fights");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    _masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    _masterPopoverController = nil;
}

#pragma mark - Helper Methods

- (void)configureView
{
    [self navigationItem].title = self.actor.name;
    self.lineChartView.data = [self calculatePerSecondValues];
    [self updateSpellBreakdowns];
}

- (void)updateSpellBreakdowns
{
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
    
    self.pieChartView.data = _sortedSpellValues;
    [self.tableView reloadData];
}

- (NSArray *)calculateTotalsOverTime
{
    NSUInteger duration = ceil(self.fight.duration);
    NSDate* start = self.fight.startTime;
    double* data = malloc(sizeof(double)*duration);
    
    for (NSUInteger i = 0; i < duration; i++) {
        data[i] = 0;
    }
    
    for (UCLLogEvent* event in _events) {
        if ([event.actor isEqualToEntity:self.actor]) {
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

- (NSArray *)calculatePerSecondValues
{
    NSArray* totals = [self calculateTotalsOverTime];
    NSUInteger count = [totals count];
    NSMutableArray* result = [NSMutableArray arrayWithCapacity:count];
    
    for (NSUInteger i = 0; i < count; i++) {
        double value = 0;
        NSUInteger windowSize = MIN(PER_SECOND_WINDOW_SIZE, i + 1);
        for (NSInteger j = i - windowSize + 1; j <= i; j++) {
            value += [[totals objectAtIndex:j] doubleValue];
        }
        [result addObject:[NSNumber numberWithDouble:(value / windowSize)]];
    }
    
    return result;
}

- (NSDictionary *)calculateSpellBreakdown
{
    NSMutableDictionary* spellBreakdown = [NSMutableDictionary dictionary];
    
    NSDate* startTime = _fight.startTime;
    
    for (UCLLogEvent* event in _events) {
        NSTimeInterval timeDiff = [event.time timeIntervalSinceDate:startTime];
        if (timeDiff < _range.location || timeDiff >= _range.location + _range.length) {
            continue;
        }
        if ([event.actor isEqualToEntity:self.actor]) {
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

#pragma mark - TableView DataSource & Delegate Methods

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

#pragma mark - PieChartView Delegate Methods

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

#pragma mark - LineChartView Delegate Methods

- (void)lineChartView:(UCLLineChartView *)lineChartView didZoomToRange:(NSRange)range
{
    _range = range;
    [self updateSpellBreakdowns];
}

@end
