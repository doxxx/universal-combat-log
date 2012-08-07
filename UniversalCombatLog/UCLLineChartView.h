//
//  UCLLineChart.h
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-08-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UCLLineChartView : UIView

@property (nonatomic) double xInterval;
@property (nonatomic) double yInterval;
@property (copy, nonatomic) NSArray* data;

@end
