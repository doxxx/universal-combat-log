//
//  UCLDetailViewController.m
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-07-19.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UCLFightViewController.h"

@interface UCLFightViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation UCLFightViewController

@synthesize fight = _fight;
@synthesize titleLabel = _titleLabel;
@synthesize selectorControl = _selectorControl;
@synthesize tableView = _tableView;
@synthesize masterPopoverController = _masterPopoverController;

#pragma mark - Managing the detail item

- (void)setFight:(UCLFight *)fight
{
    if (_fight != fight) {
        _fight = fight;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.fight) {
        self.titleLabel.text = self.fight.title;
        
        if (self.selectorControl.selectedSegmentIndex == 0) { // DPS
            
        }
        else if (self.selectorControl.selectedSegmentIndex == 1) { // HPS
            
        }
        
        [self.tableView reloadData];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    self.titleLabel = nil;
    self.selectorControl = nil;
    self.tableView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Fights", @"Fights");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark - Table view delegate

#pragma mark - Table view datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray* names = [NSArray arrayWithObjects:@"Bob", @"Jane", @"Dick", @"Harry", @"Tom", nil];
    int values[] = {100, 75, 50, 25, 1};
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"SummaryCell"];
    cell.textLabel.text = [names objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [[NSNumber numberWithInt:values[indexPath.row]] stringValue];
    return cell;
}

#pragma mark - Actions

- (IBAction)selectorChanged:(UISegmentedControl *)sender {
    [self configureView];
}
@end
