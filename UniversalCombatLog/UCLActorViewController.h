//
//  UCLActorViewController.h
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-08-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UCLLineChartView.h"
#import "UCLPieChartView.h"

#import "UCLEntity.h"
#import "UCLFight.h"

@interface UCLActorViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, readonly, nonatomic) UCLEntity* actor;
@property (strong, readonly, nonatomic) UCLFight* fight;

@property (weak, nonatomic) IBOutlet UCLLineChartView *lineChartView;
@property (weak, nonatomic) IBOutlet UCLPieChartView *pieChartView;

- (void)setActor:(UCLEntity*)actor fight:(UCLFight*)fight;

@end
