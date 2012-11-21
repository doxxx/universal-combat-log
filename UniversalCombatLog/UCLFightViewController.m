//
//  UCLFIghtViewController.m
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-10-23.
//  Copyright (c) 2012 Gordon Tyler. All rights reserved.
//

#import "UCLLogsViewController.h"
#import "UCLFightViewController.h"
#import "UCLActorsViewController.h"

#import <QuartzCore/QuartzCore.h>

#define PER_SECOND_WINDOW_SIZE 5

@implementation UCLFightViewController
{
    NSArray* _pieChartColors;
    UCLLogFile* _logFile;
    UCLSummaryType _summaryType;
    NSRange _visibleRange;
    UCLEntity* _selectedActor;
    NSArray* _selectedActorEvents;
    NSDictionary* _spellBreakdown;
    NSArray* _sortedSpells;
    NSArray* _sortedSpellValues;
    NSDictionary* _spellColors;
    double _spellBreakdownSum;
    
    UIPopoverController* _uclPopoverController;
}

@synthesize fight = _fight;
@synthesize fightLineChartView = _fightLineChartView;
@synthesize playersButton = _playersButton;
@synthesize summaryTypeButton = _summaryTypeButton;
@synthesize playerDetailsView = _playerDetailsView;
@synthesize spellPieChartView = _pieChartView;
@synthesize spellTableView = _spellTableView;
@synthesize spellStatsView = _spellStatsView;
@synthesize spellHitsLabel = _spellHitPercentLabel;
@synthesize spellCritsLabel = _spellCritPercentLabel;
@synthesize spellMinDamageLabel = _spellMinDamageLabel;
@synthesize spellMaxDamageLabel = _spellMaxDamageLabel;
@synthesize spellAvgDamageLabel = _spellAvgDamageLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _pieChartColors = [NSArray arrayWithObjects:
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
                       nil];
    
    _summaryType = UCLSummaryDPS;

    CGRect playerDetailsFrame = self.playerDetailsView.frame;
    playerDetailsFrame.origin.x = 1024;
    self.playerDetailsView.frame = playerDetailsFrame;
    self.playerDetailsView.alpha = 0;
    self.playerDetailsView.hidden = YES;

    [self updateOverview];
}

- (void)viewDidUnload
{
    _selectedActor = nil;
    _pieChartColors = nil;
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    self.fightLineChartView.rotating = YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.fightLineChartView willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    self.fightLineChartView.rotating = NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (_uclPopoverController) {
        [_uclPopoverController dismissPopoverAnimated:NO];
    }
    if ([segue isKindOfClass:[UIStoryboardPopoverSegue class]]) {
        _uclPopoverController = ((UIStoryboardPopoverSegue*)segue).popoverController;
    }
    
    if ([segue.identifier isEqualToString:@"LogsFightsPopover"]) {
        UINavigationController* navController = segue.destinationViewController;
        UCLLogsViewController* logsController = (UCLLogsViewController*)navController.topViewController;
        logsController.fightViewController = self;
        if (_logFile) {
            [logsController navigateToLogFile:_logFile];
        }
    }
    else if ([segue.identifier isEqualToString:@"SummaryTypes"]) {
        UCLSummaryTypesViewController* summaryTypesController = segue.destinationViewController;
        summaryTypesController.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"Players"]) {
        UCLActorsViewController* actorsViewController = segue.destinationViewController;
        [actorsViewController setFight:self.fight summaryType:_summaryType];
        if (_selectedActor) {
            actorsViewController.selectedActor = _selectedActor;
        }
        actorsViewController.delegate = self;
    }
}

- (void)showFight:(UCLFight *)fight inLogFile:(UCLLogFile *)logFile
{
    if (_uclPopoverController) {
        [_uclPopoverController dismissPopoverAnimated:YES];
        _uclPopoverController = nil;
    }
    
    self.fight = fight;
    _logFile = logFile;
    _visibleRange = NSMakeRange(0, ceil(self.fight.duration));
    _selectedActor = nil;
    
    [self.fightLineChartView removeAllLines];
    
    [self updateOverview];
    
    [self.playersButton setEnabled:YES];
    [self.summaryTypeButton setEnabled:YES];
    
    if (!self.playerDetailsView.hidden) {
        CGRect chartFrame = self.fightLineChartView.frame;
        chartFrame.size.width = 1024;
        self.fightLineChartView.frame = chartFrame;
        
        CGRect detailsFrame = self.playerDetailsView.frame;
        detailsFrame.origin.x = 1024;
        self.playerDetailsView.frame = detailsFrame;
        
        self.playerDetailsView.alpha = 0;
        self.playerDetailsView.hidden = YES;
    }
}

- (void)setSummaryType:(UCLSummaryType)summaryType
{
    [_uclPopoverController dismissPopoverAnimated:YES];
    _uclPopoverController = nil;
    
    _summaryType = summaryType;
    switch (summaryType) {
        case UCLSummaryDPS:
            self.navigationItem.rightBarButtonItem.title = @"DPS";
            break;
            
        case UCLSummaryHPS:
            self.navigationItem.rightBarButtonItem.title = @"HPS";
            break;
            
        default:
            break;
    }
    
    [self updateOverview];
    [self updatePlayerDetails];
}

#pragma mark - LineChartView Delegate Methods

- (void)lineChartView:(UCLLineChartView *)lineChartView didZoomToRange:(NSRange)range
{
    _visibleRange = range;
    [self updateSpellBreakdownsNewData:NO];
    [self updateSpellStats];
}

- (void)actorsView:(UCLActorsViewController *)actorsView didSelectActor:(UCLEntity *)actor
{
    if (_selectedActor) {
        [self.fightLineChartView removeLineForKey:_selectedActor.name];
    }
    
    _selectedActor = actor;
    
    _selectedActorEvents = [self.fight filterEventsUsingPredicate:^BOOL(UCLLogEvent* event) {
        return [event.actor isEqualToEntity:_selectedActor];
    }];
    
    [self updatePlayerDetails];

    if (self.playerDetailsView.hidden) {
        CGRect chartFrame = self.fightLineChartView.frame;
        chartFrame.size.width = 768;
        self.fightLineChartView.frame = chartFrame;
        
        CGRect detailsFrame = self.playerDetailsView.frame;
        detailsFrame.origin.x = 768;
        self.playerDetailsView.frame = detailsFrame;
        
        self.playerDetailsView.alpha = 1;
        self.playerDetailsView.hidden = NO;
    }
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
    cell.detailTextLabel.textColor = [_spellColors objectForKey:spell];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.spellPieChartView selectSegment:indexPath.row];
    [self updateSpellStats];
}

#pragma mark - PieChartView Delegate Methods

- (void)pieChartView:(UCLPieChartView *)pieChartView didSelectSegmentAtIndex:(NSUInteger)segmentIndex
{
    [self.spellTableView cellForRowAtIndexPath:[self.spellTableView indexPathForSelectedRow]].accessoryType = UITableViewCellAccessoryNone;
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:segmentIndex inSection:0];
    [self.spellTableView selectRowAtIndexPath:indexPath
                                animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    [self.spellTableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    [self updateSpellStats];
}

- (UIColor *)pieChartView:(UCLPieChartView *)pieChartView colorForSegment:(NSUInteger)segmentIndex
{
    UCLSpell* spell = [_sortedSpells objectAtIndex:segmentIndex];
    return [_spellColors objectForKey:spell];
}

- (void)updateOverview
{
    NSArray* lineValues = [self chartLineValuesFromEvents:self.fight.events];
    [self.fightLineChartView addLineWithValues:lineValues forKey:@"Total"];
}

- (void)updatePlayerDetails
{
    NSArray* lineValues = [self chartLineValuesFromEvents:_selectedActorEvents];
    [self.fightLineChartView addLineWithValues:lineValues forKey:_selectedActor.name];
    [self updateSpellBreakdownsNewData:YES];
    [self updateSpellStats];
}

- (NSArray*)chartLineValuesFromEvents:(NSArray*)events
{
    NSDate* startTime = self.fight.startTime;
    NSUInteger duration = ceil(self.fight.duration);
    double* totals = malloc(sizeof(double) * duration);
    
    for (NSUInteger i = 0; i < duration; i++) {
        totals[i] = 0;
    }
    
    for (UCLLogEvent* event in events) {
        uint32_t index = floor([event.time timeIntervalSinceDate:startTime]);
        if ((_summaryType == UCLSummaryDPS && [event isDamage]) ||
            (_summaryType == UCLSummaryHPS && [event isHealing])) {
            totals[index] = totals[index] + [event.amount doubleValue];
        }
    }
    
    NSMutableArray* chartData = [NSMutableArray arrayWithCapacity:duration];
    
    for (NSUInteger i = 0; i < duration; i++) {
        double value = 0;
        NSUInteger windowSize = MIN(PER_SECOND_WINDOW_SIZE, i + 1);
        for (NSInteger j = i - windowSize + 1; j <= i; j++) {
            value += totals[j];
        }
        [chartData addObject:[NSNumber numberWithDouble:(value / windowSize)]];
    }
    
    free(totals);
    
    return chartData;
}

- (void)updateSpellBreakdownsNewData:(BOOL)newData
{
    UCLSpell* selectedSpell = nil;
    NSIndexPath* indexPath = [self.spellTableView indexPathForSelectedRow];
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
    
    self.spellPieChartView.data = _sortedSpellValues;
    [self.spellTableView reloadData];
    
    if (!newData && selectedSpell != nil) {
        NSUInteger selectedRow = [_sortedSpells indexOfObject:selectedSpell];
        [self.spellPieChartView selectSegment:selectedRow];
        [self.spellTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:0] 
                                         animated:NO 
                                   scrollPosition:UITableViewScrollPositionNone];
    }
}

- (NSDictionary *)calculateSpellBreakdown
{
    NSMutableDictionary* spellBreakdown = [NSMutableDictionary dictionary];
    
    NSDate* startTime = self.fight.startTime;
    
    NSRange range = [self visibleRange];
    
    for (UCLLogEvent* event in _selectedActorEvents) {
        if ((_summaryType == UCLSummaryDPS && [event isDamage]) ||
            (_summaryType == UCLSummaryHPS && [event isHealing])) {
            NSTimeInterval timeDiff = [event.time timeIntervalSinceDate:startTime];
            if (timeDiff < range.location || timeDiff >= range.location + range.length) {
                continue;
            }
            NSNumber* amount = [spellBreakdown objectForKey:event.spell];
            if (amount == nil) {
                [spellBreakdown setObject:event.amount forKey:event.spell];
            }
            else {
                long eventAmount = [event.amount longValue];
                long currentAmount = amount.longValue;
                long newAmount = eventAmount + currentAmount;
                [spellBreakdown setObject:[NSNumber numberWithLong:newAmount] forKey:event.spell];
            }
        }
    }
    
    return spellBreakdown;
}

- (NSRange)visibleRange 
{
    return _visibleRange;
}

- (void)updateSpellStats 
{
    NSIndexPath* indexPath = [self.spellTableView indexPathForSelectedRow];
    if (indexPath == nil) {
        self.spellStatsView.hidden = YES;
        return;
    }
    
    UCLSpell* spell = [_sortedSpells objectAtIndex:indexPath.row];
    
    NSUInteger attackCount = 0, hitCount = 0, critCount = 0;
    double min = NSUIntegerMax, max = 0, total = 0, average = 0;
    
    NSDate* startTime = _fight.startTime;
    
    NSRange range = [self visibleRange];
    
    for (UCLLogEvent* event in _selectedActorEvents) {
        NSTimeInterval timeDiff = [event.time timeIntervalSinceDate:startTime];
        if (timeDiff < range.location || timeDiff >= range.location + range.length) {
            continue;
        }
        if ([event.actor isEqualToEntity:_selectedActor] && [event.spell isEqualToSpell:spell]) {
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
    
    self.spellHitsLabel.text = [NSString stringWithFormat:@"%d (%.1f%%)", hitCount, (float)hitCount / (float)attackCount * 100.0];
    self.spellCritsLabel.text = [NSString stringWithFormat:@"%d (%.1f%%)", critCount, (float)critCount / (float)hitCount * 100.0];
    self.spellMinDamageLabel.text = [NSString stringWithFormat:@"%.0f", min];
    self.spellMaxDamageLabel.text = [NSString stringWithFormat:@"%.0f", max];
    self.spellAvgDamageLabel.text = [NSString stringWithFormat:@"%.0f", average];
    
    self.spellStatsView.hidden = NO;
}

@end
