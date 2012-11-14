//
//  UCLLineChart.h
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-08-03.
//  Copyright (c) 2012 Gordon Tyler. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UCLLineChartView;

@protocol UCLLineChartViewDelegate <NSObject>

@optional

- (void)lineChartView:(UCLLineChartView*)lineChartView didZoomToRange:(NSRange)range;

@end

@interface UCLLineChartView : UIView <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet id <UCLLineChartViewDelegate> delegate;
@property (nonatomic, getter = isRotating) BOOL rotating;

- (void)addLineWithValues:(NSArray*)values forKey:(NSString*)key;
- (void)removeLineForKey:(NSString*)key;
- (void)removeAllLines;
- (void)resetView;

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;


@end
