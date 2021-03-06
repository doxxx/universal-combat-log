//
//  UCLFIghtViewController.h
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-10-23.
//  Copyright (c) 2012 Gordon Tyler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UCLLineChartView.h"
#import "UCLPieChartView.h"
#import "UCLLogFile.h"
#import "UCLFight.h"
#import "UCLSummaryTypesViewController.h"
#import "UCLActorsViewController.h"

@interface UCLFightViewController : UIViewController<UCLLineChartViewDelegate,UCLPieChartViewDelegate,UCLSummaryTypesViewDelegate,UCLActorsViewDelegate,UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) UCLFight* fight;

@property (weak, nonatomic) IBOutlet UCLLineChartView *fightLineChartView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *playersButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *summaryTypeButton;
@property (weak, nonatomic) IBOutlet UIView *playerDetailsView;
@property (weak, nonatomic) IBOutlet UCLPieChartView *spellPieChartView;
@property (weak, nonatomic) IBOutlet UITableView *spellTableView;
@property (weak, nonatomic) IBOutlet UIView *spellStatsView;
@property (weak, nonatomic) IBOutlet UILabel *spellMinLabel;
@property (weak, nonatomic) IBOutlet UILabel *spellMaxLabel;
@property (weak, nonatomic) IBOutlet UILabel *spellAvgLabel;
@property (weak, nonatomic) IBOutlet UILabel *spellHitsAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *spellCritsAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *spellMinAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *spellMaxAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *spellAvgAmountLabel;

- (void)showFight:(UCLFight *)fight inLogFile:(UCLLogFile *)logFile;

- (IBAction)showPlayersPopover:(id)sender;
- (IBAction)showSummaryTypesPopover:(id)sender;
- (IBAction)showLogsPopover:(id)sender;

@end
