//
//  UCLPieChartView.h
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-08-08.
//  Copyright (c) 2012 Gordon Tyler. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UCLPieChartViewDelegate;

@interface UCLPieChartView : UIView

@property (weak, nonatomic) IBOutlet id <UCLPieChartViewDelegate> delegate;
@property (copy, nonatomic) NSArray* data;

- (void)selectSegment:(NSInteger)segmentIndex;

@end


@protocol UCLPieChartViewDelegate <NSObject>

- (UIColor*) pieChartView:(UCLPieChartView*)pieChartView colorForSegment:(NSInteger)segmentIndex;

@optional

- (void)pieChartView:(UCLPieChartView*)pieChartView didSelectSegmentAtIndex:(NSInteger)segmentIndex;

@end
