//
//  UCLLineChart.m
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-08-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreText/CoreText.h>

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
    if (data != nil) {
        _data = [data copy];
        _maxValue = [_data objectAtIndex:0];
        for (NSNumber* value in _data) {
            if ([value compare:_maxValue] == NSOrderedDescending) {
                _maxValue = value;
            }
        }
        
        double yInterval = pow(10, floor(log10([_maxValue doubleValue])));
        double yIntervalCount = [_maxValue doubleValue] / yInterval;
        if (yIntervalCount < 3) {
            yInterval /= 5;
        }
        else if (yIntervalCount < 8) {
            yInterval /= 2;
        }
        self.yInterval = yInterval;
        
        double xInterval = MAX(1, round(floor([_data count] / 10) / 15) * 15);
        while ([_data count] / xInterval > 20) {
            xInterval *= 2;
        }
        self.xInterval = xInterval;
    }
    else {
        _data = nil;
        _maxValue = nil;
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

    // Flip co-ordinate system to bottom left going up and right.
    CGContextTranslateCTM(c, 0, bounds.size.height);
    CGContextScaleCTM(c, 1, -1);
    
    CGFloat xScale = 1;
    CGFloat yScale = 1;

    if (self.data != nil) {
        xScale = chartWidth / ([self.data count] - 1);
        yScale = chartHeight / [_maxValue doubleValue];
        
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
    }
    
    // Draw axes.
    CGContextSetStrokeColorWithColor(c, [UIColor lightGrayColor].CGColor);
    CGContextSetLineWidth(c, 1);
    CGContextSetLineJoin(c, kCGLineJoinMiter);
    CGContextSetLineCap(c, kCGLineCapSquare);
    
    CGContextMoveToPoint(c, LINSET, YINSET + chartHeight);
    CGContextAddLineToPoint(c, LINSET, YINSET);
    CGContextAddLineToPoint(c, LINSET + chartWidth, YINSET);
    CGContextStrokePath(c);
    
    if (_maxValue != nil) {
        // Draw markers on axes.
        CTFontRef axisMarkerFont = CTFontCreateUIFontForLanguage(kCTFontSystemFontType, 12, NULL);
        CGColorRef axisMarkerColor = [UIColor whiteColor].CGColor;
        NSDictionary* axisMarkerAttr = [NSDictionary dictionaryWithObjectsAndKeys:
                                        (__bridge id)axisMarkerFont, kCTFontAttributeName,
                                        axisMarkerColor, kCTForegroundColorAttributeName, nil];
        
        NSUInteger yMarkerCount = floor([_maxValue doubleValue] / self.yInterval);
        for (NSUInteger i = 1; i <= yMarkerCount; i++) {
            CGFloat y = YINSET + (i * self.yInterval) * yScale;
            CGContextMoveToPoint(c, LINSET, y);
            CGContextAddLineToPoint(c, LINSET - MARKER_LENGTH, y);
            CGContextStrokePath(c);

            NSString* markerLabel = [NSString stringWithFormat:@"%0.0f", (i * self.yInterval)];
            NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:markerLabel 
                                                                          attributes:axisMarkerAttr];
            CTLineRef line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)attrStr);
            CGRect labelRect = CTLineGetImageBounds(line, c);
            CGContextSetTextPosition(c, LINSET - MARKER_LENGTH - labelRect.size.width - 4, y - labelRect.size.height/2);
            CTLineDraw(line, c);
            CFRelease(line);
        }
        
        NSUInteger xMarkerCount = floor([self.data count] / self.xInterval);
        for (NSUInteger i = 1; i <= xMarkerCount; i++) {
            CGFloat x = LINSET + (i * self.xInterval) * xScale;
            CGContextMoveToPoint(c, x, YINSET);
            CGContextAddLineToPoint(c, x, YINSET - MARKER_LENGTH);
            CGContextStrokePath(c);

            double value = i * self.xInterval;
            double minutes = floor(value / 60.0);
            double seconds = round((value / 60.0 - minutes) * 60);
            NSString* markerLabel = [NSString stringWithFormat:@"%.0f:%02.f", minutes, seconds];
            NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:markerLabel 
                                                                          attributes:axisMarkerAttr];
            CTLineRef line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)attrStr);
            CGRect labelRect = CTLineGetImageBounds(line, c);
            CGContextSetTextPosition(c, x - labelRect.size.width/2, YINSET - MARKER_LENGTH - labelRect.size.height - 4);
            CTLineDraw(line, c);
            CFRelease(line);
        }

        CFRelease(axisMarkerFont);
    }
}

@end
