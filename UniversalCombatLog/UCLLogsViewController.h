//
//  UCLMasterViewController.h
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-07-19.
//  Copyright (c) 2012 Gordon Tyler. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UCLFightViewController.h"

@interface UCLLogsViewController : UIViewController

@property (strong, nonatomic) UCLFightViewController* fightViewController;
@property (strong, nonatomic) NSURL* documentsDirectory;

@property (weak, nonatomic) IBOutlet UITableView *localFilesTableView;
@property (weak, nonatomic) IBOutlet UITableView *networkServersTableView;

- (IBAction)refresh:(id)sender;
- (IBAction)sourceChanged:(UISegmentedControl *)sender;

@end
