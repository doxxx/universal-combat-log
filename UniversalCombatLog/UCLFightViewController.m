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
    UCLSummaryType _summaryType;
    NSArray* _players;
    NSDictionary* _playerDetails;
    UCLEntity* _selectedActor;
    
    UIPopoverController* _uclPopoverController;
}

@synthesize fight = _fight;
@synthesize fightLineChartView;
@synthesize playersButton = _playersButton;
@synthesize summaryTypeButton = _summaryTypeButton;

- (void)setFight:(UCLFight *)fight
{
    if (_uclPopoverController) {
        [_uclPopoverController dismissPopoverAnimated:YES];
        _uclPopoverController = nil;
    }
    _fight = fight;
    _selectedActor = nil;
    
    [self.fightLineChartView removeAllLines];
    
    [self processEvents];
    
    [self.playersButton setEnabled:YES];
    [self.summaryTypeButton setEnabled:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _summaryType = UCLSummaryDPS;

    [self processEvents];
}

- (void)viewDidUnload
{
    _players = nil;
    _playerDetails = nil;
    _selectedActor = nil;
    
    self.fightLineChartView = nil;
    self.playersButton = nil;
    self.summaryTypeButton = nil;
    
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

- (void)processEvents
{
    NSUInteger duration = ceil(self.fight.duration);
    NSDate* start = self.fight.startTime;
    double* totals = malloc(sizeof(double)*duration);
    
    for (NSUInteger i = 0; i < duration; i++) {
        totals[i] = 0;
    }
    
    NSMutableDictionary* players = [NSMutableDictionary dictionaryWithCapacity:25];
    
    for (UCLLogEvent* event in self.fight.events) {
        if ([event.actor isPlayerOrPet]) {
            uint32_t index = floor([event.time timeIntervalSinceDate:start]);
            NSNumber* playerTotal = [players objectForKey:event.actor];
            if ((_summaryType == UCLSummaryDPS && [event isDamage]) ||
                (_summaryType == UCLSummaryHPS && [event isHealing])) {
                if (playerTotal == nil) {
                    playerTotal = event.amount;
                }
                else {
                    playerTotal = [NSNumber numberWithDouble:[playerTotal doubleValue] + [event.amount doubleValue]];
                }
                [players setObject:playerTotal forKey:event.actor];
                totals[index] = totals[index] + [event.amount doubleValue];
            }
        }
        if ([event.target isPlayerOrPet]) {
            if ([players objectForKey:event.target] == nil) {
                [players setObject:[NSNumber numberWithDouble:0] forKey:event.target];
            }
        }
    }
    
    NSComparator valueSort = ^(NSNumber* v1, NSNumber* v2){ return [v2 compare:v1]; };
    _players = [players keysSortedByValueUsingComparator:valueSort];
    
    for (UCLEntity* player in [players allKeys]) {
        NSNumber* playerTotal = [players objectForKey:player];
        [players setObject:[NSNumber numberWithDouble:[playerTotal doubleValue] / duration] forKey:player];
    }
    
    _playerDetails = players;
    
    NSMutableArray* chartData = [NSMutableArray arrayWithCapacity:duration];
    
    for (NSUInteger i = 0; i < duration; i++) {
        double value = 0;
        NSUInteger windowSize = MIN(PER_SECOND_WINDOW_SIZE, i + 1);
        for (NSInteger j = i - windowSize + 1; j <= i; j++) {
            value += totals[j];
        }
        [chartData addObject:[NSNumber numberWithDouble:(value / windowSize)]];
    }

    [self.fightLineChartView removeLineForKey:@"Total"];
    [self.fightLineChartView addLineWithValues:chartData forKey:@"Total"];

    free(totals);
}
/*
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.playersTableView) {
        return [_players count];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.playersTableView) {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        UCLEntity* player = [_players objectAtIndex:indexPath.row];
        NSNumber* playerValue = [_playerDetails objectForKey:player];
        cell.textLabel.text = player.name;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f", [playerValue doubleValue]];
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.playersTableView) {
        UCLEntity* player = [_players objectAtIndex:indexPath.row];
        NSArray* data = [self chartDataForEntity:player];
        [self.fightLineChartView addLineWithValues:data forKey:player.name];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == playersTableView) {
        UCLEntity* player = [_players objectAtIndex:indexPath.row];
        [self.fightLineChartView removeLineForKey:player.name];
    }
}
*/

- (NSArray*)chartDataForEntity:(UCLEntity*)entity
{
    NSUInteger duration = ceil(self.fight.duration);
    NSDate* start = self.fight.startTime;
    double* totals = malloc(sizeof(double)*duration);
    
    for (NSUInteger i = 0; i < duration; i++) {
        totals[i] = 0;
    }
    
    for (UCLLogEvent* event in self.fight.events) {
        if ([event.actor isEqualToEntity:entity]) {
            uint32_t index = floor([event.time timeIntervalSinceDate:start]);
            if ((_summaryType == UCLSummaryDPS && [event isDamage]) ||
                (_summaryType == UCLSummaryHPS && [event isHealing])) {
                totals[index] = totals[index] + [event.amount doubleValue];
            }
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
    [self processEvents];
//    [self.playersTableView reloadData];
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

- (void)actorsView:(UCLActorsViewController *)actorsView didSelectActor:(UCLEntity *)actor
{
    if (_selectedActor) {
        [self.fightLineChartView removeLineForKey:_selectedActor.name];
    }
    _selectedActor = actor;
    NSArray* data = [self chartDataForEntity:actor];
    [self.fightLineChartView addLineWithValues:data forKey:actor.name];
}

@end
