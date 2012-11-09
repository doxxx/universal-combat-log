//
//  UCLSummaryTypesViewController.h
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-08-02.
//  Copyright (c) 2012 Gordon Tyler. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    UCLSummaryDPS,
    UCLSummaryHPS
} UCLSummaryType;

@protocol UCLSummaryTypesViewDelegate <NSObject>

- (void)setSummaryType:(UCLSummaryType)summaryType;

@end

@interface UCLSummaryTypesViewController : UITableViewController

@property (weak, nonatomic) id<UCLSummaryTypesViewDelegate> delegate;

@end
