//
//  UCLActorsViewController.h
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-08-01.
//  Copyright (c) 2012 Gordon Tyler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UCLSummaryTypesViewController.h"
#import "UCLFight.h"

@class UCLActorsViewController;

@protocol UCLActorsViewDelegate <NSObject>

- (void)actorsView:(UCLActorsViewController*)actorsView didSelectActor:(UCLEntity*)actor;
- (void)actorsView:(UCLActorsViewController*)actorsView didDeselectActor:(UCLEntity*)actor;

@end

@interface UCLActorsViewController : UITableViewController<UINavigationControllerDelegate>

@property (weak, nonatomic) id<UCLActorsViewDelegate> delegate;
@property (strong, nonatomic) UCLFight* fight;
@property (nonatomic) UCLSummaryType summaryType;
@property (strong, nonatomic) UCLEntity* selectedActor;

- (void)setFight:(UCLFight *)fight summaryType:(UCLSummaryType)summaryType;

@end
