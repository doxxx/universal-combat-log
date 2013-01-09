//
//  UCLMasterViewController.h
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-07-19.
//  Copyright (c) 2012 Gordon Tyler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UCLFightViewController.h"
#import "UCLLogFile.h"

@interface UCLLogsViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) UCLFightViewController* fightViewController;
@property (strong, nonatomic) NSURL* documentsDirectory;

@property (weak, nonatomic) IBOutlet UITableView *logsTableView;

- (void)navigateToLogFile:(UCLLogFile*)logFile;

- (IBAction)refresh:(id)sender;

@end
