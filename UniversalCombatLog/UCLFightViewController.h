//
//  UCLDetailViewController.h
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-07-19.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UCLFight.h"

@interface UCLFightViewController : UIViewController <UISplitViewControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (readwrite, weak, nonatomic) UCLFight* fight;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *selectorControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)selectorChanged:(UISegmentedControl *)sender;

@end
