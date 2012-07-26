//
//  UCLDetailViewController.h
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-07-19.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UCLFight.h"

@interface UCLFightViewController : UIViewController <UISplitViewControllerDelegate>

@property (readwrite, weak, nonatomic) UCLFight* fight;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end
