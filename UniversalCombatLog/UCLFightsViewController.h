//
//  UCLFightsViewController.h
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-07-25.
//  Copyright (c) 2012 Gordon Tyler. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UCLActorViewController.h"

@interface UCLFightsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (readwrite, strong, nonatomic) NSURL* url;
@property (readwrite, strong, nonatomic) NSArray* fights;
@property (weak, nonatomic) IBOutlet UITableView *fightsTableView;

- (IBAction)refresh:(id)sender;

@end
