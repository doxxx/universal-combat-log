//
//  UCLMasterViewController.h
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-07-19.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "UCLActorViewController.h"
#import "UCLLogFile.h"

@interface UCLLogsViewController : UITableViewController

@property (strong, nonatomic) UCLActorViewController* actorViewController;
@property (strong, nonatomic) NSURL* documentsDirectory;

- (IBAction)refresh:(id)sender;

@end
