//
//  UCLFightsViewController.h
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-07-25.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UCLFightViewController.h"
#import "UCLActorsViewController.h"

@interface UCLFightsViewController : UITableViewController

@property (readwrite, weak, nonatomic) NSArray* fights;
@property (readwrite, weak, nonatomic) UCLActorsViewController* actorsViewController;

@end
