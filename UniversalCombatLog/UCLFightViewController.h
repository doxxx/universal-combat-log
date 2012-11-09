//
//  UCLFIghtViewController.h
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-10-23.
//  Copyright (c) 2012 Gordon Tyler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UCLLineChartView.h"
#import "UCLFight.h"
#import "UCLSummaryTypesViewController.h"
#import "UCLActorsViewController.h"

@interface UCLFightViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UCLSummaryTypesViewDelegate,UCLActorsViewDelegate>

@property (strong, nonatomic) UCLFight* fight;

@property (weak, nonatomic) IBOutlet UCLLineChartView *fightLineChartView;
@property (weak, nonatomic) IBOutlet UITableView *playersTableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *playersTableModeToggleControl;

- (IBAction)playerTableModeToggled:(UISegmentedControl *)sender;

@end
