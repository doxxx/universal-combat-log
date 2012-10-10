//
//  UCLFightsViewController.h
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-07-25.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UCLActorViewController.h"

@interface UCLFightsViewController : UITableViewController

@property (readwrite, strong, nonatomic) NSURL* url;
@property (readwrite, strong, nonatomic) NSArray* fights;
@property (readwrite, weak, nonatomic) UCLActorViewController* actorViewController;

- (IBAction)refresh:(id)sender;

@end
