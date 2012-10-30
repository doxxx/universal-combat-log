//
//  UCLActorViewController.m
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-08-03.
//  Copyright (c) 2012 Gordon Tyler. All rights reserved.
//

#import "UCLActorViewController.h"

#import "UCLLogEvent.h"

#define PER_SECOND_WINDOW_SIZE 5

@implementation UCLActorViewController
{
    UIPopoverController* _masterPopoverController;
    NSArray* _pieChartColors;
    NSArray* _events;
    NSDictionary* _spellBreakdown;
    NSArray* _sortedSpells;
    NSArray* _sortedSpellValues;
    NSDictionary* _spellColors;
    double _spellBreakdownSum;
    NSRange _range;
}

#pragma mark - View Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.lineChartView.delegate = self;
    self.pieChartView.delegate = self;
    
    CGRect detailFrame = self.detailView.frame;
    detailFrame.size = self.tableView.frame.size;
    detailFrame.origin.x = self.view.frame.size.width;
    detailFrame.origin.y = self.tableView.frame.origin.y;
    self.detailView.frame = detailFrame;

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
    
    _pieChartColors = [NSArray arrayWithArray:colors];
}

- (void)viewDidUnload
{
    self.lineChartView = nil;
    self.pieChartView = nil;
    self.tableView = nil;
    self.detailView = nil;
    self.hitPercentLabel = nil;
    self.critPercentLabel = nil;
    self.minDamageLabel = nil;
    self.maxDamageLabel = nil;
    self.avgDamageLabel = nil;
    
    _masterPopoverController = nil;
    _pieChartColors = nil;
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
    CGRect detailFrame = self.detailView.frame;
    detailFrame.size = self.tableView.frame.size;
    if (self.pieChartView.frame.origin.x < 0) {
        CGFloat slideDistance = self.view.bounds.size.width / 2;
        detailFrame.origin.x = self.tableView.frame.origin.x + slideDistance;
        detailFrame.origin.y = self.tableView.frame.origin.y;
    }
    else {
        detailFrame.origin.x = self.view.frame.size.width;
        detailFrame.origin.y = self.tableView.frame.origin.y;
    }
    self.detailView.frame = detailFrame;
}

#pragma mark - Properties

@synthesize actor = _actor;
@synthesize fight = _fight;

@synthesize lineChartView = _lineChartView;
@synthesize pieChartView = _pieChartView;
@synthesize tableView = _tableView;
@synthesize detailView = _detailView;
@synthesize hitPercentLabel = _hitPercentLabel;
@synthesize critPercentLabel = _critPercentLabel;
@synthesize minDamageLabel = _minDamageLabel;
@synthesize maxDamageLabel = _maxDamageLabel;
@synthesize avgDamageLabel = _avgDamageLabel;

- (void)setActor:(UCLEntity *)actor fight:(UCLFight *)fight
{
    if (_actor != nil) {
        [self.lineChartView removeDataForKey:_actor.name];
    }
    
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
    
    [self navigationItem].title = actor.name;
    [self.lineChartView addData:[self calculatePerSecondValues] forKey:actor.name];
    [self updateSpellBreakdownsNewData:YES];
    self.detailView.hidden = YES;
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Logs", @"Logs");
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

- (void)updateSpellBreakdownsNewData:(BOOL)newData
{
    UCLSpell* selectedSpell = nil;
    NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
    if (indexPath != nil) {
        selectedSpell = [_sortedSpells objectAtIndex:indexPath.row];
    }
    
    _spellBreakdown = [self calculateSpellBreakdown];
    
    _sortedSpells = [_spellBreakdown keysSortedByValueUsingComparator:^(NSNumber* amount1, NSNumber* amount2) {
        return [amount2 compare:amount1];
    }];
    
    if (newData) {
        NSMutableDictionary* spellColors = [NSMutableDictionary dictionaryWithCapacity:[_sortedSpells count]];
        NSUInteger colorIndex = 0;
        for (UCLSpell* spell in _sortedSpells) {
            UIColor* color = [UIColor whiteColor];
            if (colorIndex < [_pieChartColors count]) {
                color = [_pieChartColors objectAtIndex:colorIndex];
            }
            [spellColors setObject:color forKey:spell];
            colorIndex++;
        }
        _spellColors = [NSDictionary dictionaryWithDictionary:spellColors];
    }
    
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
    
    if (!newData && selectedSpell != nil) {
        NSUInteger selectedRow = [_sortedSpells indexOfObject:selectedSpell];
        [self.pieChartView selectSegment:selectedRow];
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:0] 
                                    animated:NO 
                              scrollPosition:UITableViewScrollPositionNone];
    }
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

- (void)updateDetailView
{
    NSIndexPath* indexPath = [_tableView indexPathForSelectedRow];
    if (indexPath == nil) {
        self.detailView.hidden = YES;
        return;
    }
    
    UCLSpell* spell = [_sortedSpells objectAtIndex:indexPath.row];
    
    NSUInteger attackCount = 0, hitCount = 0, critCount = 0;
    double min = NSUIntegerMax, max = 0, total = 0, average = 0;
    
    NSDate* startTime = _fight.startTime;

    for (UCLLogEvent* event in _events) {
        NSTimeInterval timeDiff = [event.time timeIntervalSinceDate:startTime];
        if (timeDiff < _range.location || timeDiff >= _range.location + _range.length) {
            continue;
        }
        if ([event.actor isEqualToEntity:self.actor] && [event.spell isEqualToSpell:spell]) {
            attackCount++;
            if (![event isMiss]) {
                hitCount++;
                if ([event isCrit]) {
                    critCount++;
                }
                double amount = [event.amount doubleValue];
                min = MIN(min, amount);
                max = MAX(max, amount);
                total += amount;
            }
        }
    }
    
    average = total / hitCount;
    
    self.hitPercentLabel.text = [NSString stringWithFormat:@"%.1f%%", (float)hitCount / (float)attackCount * 100.0];
    self.critPercentLabel.text = [NSString stringWithFormat:@"%.1f%%", (float)critCount / (float)hitCount * 100.0];
    self.minDamageLabel.text = [NSString stringWithFormat:@"%.0f", min];
    self.maxDamageLabel.text = [NSString stringWithFormat:@"%.0f", max];
    self.avgDamageLabel.text = [NSString stringWithFormat:@"%.0f", average];

    self.detailView.hidden = NO;
}

#pragma mark - TableView DataSource & Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_spellBreakdown != nil) {
        return [_spellBreakdown count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    UCLSpell* spell = [_sortedSpells objectAtIndex:indexPath.row];
    NSNumber* value = [_spellBreakdown objectForKey:spell];
    cell.textLabel.text = spell.name;
    cell.textLabel.textColor = [_spellColors objectForKey:spell];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f%%", 
                                 ([value doubleValue] / _spellBreakdownSum * 100)];
    cell.detailTextLabel.textColor = [_pieChartColors objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.pieChartView selectSegment:indexPath.row];
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    [self updateDetailView];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self swipeLeft:nil];
}

#pragma mark - PieChartView Delegate Methods

- (void)pieChartView:(UCLPieChartView *)pieChartView didSelectSegmentAtIndex:(NSUInteger)segmentIndex
{
    [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]].accessoryType = UITableViewCellAccessoryNone;
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:segmentIndex inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath
                                animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    [self.tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    [self updateDetailView];
}

- (UIColor *)pieChartView:(UCLPieChartView *)pieChartView colorForSegment:(NSUInteger)segmentIndex
{
    UCLSpell* spell = [_sortedSpells objectAtIndex:segmentIndex];
    return [_spellColors objectForKey:spell];
}

#pragma mark - LineChartView Delegate Methods

- (void)lineChartView:(UCLLineChartView *)lineChartView didZoomToRange:(NSRange)range
{
    _range = range;
    [self updateSpellBreakdownsNewData:NO];
    [self updateDetailView];
}

#pragma mark - Gesture Methods

- (IBAction)swipeLeft:(UISwipeGestureRecognizer *)sender {
    if (self.pieChartView.frame.origin.x < 0) {
        return;
    }
    
    CGFloat slideDistance = self.view.bounds.size.width / 2;
    
    [UIView animateWithDuration:0.5 
                          delay:0 
                        options:UIViewAnimationOptionCurveEaseOut 
                     animations:^{
                         CGRect newPieChartFrame = self.pieChartView.frame;
                         newPieChartFrame.origin.x -= slideDistance;
                         
                         CGRect newTableFrame = self.tableView.frame;
                         newTableFrame.origin.x -= slideDistance;
                         
                         CGRect newDetailFrame = self.detailView.frame;
                         newDetailFrame.origin.x -= slideDistance;
                         
                         self.pieChartView.frame = newPieChartFrame;
                         self.tableView.frame = newTableFrame;
                         self.detailView.frame = newDetailFrame;
                     }
                     completion:^(BOOL finished) {
                         // nothing
                     }];

    [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]].accessoryType = UITableViewCellAccessoryNone;
}

- (IBAction)swipeRight:(UISwipeGestureRecognizer *)sender {
    if (self.pieChartView.frame.origin.x > 0) {
        return;
    }

    CGFloat slideDistance = self.view.bounds.size.width / 2;
    
    [UIView animateWithDuration:0.5 
                          delay:0 
                        options:UIViewAnimationCurveEaseOut 
                     animations:^{
                         CGRect newPieChartFrame = self.pieChartView.frame;
                         newPieChartFrame.origin.x += slideDistance;
                         
                         CGRect newTableFrame = self.tableView.frame;
                         newTableFrame.origin.x += slideDistance;
                         
                         CGRect newDetailFrame = self.detailView.frame;
                         newDetailFrame.origin.x += slideDistance;

                         self.pieChartView.frame = newPieChartFrame;
                         self.tableView.frame = newTableFrame;
                         self.detailView.frame = newDetailFrame;
                     }
                     completion:^(BOOL finished) {
                         NSLog(@"Done!");
                     }];

    [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]].accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
}

@end
