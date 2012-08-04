//
//  UCLLineChart.m
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-08-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UCLLineChartView.h"

@implementation UCLLineChartView
{
    NSNumber* _maxValue;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - Properties

@synthesize data = _data;

- (void)setData:(NSArray *)data
{
    _data = [data copy];
    _maxValue = [_data objectAtIndex:0];
    for (NSNumber* value in _data) {
        if ([value compare:_maxValue] == NSOrderedDescending) {
            _maxValue = value;
        }
    }
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    // Flip co-ordinate system to bottom left going up and right.
    CGContextTranslateCTM(c, 0, [self bounds].size.height);
    CGContextScaleCTM(c, 1, -1);

    // Set line color and style
    CGContextSetRGBStrokeColor(c, 0, 0, 0, 1);
    CGContextSetLineWidth(c, 2);
    CGContextSetLineJoin(c, kCGLineJoinRound);
    CGContextSetLineCap(c, kCGLineCapRound);

    
    CGFloat xStep = rect.size.width / ([self.data count] - 1);
    CGFloat yScale = rect.size.height / [_maxValue doubleValue];
    
    int count = 0;
    for (NSNumber* value in self.data) {
        CGFloat x = xStep * count;
        CGFloat y = [value doubleValue] * yScale;
        if (count == 0) {
            CGContextMoveToPoint(c, x, y);
        }
        else {
            CGContextAddLineToPoint(c, x, y);
        }
        count++;
    }
    
    CGContextStrokePath(c);
    
}

@end
