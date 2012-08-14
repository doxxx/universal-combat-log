//
//  UCLPieChartView.h
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-08-08.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UCLPieChartViewDelegate;

@interface UCLPieChartView : UIView

@property (weak, nonatomic) id <UCLPieChartViewDelegate> delegate;
@property (copy, nonatomic) NSArray* data;

- (void)selectSegment:(NSUInteger)segmentIndex;

@end


@protocol UCLPieChartViewDelegate <NSObject>

@required

- (UIColor*) pieChartView:(UCLPieChartView*)pieChartView colorForSegment:(NSUInteger)segmentIndex;

@optional

- (void)pieChartView:(UCLPieChartView*)pieChartView didSelectSegmentAtIndex:(NSUInteger)segmentIndex;

@end

