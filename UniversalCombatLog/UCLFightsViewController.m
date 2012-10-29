//
//  UCLFightsViewController.m
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-07-25.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UCLFightsViewController.h"
#import "UCLActorsViewController.h"
#import "UCLFIghtViewController.h"

#import "UCLFight.h"
#import "UCLNetworkClient.h"
#import "UCLLogFileLoader.h"

@implementation UCLFightsViewController

#pragma mark - Properties

@synthesize url=_url;
@synthesize fights=_fights;
//@synthesize actorViewController=_actorViewController;
@synthesize tableView = _tableView;

- (void)viewWillAppear:(BOOL)animated
{
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:NO];
}

- (void)setUrl:(NSURL *)url
{
    _url = url;
    
    [self refresh:nil];
}

- (void)setFights:(NSArray *)fights
{
    _fights = fights;
    [self.tableView reloadData];
}

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
                UCLLogFile* logFile = [UCLLogFileLoader loadFromData:data];
                NSLog(@"Loaded %d fights from network server", [logFile.fights count]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.fights = logFile.fights;
                });
            });
        }
    };
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:self.url] 
                                       queue:[NSOperationQueue mainQueue] 
                           completionHandler:handler];
    
    _fights = nil;
    [self.tableView reloadData];
}

#pragma mark - View methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        if (self.url != nil && self.fights == nil) {
            return 1;
        }
        return [self.fights count];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* fightCellID = @"FightCell";
    static NSString* loadingCellID = @"LoadingCell";
    
    if ([indexPath section] == 0) {
        UITableViewCell *cell;
        if (indexPath.row == 0 && self.url != nil && self.fights == nil) {
            cell = [tableView dequeueReusableCellWithIdentifier:loadingCellID];
        }
        else {
            UCLFight* fight = [self.fights objectAtIndex:[indexPath row]];
            cell = [tableView dequeueReusableCellWithIdentifier:fightCellID];
            cell.textLabel.text = fight.title;
        }
        return cell;
    }
    
    return nil;
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"Fight"]) {
//        UCLActorsViewController* vc = [segue destinationViewController];
        UCLFightViewController* vc = [segue destinationViewController];
        NSIndexPath* indexPath = [self.tableView indexPathForCell:sender];
//        vc.actorViewController = self.actorViewController;
        vc.fight = [self.fights objectAtIndex:indexPath.row];
    }
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}
@end
