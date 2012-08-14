//
//  UCLFightsViewController.m
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-07-25.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UCLFightsViewController.h"
#import "UCLActorsViewController.h"

#import "UCLFight.h"

@implementation UCLFightsViewController

#pragma mark - Properties

@synthesize fights=_fights;
@synthesize actorViewController=_actorViewController;

- (void)setFights:(NSArray *)fights
{
    _fights = fights;
    [self.tableView reloadData];
}

#pragma mark - View methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return [self.fights count];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FightCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if ([indexPath section] == 0) {
        UCLFight* fight = [self.fights objectAtIndex:[indexPath row]];
        // Configure the cell...
        cell.textLabel.text = fight.title;
        return cell;
    }
    
    return nil;
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"FightToActors"]) {
        UCLActorsViewController* vc = [segue destinationViewController];
        NSIndexPath* indexPath = [self.tableView indexPathForCell:sender];
        vc.actorViewController = self.actorViewController;
        vc.fight = [self.fights objectAtIndex:indexPath.row];
    }
}


@end
