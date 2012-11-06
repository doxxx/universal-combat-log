//
//  UCLActorsViewController.h
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-08-01.
//  Copyright (c) 2012 Gordon Tyler. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UCLActorViewController.h"

#import "UCLFight.h"

@class UCLActorsViewController;

@protocol UCLActorsViewDelegate <NSObject>

- (void)actorsView:(UCLActorsViewController*)actorsView didSelectActor:(UCLEntity*)actor;

@end

@interface UCLActorsViewController : UITableViewController<UINavigationControllerDelegate>

@property (strong, nonatomic) UCLFight* fight;
@property (strong, nonatomic) NSString* summaryType;
@property (weak, nonatomic) id<UCLActorsViewDelegate> delegate;

- (UCLEntity*)selectedActor;
- (void)setSelectedActor:(UCLEntity*)actor;

@end
