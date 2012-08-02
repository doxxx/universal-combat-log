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

@property (strong, nonatomic) NSArray* summary;

-(void)configureView;

@end

@implementation UCLActorsViewController
{
    __weak UIPopoverController* _popoverController;
}

@synthesize fight = _fight;
@synthesize summaryType = _summaryType;
@synthesize metricButton = _metricButton;
@synthesize summary = _summary;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _summaryType = @"DPS";
    }
    return self;
}

-(void)setFight:(UCLFight *)fight
{
    _fight = fight;
    [self configureView];
}

- (void)setSummaryType:(NSString *)summaryType
{
    _summaryType = summaryType;
    self.metricButton.title = summaryType;
    [self configureView];
}

-(void)configureView
{
    if (self.fight != nil) {
        UCLSummarizer* summarizer = [UCLSummarizer summarizerForFight:self.fight];
        if ([self.summaryType isEqualToString:@"DPS"]) {
            self.summary = [summarizer summarizeForType:DPS];
        }
        else if ([self.summaryType isEqualToString:@"HPS"]) {
            self.summary = [summarizer summarizeForType:HPS];
        }
    }
    else {
        self.summary = nil;
    }
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.summaryType = @"DPS";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;

    self.metricButton = nil;
    self.fight = nil;
    self.summary = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.summary count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ActorCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    UCLSummaryEntry* summaryEntry = [self.summary objectAtIndex:indexPath.row];
    
    cell.textLabel.text = summaryEntry.name;
    cell.detailTextLabel.text = [summaryEntry.amount stringValue];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    _popoverController = [(UIStoryboardPopoverSegue*)segue popoverController];
    UCLSummaryTypesViewController* vc = [segue destinationViewController];
    vc.actorsViewController = self;
    vc.popoverController = _popoverController;
}

- (IBAction)metricSelected:(id)sender {
    if (_popoverController) {
        [_popoverController dismissPopoverAnimated:TRUE];
    }
    else {
        [self performSegueWithIdentifier:@"SummaryTypes" sender:sender];
    }
//    if ([self.metricButton.title isEqualToString:@"DPS"]) {
//        self.metricButton.title = @"HPS";
//    }
//    else if ([self.metricButton.title isEqualToString:@"HPS"]) {
//        self.metricButton.title = @"DPS";
//    }
//    [self configureView];
}

@end
