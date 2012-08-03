//
//  UCLSummaryTypesViewController.m
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-08-02.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UCLSummaryTypesViewController.h"

@interface UCLSummaryTypesViewController ()

@end

@implementation UCLSummaryTypesViewController

@synthesize actorsViewController;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.actorsViewController.summaryType = [self.tableView cellForRowAtIndexPath:indexPath].textLabel.text;
}

@end
