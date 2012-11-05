//
//  UCLFIghtViewController.m
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-10-23.
//  Copyright (c) 2012 Gordon Tyler. All rights reserved.
//

#import "UCLFightViewController.h"

#import <QuartzCore/QuartzCore.h>

#define PER_SECOND_WINDOW_SIZE 5

@implementation UCLFightViewController
{
    NSInteger _playerTableMode;
    NSArray* _players;
    NSDictionary* _playerDetails;
}

@synthesize fight;
@synthesize fightLineChartView;
@synthesize playersTableView;
@synthesize playersTableModeToggleControl;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _playerTableMode = 0;

    [self processEvents];
}

- (void)viewDidUnload
{
    _players = nil;
    
    self.fightLineChartView = nil;
    self.playersTableView = nil;
    self.playersTableModeToggleControl = nil;
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
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

- (void)viewDidLayoutSubviews
{
    // resize fight line chart view
    CGRect frame = self.fightLineChartView.frame;
    CGSize viewSize = self.view.bounds.size;
    CGFloat newHeight = MIN(viewSize.height, viewSize.width / 1.45);
    frame.size.height = newHeight;
    self.fightLineChartView.frame = frame;

    // reposition players table mode toggle control
    CGRect tableFrame = self.playersTableView.frame;
    CGRect controlFrame = self.playersTableModeToggleControl.frame;
    CGFloat controlX = tableFrame.origin.x + tableFrame.size.width - controlFrame.size.width;
    CGFloat controlY = tableFrame.origin.y - controlFrame.size.height - 3;
    CGRect newFrame = CGRectMake(controlX, controlY, controlFrame.size.width, controlFrame.size.height);
    self.playersTableModeToggleControl.frame = newFrame;
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
            if ((_playerTableMode == 0 && [event isDamage]) ||
                (_playerTableMode == 1 && [event isHealing])) {
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

    [self.fightLineChartView removeDataForKey:@"Total"];
    [self.fightLineChartView addData:chartData forKey:@"Total"];

    free(totals);
}

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
        [self.fightLineChartView addData:data forKey:player.name];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == playersTableView) {
        UCLEntity* player = [_players objectAtIndex:indexPath.row];
        [self.fightLineChartView removeDataForKey:player.name];
    }
}

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
            if ((_playerTableMode == 0 && [event isDamage]) ||
                (_playerTableMode == 1 && [event isHealing])) {
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

- (IBAction)playerTableModeToggled:(UISegmentedControl *)sender {
    _playerTableMode = sender.selectedSegmentIndex;
    [self processEvents];
    [self.playersTableView reloadData];
}

@end
