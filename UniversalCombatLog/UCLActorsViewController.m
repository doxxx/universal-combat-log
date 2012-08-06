//
//  UCLActorsViewController.m
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-08-01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UCLActorsViewController.h"
#import "UCLSummaryTypesViewController.h"
#import "UCLSummarizer.h"

@interface UCLActorsViewController ()

-(void)configureView;

@end

@implementation UCLActorsViewController
{
    __weak UIPopoverController* _popoverController;
    __strong NSArray* _summary;
}

#pragma mark - Properties

@synthesize actorViewController = _actorViewController;
@synthesize fight = _fight;
@synthesize summaryType = _summaryType;
@synthesize summaryTypeButton = _summaryTypeButton;

-(void)setFight:(UCLFight *)fight
{
    _fight = fight;
    [self configureView];
}

- (void)setSummaryType:(NSString *)summaryType
{
    if (_popoverController) {
        [_popoverController dismissPopoverAnimated:TRUE];
    }
    _summaryType = summaryType;
    self.summaryTypeButton.title = summaryType;
    [self configureView];
}

#pragma mark - View methods

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Set default summary type, which then configures the view.
    self.summaryType = @"DPS";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.summaryTypeButton = nil;
    self.fight = nil;

    _summary = nil;
    _popoverController = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (_popoverController) {
        [_popoverController dismissPopoverAnimated:TRUE];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

# pragma mark - Private methods

-(void)configureView
{
    if (self.fight != nil) {
        UCLSummarizer* summarizer = [UCLSummarizer summarizerForFight:self.fight];
        if ([self.summaryType isEqualToString:@"DPS"]) {
            _summary = [summarizer summarizeForType:DPS];
        }
        else if ([self.summaryType isEqualToString:@"HPS"]) {
            _summary = [summarizer summarizeForType:HPS];
        }
    }
    else {
        _summary = nil;
    }
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_summary count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ActorCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    UCLSummaryEntry* summaryEntry = [_summary objectAtIndex:indexPath.row];
    UCLEntity* actor = summaryEntry.item;
    cell.textLabel.text = actor.name;
    cell.detailTextLabel.text = [summaryEntry.amount stringValue];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UCLSummaryEntry* summaryEntry = [_summary objectAtIndex:indexPath.row];
    UCLEntity* actor = summaryEntry.item;
    NSArray* events = [self.fight allEventsForEntity:actor];
    [self.actorViewController setActor:actor events:events];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SummaryTypes"]) {
        _popoverController = [(UIStoryboardPopoverSegue*)segue popoverController];
        UCLSummaryTypesViewController* vc = [segue destinationViewController];
        vc.actorsViewController = self;
    }
}

#pragma mark - Actions

- (IBAction)showSummaryTypes:(id)sender {
    if (_popoverController) {
        [_popoverController dismissPopoverAnimated:TRUE];
    }
    else {
        [self performSegueWithIdentifier:@"SummaryTypes" sender:sender];
    }
}


@end
