//
//  UCLMasterViewController.m
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-07-19.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UCLLogsViewController.h"

#import "UCLLogFileLoader.h"
#import "UCLFightsViewController.h"
#import "UCLActorViewController.h"

@implementation UCLLogsViewController
{
    NSArray* _logFileURLs;
}

#pragma mark - Properties

@synthesize actorViewController = _actorViewController;
@synthesize documentsDirectory = _applicationDocumentsDirectory;

#pragma mark - View methods

- (void)awakeFromNib
{
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.actorViewController = (UCLActorViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    [self scanDocumentsDirectory];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self scanDocumentsDirectory];
    [self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_logFileURLs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LogCell"];
    
    NSURL* url = [_logFileURLs objectAtIndex:indexPath.row];
    NSFileManager* fm = [NSFileManager defaultManager];
    cell.textLabel.text = [fm displayNameAtPath:[url path]];
    NSError* error;
    NSDictionary* attr = [fm attributesOfItemAtPath:[url path] error:&error];
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterShortStyle];
    [df setTimeStyle:NSDateFormatterShortStyle];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [df stringFromDate:[attr objectForKey:NSFileModificationDate]]];
    cell.tag = indexPath.row;
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"LogToFights"]) {
        UCLFightsViewController* vc = [segue destinationViewController];
        vc.actorViewController = self.actorViewController;
        if ([sender isKindOfClass:[UITableViewCell class]]) {
            UITableViewCell* cell = sender;
            NSURL* url = [_logFileURLs objectAtIndex:cell.tag];
            vc.fights = [UCLLogFileLoader loadFromURL:url].fights;
        }
    }
}

- (void)scanDocumentsDirectory
{
    NSArray* props = [NSArray arrayWithObjects:NSURLLocalizedNameKey, NSURLCreationDateKey, nil];
    NSError* error = nil;
    NSArray* contents = [[NSFileManager defaultManager] 
                         contentsOfDirectoryAtURL:self.documentsDirectory 
                         includingPropertiesForKeys:props 
                         options:NSDirectoryEnumerationSkipsHiddenFiles 
                         error:&error];
    if (contents == nil) {
        // TODO: Handle error
        return;
    }
    
    _logFileURLs = [contents filteredArrayUsingPredicate:
                    [NSPredicate predicateWithFormat:@"path endswith '.ucl'"]];
    
    NSLog(@"Found %d UCL files", [_logFileURLs count]);
    
}

@end
