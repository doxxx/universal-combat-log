//
//  UCLLineChart.h
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-08-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UCLLineChartView;

@protocol UCLLineChartViewDelegate <NSObject>

@optional

- (void)lineChartView:(UCLLineChartView*)lineChartView didZoomToRange:(NSRange)range;

@end

@interface UCLLineChartView : UIView <UIGestureRecognizerDelegate>

@property (weak, nonatomic) id <UCLLineChartViewDelegate> delegate;
@property (copy, nonatomic) NSArray* data;

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;

@end
