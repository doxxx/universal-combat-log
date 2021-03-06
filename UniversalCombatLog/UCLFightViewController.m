//
//  UCLFightViewController.m
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-10-23.
//  Copyright (c) 2012 Gordon Tyler. All rights reserved.
//

#import "UCLLogsViewController.h"
#import "UCLFight+Summarizing.h"

#define PER_SECOND_WINDOW_SIZE 5

@implementation UCLFightViewController
{
    NSArray* _pieChartColors;
    UCLLogFile* _logFile;
    UCLSummaryType _summaryType;
    NSRange _visibleIndexRange;
    UCLEntity* _selectedActor;
    NSDictionary* _spellBreakdown;
    NSArray* _sortedSpells;
    NSDictionary* _spellColors;
    double _spellBreakdownSum;
    
    UIPopoverController* _uclPopoverController;
}

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
    
    [self updateLineChart];
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

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    self.fightLineChartView.rotating = NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue isKindOfClass:[UIStoryboardPopoverSegue class]]) {
        _uclPopoverController = ((UIStoryboardPopoverSegue*)segue).popoverController;
    }

    if ([segue.identifier isEqualToString:@"Logs"]) {
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
    _visibleIndexRange = NSMakeRange(0, self.fight.count);
    _selectedActor = nil;
    
    [self.fightLineChartView resetZoom];
    [self.fightLineChartView removeAllLines];
    
    [self updateLineChart];
    
    [self.playersButton setEnabled:YES];
    [self.summaryTypeButton setEnabled:YES];
    
    if (!self.playerDetailsView.hidden) {
        [self hidePlayerDetails];
    }
}

- (IBAction)showPlayersPopover:(id)sender
{
    [self showPopover:@"Players"];
}

- (IBAction)showSummaryTypesPopover:(id)sender
{
    [self showPopover:@"SummaryTypes"];
}

- (IBAction)showLogsPopover:(id)sender
{
    [self showPopover:@"Logs"];
}

- (void)showPopover:(NSString*)identifier
{
    BOOL perform = YES;

    if (_uclPopoverController.popoverVisible) {
        perform = ![_uclPopoverController.contentViewController.title isEqualToString:identifier];
        [_uclPopoverController dismissPopoverAnimated:YES];
        _uclPopoverController = nil;
    }

    if (perform) {
        [self performSegueWithIdentifier:identifier sender:nil];
    }
}

- (void)setSummaryType:(UCLSummaryType)summaryType
{
    [_uclPopoverController dismissPopoverAnimated:YES];
    _uclPopoverController = nil;
    
    _summaryType = summaryType;
    switch (summaryType) {
        case UCLSummaryDPS:
            self.summaryTypeButton.title = @"DPS";
            self.spellMinLabel.text = @"@Min Damage";
            self.spellMaxLabel.text = @"@Max Damage";
            self.spellAvgLabel.text = @"@Avg Damage";
            break;
            
        case UCLSummaryHPS:
            self.summaryTypeButton.title = @"HPS";
            self.spellMinLabel.text = @"Min Healing";
            self.spellMaxLabel.text = @"Max Healing";
            self.spellAvgLabel.text = @"Avg Healing";
            break;
            
        default:
            break;
    }
    
    [self updateLineChart];
    [self updatePlayerDetailsNewData:YES];
}

#pragma mark - LineChartView Delegate Methods

- (void)lineChartView:(UCLLineChartView *)lineChartView didZoomToRange:(NSRange)range
{
    _visibleIndexRange = [self.fight indexRangeForTimeRange:range];

    [self updatePlayerDetailsNewData:NO];
}

- (void)actorsView:(UCLActorsViewController *)actorsView didSelectActor:(UCLEntity *)actor
{
    [_uclPopoverController dismissPopoverAnimated:YES];
    _uclPopoverController = nil;

    _selectedActor = actor;

    [self updateSpellColors];
    [self updateLineChart];
    [self updatePlayerDetailsNewData:YES];

    if (self.playerDetailsView.hidden) {
        [self showPlayerDetails];
    }
}

- (void)actorsView:(UCLActorsViewController *)actorsView didDeselectActor:(UCLEntity *)actor
{
    [self.fightLineChartView removeLineForKey:actor.name];
    _selectedActor = nil;
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

    if (indexPath.row < _sortedSpells.count) {
        NSNumber* spellID = [_sortedSpells objectAtIndex:indexPath.row];
        UCLSpell* spell = [self.fight spellForID:spellID.unsignedLongLongValue];
        NSNumber* value = [_spellBreakdown objectForKey:spellID];
        cell.textLabel.text = spell.name;
        cell.textLabel.textColor = [_spellColors objectForKey:spellID];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f%%", 
                                     ([value doubleValue] / _spellBreakdownSum * 100)];
        cell.detailTextLabel.textColor = [_spellColors objectForKey:spellID];
    }
    else {
        cell.textLabel.text = @"";
        cell.detailTextLabel.text = @"";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.spellPieChartView selectSegment:indexPath.row];
    [self updateSpellStatsForRange:_visibleIndexRange];
}

#pragma mark - PieChartView Delegate Methods

- (void)pieChartView:(UCLPieChartView *)pieChartView didSelectSegmentAtIndex:(NSInteger)segmentIndex
{
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:segmentIndex inSection:0];
    [self.spellTableView selectRowAtIndexPath:indexPath
                                animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    [self updateSpellStatsForRange:_visibleIndexRange];
}

- (UIColor *)pieChartView:(UCLPieChartView *)pieChartView colorForSegment:(NSInteger)segmentIndex
{
    if (segmentIndex < _sortedSpells.count) {
        NSNumber* spellID = [_sortedSpells objectAtIndex:segmentIndex];
        return [_spellColors objectForKey:spellID];
    }
    else {
        return nil;
    }
}

- (void)updateSpellColors
{
    NSRange indexRange = NSMakeRange(0, self.fight.count);
    NSDictionary* spellBreakdown = [self calculateSpellBreakdownForIndexRange:indexRange];
    NSArray* sortedSpells = [spellBreakdown keysSortedByValueUsingComparator:^(NSNumber* amount1, NSNumber* amount2) {
        return [amount2 compare:amount1];
    }];

    NSMutableDictionary* newSpellColors = [NSMutableDictionary dictionaryWithCapacity:[sortedSpells count]];
    NSUInteger colorIndex = 0;
    for (NSNumber* spellID in sortedSpells) {
        UIColor* color = nil;
        if (colorIndex < [_pieChartColors count]) {
            color = [_pieChartColors objectAtIndex:colorIndex];
        }
        if (!color) {
            color = [UIColor whiteColor];
        }
        [newSpellColors setObject:color forKey:spellID];
        colorIndex++;
    }
    
    _spellColors = newSpellColors;
}

- (void)updateLineChart
{
    if (!self.fight) {
        return;
    }

    UCLLogEventPredicate predicate = ^BOOL(UCLLogEvent *event) {
        return ((_summaryType == UCLSummaryDPS && UCLLogEventIsDamage(event)) ||
                (_summaryType == UCLSummaryHPS && UCLLogEventIsHealing(event)));
    };
    NSArray* lineValues = [self.fight amountsPerSecondUsingWindowSize:PER_SECOND_WINDOW_SIZE
                                                        withPredicate:predicate];
    [self.fightLineChartView addLineWithValues:lineValues forKey:@"Total"];

    if (_selectedActor) {
        uint64_t selectedActorID = _selectedActor.idNum;
        UCLLogEventPredicate playerPredicate = ^BOOL(UCLLogEvent *event) {
            return predicate(event) && event->actorID == selectedActorID;
        };
        NSArray* playerLineValues = [self.fight amountsPerSecondUsingWindowSize:PER_SECOND_WINDOW_SIZE
                                                            withPredicate:playerPredicate];
        [self.fightLineChartView addLineWithValues:playerLineValues forKey:_selectedActor.name];
    }
}

- (void)updatePlayerDetailsNewData:(BOOL)newData
{
    if (!_selectedActor) {
        return;
    }
    [self updateSpellBreakdownsNewData:newData];
}

- (void)updateSpellBreakdownsNewData:(BOOL)newData
{
    NSNumber* selectedSpellID = nil;
    NSIndexPath* indexPath = [self.spellTableView indexPathForSelectedRow];
    if (indexPath != nil) {
        selectedSpellID = [_sortedSpells objectAtIndex:indexPath.row];
    }
    NSRange range = _visibleIndexRange;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary* newSpellBreakdown = [self calculateSpellBreakdownForIndexRange:range];
        NSArray* newSortedSpells = [newSpellBreakdown keysSortedByValueUsingComparator:^(NSNumber* amount1, NSNumber* amount2) {
            return [amount2 compare:amount1];
        }];

        NSMutableArray* sortedSpellValues = [NSMutableArray arrayWithCapacity:[newSortedSpells count]];
        for (NSNumber* spellID in newSortedSpells) {
            [sortedSpellValues addObject:[newSpellBreakdown objectForKey:spellID]];
        }

        double sum = 0;
        for (NSNumber* value in [newSpellBreakdown allValues]) {
            sum += [value doubleValue];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            _spellBreakdown = newSpellBreakdown;
            _sortedSpells = newSortedSpells;
            _spellBreakdownSum = sum;

            self.spellPieChartView.data = sortedSpellValues;
            [self.spellTableView reloadData];

            if (!newData && selectedSpellID != nil) {
                NSUInteger selectedRow = [_sortedSpells indexOfObject:selectedSpellID];
                [self.spellPieChartView selectSegment:selectedRow];
                [self.spellTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:0]
                                                 animated:NO
                                           scrollPosition:UITableViewScrollPositionNone];
            }

            [self updateSpellStatsForRange:range];
        });
    });
}

- (NSDictionary *)calculateSpellBreakdownForIndexRange:(NSRange)indexRange
{
    uint64_t selectedActorID = _selectedActor.idNum;

    return [self.fight spellBreakdownForIndexRange:indexRange withPredicate:^BOOL(UCLLogEvent *event) {
        BOOL matchesSummaryType = ((_summaryType == UCLSummaryDPS && UCLLogEventIsDamage(event)) ||
                                   (_summaryType == UCLSummaryHPS && UCLLogEventIsHealing(event)));
        return matchesSummaryType && event->actorID == selectedActorID;
    }];
}

- (void)updateSpellStatsForRange:(NSRange)range
{
    NSIndexPath* indexPath = [self.spellTableView indexPathForSelectedRow];
    if (indexPath == nil) {
        self.spellStatsView.hidden = YES;
        return;
    }
    
    uint64_t spellID = [[_sortedSpells objectAtIndex:indexPath.row] unsignedLongLongValue];

    NSUInteger attackCount = 0, hitCount = 0, critCount = 0;
    double min = NSUIntegerMax, max = 0, total = 0, average = 0;
    
    uint64_t selectedActorID = _selectedActor.idNum;

    UCLLogEvent* event = self.fight.events + range.location;
    for (uint32_t count = range.length; count > 0; count--, event++) {
        if (event->actorID == selectedActorID && event->spellID == spellID) {
            attackCount++;
            if (!UCLLogEventIsMiss(event)) {
                hitCount++;
                if (UCLLogEventIsCritical(event)) {
                    critCount++;
                }
                double amount = event->amount;
                min = MIN(min, amount);
                max = MAX(max, amount);
                total += amount;
            }
        }
    }
    
    average = total / hitCount;

    dispatch_async(dispatch_get_main_queue(), ^{
        self.spellHitsAmountLabel.text = [NSString stringWithFormat:@"%d (%.1f%%)", hitCount, (float)hitCount / (float)attackCount * 100.0];
        self.spellCritsAmountLabel.text = [NSString stringWithFormat:@"%d (%.1f%%)", critCount, (float)critCount / (float)hitCount * 100.0];
        self.spellMinAmountLabel.text = [NSString stringWithFormat:@"%.0f", min];
        self.spellMaxAmountLabel.text = [NSString stringWithFormat:@"%.0f", max];
        self.spellAvgAmountLabel.text = [NSString stringWithFormat:@"%.0f", average];

        self.spellStatsView.hidden = NO;
    });
}

- (void)showPlayerDetails
{
    self.playerDetailsView.hidden = NO;
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionAllowAnimatedContent
                     animations:^{
                         CGRect chartFrame = self.fightLineChartView.frame;
                         chartFrame.size.width = 768;
                         self.fightLineChartView.frame = chartFrame;
                         
                         CGRect detailsFrame = self.playerDetailsView.frame;
                         detailsFrame.origin.x = 768;
                         self.playerDetailsView.frame = detailsFrame;
                         
                         self.playerDetailsView.alpha = 1;
                     } 
                     completion:^(BOOL finished){
                     }];
}

- (void)hidePlayerDetails
{
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionAllowAnimatedContent
                     animations:^{
                         CGRect chartFrame = self.fightLineChartView.frame;
                         chartFrame.size.width = 1024;
                         self.fightLineChartView.frame = chartFrame;
                         
                         CGRect detailsFrame = self.playerDetailsView.frame;
                         detailsFrame.origin.x = 1024;
                         self.playerDetailsView.frame = detailsFrame;
                         
                         self.playerDetailsView.alpha = 0;
                     } 
                     completion:^(BOOL finished){
                         self.playerDetailsView.hidden = YES;
                     }];
}

@end
