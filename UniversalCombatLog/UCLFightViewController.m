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

@synthesize fight = _fight;
@synthesize lineChartView = _lineChartView;
@synthesize playersTableView = _playersTableView;
@synthesize playersTableModeToggleControl = _playersTableModeToggleControl;

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self processEvents];
}

- (void)viewDidUnload
{
    _players = nil;
    
    self.lineChartView = nil;
    self.playersTableView = nil;
    self.playersTableModeToggleControl = nil;
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [_lineChartView willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)viewDidLayoutSubviews
{
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
    NSUInteger duration = ceil(_fight.duration);
    NSDate* start = _fight.startTime;
    double* totals = malloc(sizeof(double)*duration);
    
    for (NSUInteger i = 0; i < duration; i++) {
        totals[i] = 0;
    }
    
    NSMutableDictionary* players = [NSMutableDictionary dictionaryWithCapacity:25];
    
    for (UCLLogEvent* event in _fight.events) {
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

    _lineChartView.data = chartData;

    free(totals);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _playersTableView) {
        return [_players count];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _playersTableView) {
        UITableViewCell* cell = [_playersTableView dequeueReusableCellWithIdentifier:@"Cell"];
        UCLEntity* player = [_players objectAtIndex:indexPath.row];
        NSNumber* playerValue = [_playerDetails objectForKey:player];
        cell.textLabel.text = player.name;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f", [playerValue doubleValue]];
        return cell;
    }
    
    return nil;
}

- (IBAction)playerTableModeToggled:(UISegmentedControl *)sender {
    _playerTableMode = sender.selectedSegmentIndex;
    [self processEvents];
    [_playersTableView reloadData];
}

@end
