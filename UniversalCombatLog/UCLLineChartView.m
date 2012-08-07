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

@synthesize xInterval = _xInterval;
@synthesize yInterval = _yInterval;
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

#define LINSET 40
#define RINSET 30
#define YINSET 30
#define MARKER_LENGTH 5

- (void)drawRect:(CGRect)rect
{
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    CGRect bounds = [self bounds];
    CGFloat chartWidth = bounds.size.width - (LINSET + RINSET);
    CGFloat chartHeight = bounds.size.height - YINSET*2;
    CGFloat xScale = chartWidth / ([self.data count] - 1);
    CGFloat yScale = chartHeight / [_maxValue doubleValue];
    
    // Flip co-ordinate system to bottom left going up and right.
    CGContextTranslateCTM(c, 0, bounds.size.height);
    CGContextScaleCTM(c, 1, -1);
    
    // Draw data line.
    CGContextSetRGBStrokeColor(c, 0, 1, 0, 1);
    CGContextSetLineWidth(c, 2);
    CGContextSetLineJoin(c, kCGLineJoinRound);
    CGContextSetLineCap(c, kCGLineCapRound);
    
    int count = 0;
    for (NSNumber* value in self.data) {
        CGFloat x = LINSET + xScale * count;
        CGFloat y = YINSET + [value doubleValue] * yScale;
        if (count == 0) {
            CGContextMoveToPoint(c, x, y);
        }
        else {
            CGContextAddLineToPoint(c, x, y);
        }
        count++;
    }
    
    CGContextStrokePath(c);
    
    // Draw axes.
    CGContextSetRGBStrokeColor(c, 0.8, 0.8, 0.8, 1);
    CGContextSetLineWidth(c, 1);
    CGContextSetLineJoin(c, kCGLineJoinMiter);
    CGContextSetLineCap(c, kCGLineCapSquare);
    
    CGContextMoveToPoint(c, LINSET, YINSET + chartHeight);
    CGContextAddLineToPoint(c, LINSET, YINSET);
    CGContextAddLineToPoint(c, LINSET + chartWidth, YINSET);
    CGContextStrokePath(c);
    
    UIFont* axisMarkerFont = [UIFont systemFontOfSize:10];
    
    // Draw markers on axes.
    NSUInteger yMarkerCount = floor([_maxValue doubleValue] / self.yInterval);
    for (NSUInteger i = 1; i <= yMarkerCount; i++) {
        CGFloat y = YINSET + (i * self.yInterval) * yScale;
        CGContextMoveToPoint(c, LINSET, y);
        CGContextAddLineToPoint(c, LINSET - MARKER_LENGTH, y);
        CGContextStrokePath(c);
    }
    
    NSUInteger xMarkerCount = floor([self.data count] / self.xInterval);
    for (NSUInteger i = 1; i <= xMarkerCount; i++) {
        CGFloat x = YINSET + (i * self.xInterval) * xScale;
        CGContextMoveToPoint(c, x, YINSET);
        CGContextAddLineToPoint(c, x, YINSET - MARKER_LENGTH);
        CGContextStrokePath(c);
    }
    
    // Reverse CTM so that text is not drawn upside down.
    CGContextScaleCTM(c, 1, -1);
    CGContextTranslateCTM(c, 0, -bounds.size.height);
    
    // Draw axis marker labels.
    CGContextSetRGBFillColor(c, 0.8, 0.8, 0.8, 1);
    for (NSUInteger i = 1; i <= yMarkerCount; i++) {
        CGFloat y = bounds.size.height - (YINSET + (i * self.yInterval) * yScale);
        NSString* markerLabel = [NSString stringWithFormat:@"%0.0f", (i * self.yInterval)];
        CGSize labelSize = [markerLabel sizeWithFont:axisMarkerFont];
        [markerLabel drawAtPoint:CGPointMake(LINSET - MARKER_LENGTH - labelSize.width, y - labelSize.height/2) 
                        withFont:axisMarkerFont];
    }
    
    for (NSUInteger i = 1; i <= xMarkerCount; i++) {
        CGFloat x = YINSET + (i * self.xInterval) * xScale;
        NSString* markerLabel = [NSString stringWithFormat:@"%0.0f", (i * self.xInterval)];
        CGSize labelSize = [markerLabel sizeWithFont:axisMarkerFont];
        [markerLabel drawAtPoint:CGPointMake(x - labelSize.width/2, bounds.size.height - YINSET + MARKER_LENGTH) 
                        withFont:axisMarkerFont];
    }
    
}

@end
