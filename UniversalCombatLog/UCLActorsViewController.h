//
//  UCLActorsViewController.h
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-08-01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UCLFight.h"

@interface UCLActorsViewController : UITableViewController

@property (weak, nonatomic) UCLFight* fight;
@property (strong, nonatomic) NSString* summaryType;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *metricButton;

- (IBAction)metricSelected:(id)sender;

@end
