//
//  UCLSummaryTypesViewController.m
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-08-02.
//  Copyright (c) 2012 Gordon Tyler. All rights reserved.
//

#import "UCLSummaryTypesViewController.h"

@implementation UCLSummaryTypesViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate setSummaryType:[self.tableView cellForRowAtIndexPath:indexPath].tag];
}

@end
