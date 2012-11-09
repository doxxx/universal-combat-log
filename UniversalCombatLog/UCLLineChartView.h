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

@interface UCLLineChartView : UIView <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet id <UCLLineChartViewDelegate> delegate;
@property (nonatomic, getter = isRotating) BOOL rotating;

- (void)addData:(NSArray*)data forKey:(NSString*)key;
- (void)removeDataForKey:(NSString*)key;
- (void)removeAllData;
- (void)resetView;

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;


@end
