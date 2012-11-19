//
//  UCLFightsViewController.h
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-07-25.
//  Copyright (c) 2012 Gordon Tyler. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UCLFightViewController.h"
#import "UCLLogFile.h"

@interface UCLFightsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) UCLFightViewController* fightViewController;
@property (strong, nonatomic) NSURL* url;
@property (strong, nonatomic) UCLLogFile* logFile;

@property (weak, nonatomic) IBOutlet UITableView *fightsTableView;

- (IBAction)refresh:(id)sender;

@end
