//
//  UCLMasterViewController.h
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-07-19.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UCLFightViewController;

#import <CoreData/CoreData.h>

#import "UCLLogFile.h"

@interface UCLLogsViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) UCLFightViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (readwrite, strong, nonatomic) UCLLogFile* logFile;

@end
