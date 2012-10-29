//
//  UCLActorViewController.h
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-08-03.
//  Copyright (c) 2012 Gordon Tyler. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UCLLineChartView.h"
#import "UCLPieChartView.h"

#import "UCLEntity.h"
#import "UCLFight.h"

@interface UCLActorViewController : UIViewController <UISplitViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, UCLPieChartViewDelegate, UCLLineChartViewDelegate>

@property (strong, readonly, nonatomic) UCLEntity* actor;
@property (strong, readonly, nonatomic) UCLFight* fight;

@property (weak, nonatomic) IBOutlet UCLLineChartView *lineChartView;
@property (weak, nonatomic) IBOutlet UCLPieChartView *pieChartView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *detailView;
@property (weak, nonatomic) IBOutlet UILabel *hitPercentLabel;
@property (weak, nonatomic) IBOutlet UILabel *critPercentLabel;
@property (weak, nonatomic) IBOutlet UILabel *minDamageLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxDamageLabel;
@property (weak, nonatomic) IBOutlet UILabel *avgDamageLabel;

- (void)setActor:(UCLEntity*)actor fight:(UCLFight*)fight;

- (IBAction)swipeLeft:(UISwipeGestureRecognizer *)sender;
- (IBAction)swipeRight:(UISwipeGestureRecognizer *)sender;

@end
