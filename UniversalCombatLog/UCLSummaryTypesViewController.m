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
@synthesize popoverController;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.actorsViewController.summaryType = [self.tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    [self.popoverController dismissPopoverAnimated:TRUE];
}

@end
