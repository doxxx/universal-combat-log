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
#import "UCLNetworkClient.h"

@implementation UCLLogsViewController
{
    NSMutableArray* _logFileURLs;
    UCLNetworkClient* _networkClient;
}

#pragma mark - Properties

@synthesize actorViewController = _actorViewController;
@synthesize documentsDirectory = _applicationDocumentsDirectory;

#pragma mark - View methods

- (void)awakeFromNib
{
    _logFileURLs = [NSMutableArray array];
    _networkClient = [[UCLNetworkClient alloc] init];
    
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.actorViewController = (UCLActorViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)viewWillAppear:(BOOL)animated
{
    __weak NSMutableArray* urls = _logFileURLs;
    _networkClient.discoveryCallback = ^(NSURL* url) {
        [urls addObject:url];
        [self.tableView reloadData];
    };

    [self refresh:nil];

    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    _networkClient.discoveryCallback = NULL;
    [super viewWillDisappear:animated];
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
    if ([[url scheme] isEqualToString:@"ucl"]) {
        cell.textLabel.text = [url host];
        cell.detailTextLabel.text = @"Network Server";
    }
    else {
        NSFileManager* fm = [NSFileManager defaultManager];
        cell.textLabel.text = [fm displayNameAtPath:[url path]];
        NSError* error;
        NSDictionary* attr = [fm attributesOfItemAtPath:[url path] error:&error];
        NSDateFormatter* df = [[NSDateFormatter alloc] init];
        [df setDateStyle:NSDateFormatterShortStyle];
        [df setTimeStyle:NSDateFormatterShortStyle];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [df stringFromDate:[attr objectForKey:NSFileModificationDate]]];
    }
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
            vc.url = [_logFileURLs objectAtIndex:cell.tag];
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
        [[[UIAlertView alloc] initWithTitle:@"UCL" 
                                   message:[error localizedDescription] 
                                  delegate:nil 
                         cancelButtonTitle:@"OK" 
                         otherButtonTitles:nil] show];
        return;
    }
    
    [_logFileURLs addObjectsFromArray:[contents filteredArrayUsingPredicate:
                                       [NSPredicate predicateWithFormat:@"path endswith '.ucl'"]]];
    
    NSLog(@"Found %d UCL files", [_logFileURLs count]);
    
}

- (IBAction)refresh:(id)sender {
    [_logFileURLs removeAllObjects];
    [self scanDocumentsDirectory];
    [_networkClient discoverServers];
    [self.tableView reloadData];
}
@end
