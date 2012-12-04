//
//  UCLFightsViewController.m
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-07-25.
//  Copyright (c) 2012 Gordon Tyler. All rights reserved.
//

#import "UCLFightsViewController.h"
#import "UCLFIghtViewController.h"

#import "UCLFight.h"
#import "UCLNetworkClient.h"
#import "UCLLogFileLoader.h"

@implementation UCLFightsViewController

#pragma mark - Properties

@synthesize fightViewController;
@synthesize url;
@synthesize logFile;
@synthesize fightsTableView;

- (void)setUrl:(NSURL *)newURL
{
    url = newURL;
    [self refresh:nil];
}

- (void)setLogFile:(UCLLogFile *)newLogFile
{
    logFile = newLogFile;
    [self.fightsTableView reloadData];
}

#pragma mark - Instance Methods

- (IBAction)refresh:(id)sender {
    void (^handler)(NSURLResponse* response, NSData* data, NSError* error) = ^(NSURLResponse* response, NSData* data, NSError* error) {
        if (data == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"UCL" 
                                            message:[error localizedDescription] 
                                           delegate:nil 
                                  cancelButtonTitle:@"OK" 
                                  otherButtonTitles:nil] show];
            });
        }
        else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                UCLLogFile* newLogFile = [UCLLogFileLoader loadFromData:data];
                NSLog(@"Loaded %d fight(s) from %@", [logFile.fights count], self.url);
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.logFile = newLogFile;
                });
            });
        }
    };
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:self.url] 
                                       queue:[NSOperationQueue mainQueue] 
                           completionHandler:handler];
    
    self.logFile = nil;
    [self.fightsTableView reloadData];
}

#pragma mark - View methods

- (void)viewDidUnload {
    [self setFightsTableView:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.fightsTableView deselectRowAtIndexPath:[self.fightsTableView indexPathForSelectedRow] animated:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        if (self.logFile == nil) {
            return 1;
        }
        return [self.logFile.fights count];
    }
    
    return 0;
}

NSString* formatDuration(NSTimeInterval duration) {
    if (duration >= 60*60) {
        int seconds = fmod(duration, 60);
        int minutes = fmod((duration - seconds) / 60, 60);
        int hours = (((duration - seconds) / 60) - minutes) / 60;
        return [NSString stringWithFormat:@"%dh %dm %ds", hours, minutes, seconds];
    }
    else if (duration >= 60) {
        int seconds = fmod(duration, 60);
        int minutes = (duration - seconds) / 60;
        return [NSString stringWithFormat:@"%dm %ds", minutes, seconds];
    }
    else {
        return [NSString stringWithFormat:@"%.0fs", duration];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* fightCellID = @"FightCell";
    static NSString* loadingCellID = @"LoadingCell";
    
    if ([indexPath section] == 0) {
        UITableViewCell *cell;
        if (indexPath.row == 0 && self.url != nil && self.logFile == nil) {
            cell = [tableView dequeueReusableCellWithIdentifier:loadingCellID];
        }
        else {
            UCLFight* fight = [self.logFile.fights objectAtIndex:indexPath.row];
            cell = [tableView dequeueReusableCellWithIdentifier:fightCellID];
            cell.textLabel.text = fight.title;
            cell.detailTextLabel.text = formatDuration(fight.duration);
        }
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UCLFight* fight = [self.logFile.fights objectAtIndex:indexPath.row];
    [self.fightViewController showFight:fight inLogFile:self.logFile];
}

@end
