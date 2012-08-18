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
    UIPinchGestureRecognizer* _zoomGestureRecognizer;
    UIPanGestureRecognizer* _panGestureRecognizer;
    NSNumber* _maxValue;
    CGFloat _leftInset;
    CGFloat _scale;
    CGFloat _offset;
    CGFloat _originalScale;
    CGFloat _originalOffset;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _zoomGestureRecognizer = [[UIPinchGestureRecognizer alloc] 
                                  initWithTarget:self action:@selector(handleZoomGesture:)];
        [self addGestureRecognizer:_zoomGestureRecognizer];
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc]
                                 initWithTarget:self action:@selector(handlePanGesture:)];
        _panGestureRecognizer.maximumNumberOfTouches = 1;
        [self addGestureRecognizer:_panGestureRecognizer];
    }
    return self;
}

#pragma mark - Properties

@synthesize delegate = _delegate;
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
        
        _offset = 0;
        _scale = 1;
    }
    else {
        _data = nil;
        _maxValue = nil;
    }
    [self setNeedsDisplay];
}

#define LINSET 30
#define RINSET 30
#define YINSET 30
#define MARKER_LENGTH 5

- (void)drawRect:(CGRect)rect
{
    if (self.data == nil) {
        return;
    }
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    CGRect bounds = [self bounds];

    // Flip co-ordinate system to bottom left going up and right.
    CGContextTranslateCTM(c, 0, bounds.size.height);
    CGContextScaleCTM(c, 1, -1);
    
    CGFloat leftInset = LINSET;
    
    CTFontRef axisMarkerFont = CTFontCreateUIFontForLanguage(kCTFontSystemFontType, 12, NULL);
    CGColorRef axisMarkerColor = [UIColor whiteColor].CGColor;
    NSDictionary* axisMarkerAttr = [NSDictionary dictionaryWithObjectsAndKeys:
                                    (__bridge id)axisMarkerFont, kCTFontAttributeName,
                                    axisMarkerColor, kCTForegroundColorAttributeName, nil];
    
    int numDigits = ceil(log10([_maxValue doubleValue]));
    NSString* biggestLabel = [NSString stringWithFormat:@"%0*d", numDigits, 0];
    NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:biggestLabel 
                                                                  attributes:axisMarkerAttr];
    CTLineRef line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)attrStr);
    CGRect labelRect = CTLineGetImageBounds(line, c);
    leftInset = MAX(leftInset, labelRect.size.width + MARKER_LENGTH + 8);
    _leftInset = leftInset;
    
    CGFloat chartWidth = bounds.size.width - (leftInset + RINSET);
    CGFloat chartHeight = bounds.size.height - YINSET*2;

    CGFloat xScale = chartWidth / [_data count] * _scale;
    CGFloat yScale = chartHeight / [_maxValue doubleValue];
    
    // Draw data line.
    CGContextSaveGState(c);
    CGContextSetRGBStrokeColor(c, 0, 1, 0, 1);
    CGContextSetLineWidth(c, 2);
    CGContextSetLineJoin(c, kCGLineJoinRound);
    CGContextSetLineCap(c, kCGLineCapRound);
    
    CGContextClipToRect(c, CGRectMake(leftInset, YINSET, chartWidth, chartHeight));
    
    NSUInteger index = 0;
    while (index < [_data count]) {
        NSNumber* value = [_data objectAtIndex:index];
        CGFloat x = leftInset + _offset + index * xScale;
        CGFloat y = YINSET + [value doubleValue] * yScale;
        if (index == 0) {
            CGContextMoveToPoint(c, x, y);
        }
        else {
            CGContextAddLineToPoint(c, x, y);
        }
        index++;
    }
    
    CGContextStrokePath(c);
    
    CGContextRestoreGState(c);
    
    // Draw axes.
    CGContextSetStrokeColorWithColor(c, [UIColor darkGrayColor].CGColor);
    CGContextSetLineWidth(c, 2);
    CGContextSetLineJoin(c, kCGLineJoinMiter);
    CGContextSetLineCap(c, kCGLineCapSquare);
    
    CGContextMoveToPoint(c, leftInset, YINSET + chartHeight);
    CGContextAddLineToPoint(c, leftInset, YINSET);
    CGContextAddLineToPoint(c, leftInset + chartWidth, YINSET);
    CGContextStrokePath(c);
    
    // Draw markers on axes.
    NSUInteger yMarkerCount = floor([_maxValue doubleValue] / self.yInterval);
    for (NSUInteger i = 1; i <= yMarkerCount; i++) {
        CGFloat y = YINSET + (i * self.yInterval) * yScale;
        CGContextMoveToPoint(c, leftInset, y);
        CGContextAddLineToPoint(c, leftInset - MARKER_LENGTH, y);
        CGContextStrokePath(c);

        NSString* markerLabel = [NSString stringWithFormat:@"%0.0f", (i * self.yInterval)];
        NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:markerLabel 
                                                                      attributes:axisMarkerAttr];
        CTLineRef line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)attrStr);
        CGRect labelRect = CTLineGetImageBounds(line, c);
        CGContextSetTextPosition(c, leftInset - MARKER_LENGTH - labelRect.size.width - 4, y - labelRect.size.height/2);
        CTLineDraw(line, c);
        CFRelease(line);
    }
    
    CGContextSaveGState(c);
    
    CGContextClipToRect(c, CGRectMake(leftInset, 0, chartWidth, bounds.size.height));

    for (NSUInteger i = _xInterval; i < [_data count] * _xInterval; i += _xInterval) {
        CGFloat x = leftInset + _offset + i * xScale;
        CGContextMoveToPoint(c, x, YINSET);
        CGContextAddLineToPoint(c, x, YINSET - MARKER_LENGTH);
        CGContextStrokePath(c);

        double minutes = floor(i / 60.0);
        double seconds = round((i / 60.0 - minutes) * 60);
        NSString* markerLabel = [NSString stringWithFormat:@"%.0f:%02.f", minutes, seconds];
        NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:markerLabel 
                                                                      attributes:axisMarkerAttr];
        CTLineRef line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)attrStr);
        CGRect labelRect = CTLineGetImageBounds(line, c);
        CGContextSetTextPosition(c, x - labelRect.size.width/2, YINSET - MARKER_LENGTH - labelRect.size.height - 4);
        CTLineDraw(line, c);
        CFRelease(line);
    }
    
    CGContextRestoreGState(c);

    CFRelease(axisMarkerFont);
}

- (void)handleZoomGesture:(UIPinchGestureRecognizer*)gestureRecognizer
{
    CGFloat scale = gestureRecognizer.scale;
    CGPoint loc = [gestureRecognizer locationInView:self];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        _originalScale = _scale;
        _originalOffset = _offset;
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        _offset = MIN(0, _offset);

        if ([self.delegate respondsToSelector:@selector(lineChartView:didZoomToRange:)]) {
            [self.delegate lineChartView:self didZoomToRange:[self makeRangeForVisibleData]];
        }
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        _scale = MAX(1, _originalScale * scale);
        
        CGFloat p = (loc.x - _leftInset);
        CGFloat newOffset = p - (p - _originalOffset) * _scale / _originalScale;
        
        _offset = newOffset;
        
        if ([self.delegate respondsToSelector:@selector(lineChartView:didZoomToRange:)]) {
            [self.delegate lineChartView:self didZoomToRange:[self makeRangeForVisibleData]];
        }
    }

    [self setNeedsDisplay];
}

- (void)handlePanGesture:(UIPanGestureRecognizer*)gestureRecognizer
{
    CGPoint translation = [gestureRecognizer translationInView:self];
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        _originalOffset = _offset;
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGRect bounds = [self bounds];
        CGFloat chartWidth = bounds.size.width - (_leftInset + RINSET);
        _offset = MIN(0, _offset);
        _offset = MAX((-chartWidth) * _scale + chartWidth, _offset);

        if ([self.delegate respondsToSelector:@selector(lineChartView:didZoomToRange:)]) {
            [self.delegate lineChartView:self didZoomToRange:[self makeRangeForVisibleData]];
        }
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        _offset = _originalOffset + translation.x;

        if ([self.delegate respondsToSelector:@selector(lineChartView:didZoomToRange:)]) {
            [self.delegate lineChartView:self didZoomToRange:[self makeRangeForVisibleData]];
        }
    }
    
    [self setNeedsDisplay];
}

- (NSRange)makeRangeForVisibleData
{
    CGRect bounds = [self bounds];
    CGFloat chartWidth = bounds.size.width - (_leftInset + RINSET);
    CGFloat xScale = chartWidth / [_data count] * _scale;
    CGFloat posOffset = _offset * -1;
    NSUInteger start = MAX(0, ceil(posOffset / xScale));
    NSUInteger length = MIN([_data count], floor((posOffset + chartWidth) / xScale) - start);
    return NSMakeRange(start, length);
}

@end
