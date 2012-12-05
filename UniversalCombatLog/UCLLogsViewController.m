//
//  UCLMasterViewController.m
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-07-19.
//  Copyright (c) 2012 Gordon Tyler. All rights reserved.
//

#import "UCLLogsViewController.h"

#import "UCLLogFileLoader.h"
#import "UCLFightsViewController.h"
#import "UCLNetworkClient.h"

@implementation UCLLogsViewController
{
    NSArray* _tableViewSectionTitles;
    NSMutableArray* _logFileEntries;
    NSMutableArray* _networkServerEntries;
    UCLNetworkClient* _networkClient;
    UCLLogFile* _preloadedLogFile;
}

#pragma mark - Properties

@synthesize fightViewController;
@synthesize documentsDirectory;
@synthesize logsTableView;

#pragma mark - View methods

- (void)awakeFromNib
{
    self.documentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    _tableViewSectionTitles = [NSArray arrayWithObjects:@"Local Files", @"Network Servers", nil];
    _logFileEntries = [NSMutableArray array];
    _networkServerEntries = [NSMutableArray array];
    _networkClient = [[UCLNetworkClient alloc] init];
    
    [super awakeFromNib];
}

- (void)viewDidUnload {
    self.logsTableView = nil;
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    __weak NSMutableArray* networkServerEntries = _networkServerEntries;
    __weak UCLNetworkClient* networkClient = _networkClient;
    _networkClient.discoveryCallback = ^(NSURL* url) {
        [networkClient listLogFilesAtURL:url withCallback:^(NSArray* entries) {
            [networkServerEntries addObjectsFromArray:entries];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.logsTableView reloadData];
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
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0 && _logFileEntries.count == 0) {
        return nil;
    }
    if (section == 1 && _networkServerEntries.count == 0) {
        return nil;
    }
    return [_tableViewSectionTitles objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [_logFileEntries count];
    }
    else if (section == 1) {
        return [_networkServerEntries count];
    }

    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        
        NSDictionary* entry = [_logFileEntries objectAtIndex:indexPath.row];
//        NSString* title = [entry objectForKey:@"title"];
        NSURL* url = [entry objectForKey:@"url"];
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
    else if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        
        NSDictionary* entry = [_networkServerEntries objectAtIndex:indexPath.row];
        NSString* title = [entry objectForKey:@"title"];
        NSURL* url = [entry objectForKey:@"url"];
        cell.textLabel.text = title;
        cell.detailTextLabel.text = [url host];
        cell.tag = indexPath.row;
        
        return cell;
    }
    
    return nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"Fights"]) {
        UCLFightsViewController* vc = [segue destinationViewController];
        vc.fightViewController = self.fightViewController;
        if ([sender isKindOfClass:[UITableViewCell class]]) {
            NSIndexPath* indexPath = [self.logsTableView indexPathForCell:sender];
            NSDictionary* entry;
            if (indexPath.section == 0) {
                entry = [_logFileEntries objectAtIndex:indexPath.row];
            }
            else if (indexPath.section == 1) {
                entry = [_networkServerEntries objectAtIndex:indexPath.row];
            }
            NSURL* url = [entry objectForKey:@"url"];
            vc.url = url;
        }
        else if (_preloadedLogFile) {
            vc.logFile = _preloadedLogFile;
        }
        _preloadedLogFile = nil;
    }
}

- (void)navigateToLogFile:(UCLLogFile*)logFile;
{
    _preloadedLogFile = logFile;
    [self performSegueWithIdentifier:@"Fights" sender:nil];
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
    [_networkServerEntries removeAllObjects];
    
    [self scanDocumentsDirectory];
    [_networkClient discoverServers];
    
    [self.logsTableView reloadData];
}

@end
