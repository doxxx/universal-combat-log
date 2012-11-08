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
#import "UCLActorViewController.h"
#import "UCLNetworkClient.h"

@implementation UCLLogsViewController
{
    NSMutableArray* _logFileEntries;
    NSMutableArray* _networkServerEntries;
    UCLNetworkClient* _networkClient;
}

#pragma mark - Properties

@synthesize actorViewController;
@synthesize documentsDirectory;
@synthesize localFilesTableView;
@synthesize networkServersTableView;

#pragma mark - View methods

- (void)awakeFromNib
{
    _logFileEntries = [NSMutableArray array];
    _networkServerEntries = [NSMutableArray array];
    _networkClient = [[UCLNetworkClient alloc] init];
    
    [super awakeFromNib];
}

- (void)viewDidUnload {
    self.localFilesTableView = nil;
    self.networkServersTableView = nil;
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
                [self.networkServersTableView reloadData];
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
    if (tableView == self.localFilesTableView) {
        return [_logFileEntries count];
    }
    else if (tableView == self.networkServersTableView) {
        return [_networkServerEntries count];
    }

    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.localFilesTableView) {
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
    else if (tableView == self.networkServersTableView) {
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
    if ([[segue identifier] isEqualToString:@"LocalFile"]) {
        UCLFightsViewController* vc = [segue destinationViewController];
//        vc.actorViewController = self.actorViewController;
        if ([sender isKindOfClass:[UITableViewCell class]]) {
            UITableViewCell* cell = sender;
            NSDictionary* entry = [_logFileEntries objectAtIndex:cell.tag];
            NSURL* url = [entry objectForKey:@"url"];
            vc.url = url;
        }
    }
    else if ([[segue identifier] isEqualToString:@"NetworkServer"]) {
        UCLFightsViewController* vc = [segue destinationViewController];
//        vc.actorViewController = self.actorViewController;
        if ([sender isKindOfClass:[UITableViewCell class]]) {
            UITableViewCell* cell = sender;
            NSDictionary* entry = [_networkServerEntries objectAtIndex:cell.tag];
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
    
    [self.localFilesTableView reloadData];
    [self.networkServersTableView reloadData];
}

- (IBAction)sourceChanged:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
            self.localFilesTableView.hidden = NO;
            self.networkServersTableView.hidden = YES;
            break;
            
        case 1:
            self.localFilesTableView.hidden = YES;
            self.networkServersTableView.hidden = NO;
            break;
            
        default:
            break;
    }
}

@end
