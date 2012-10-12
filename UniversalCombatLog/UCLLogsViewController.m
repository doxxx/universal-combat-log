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
    NSMutableArray* _logFileEntries;
    UCLNetworkClient* _networkClient;
}

#pragma mark - Properties

@synthesize actorViewController = _actorViewController;
@synthesize documentsDirectory = _applicationDocumentsDirectory;

#pragma mark - View methods

- (void)awakeFromNib
{
    _logFileEntries = [NSMutableArray array];
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
    __weak NSMutableArray* logFileEntries = _logFileEntries;
    __weak UCLNetworkClient* networkClient = _networkClient;
    _networkClient.discoveryCallback = ^(NSURL* url) {
        [networkClient listLogFilesAtURL:url withCallback:^(NSArray* entries) {
            [logFileEntries addObjectsFromArray:entries];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
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
    return [_logFileEntries count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LogCell"];
    
    NSDictionary* entry = [_logFileEntries objectAtIndex:indexPath.row];
    NSString* title = [entry objectForKey:@"title"];
    NSURL* url = [entry objectForKey:@"url"];
    if ([[url scheme] isEqualToString:@"file"]) {
        NSFileManager* fm = [NSFileManager defaultManager];
        cell.textLabel.text = [fm displayNameAtPath:[url path]];
        NSError* error;
        NSDictionary* attr = [fm attributesOfItemAtPath:[url path] error:&error];
        NSDateFormatter* df = [[NSDateFormatter alloc] init];
        [df setDateStyle:NSDateFormatterShortStyle];
        [df setTimeStyle:NSDateFormatterShortStyle];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [df stringFromDate:[attr objectForKey:NSFileModificationDate]]];
    }
    else {
        cell.textLabel.text = title;
        cell.detailTextLabel.text = [url host];
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
            NSDictionary* entry = [_logFileEntries objectAtIndex:cell.tag];
            NSURL* url = [entry objectForKey:@"url"];
            vc.url = url;
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
    
    NSArray* files = [contents filteredArrayUsingPredicate:
                      [NSPredicate predicateWithFormat:@"path endswith '.ucl'"]];
    for (NSURL* url in files) {
        NSDictionary* entry = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"title", url, @"url", nil];
        [_logFileEntries addObject:entry];
    }
    
    NSLog(@"Found %d UCL files", [files count]);
    
}

- (IBAction)refresh:(id)sender {
    [_logFileEntries removeAllObjects];
    [self scanDocumentsDirectory];
    [_networkClient discoverServers];
    [self.tableView reloadData];
}
@end
