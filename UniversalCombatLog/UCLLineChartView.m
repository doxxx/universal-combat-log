//
//  UCLLineChart.m
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-08-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreText/CoreText.h>
#import <QuartzCore/QuartzCore.h>

#import "UCLLineChartView.h"

#define LINSET 30
#define RINSET 30
#define YINSET 30
#define MARKER_LENGTH 5

@interface DataLayer : CALayer

@property (weak, nonatomic) NSArray* data;
@property (nonatomic) double maxValue;
@property (nonatomic) CGFloat offset;
@property (nonatomic) CGFloat scale;

@end

@implementation DataLayer

@synthesize data, maxValue;
@dynamic offset, scale;

- (id)initWithLayer:(id)layer
{
    self = [super initWithLayer:layer];
    if (self != nil) {
        if ([layer isKindOfClass:[DataLayer class]]) {
            DataLayer* other = layer;
            self.data = other.data;
            self.maxValue = other.maxValue;
            self.offset = other.offset;
            self.scale = other.scale;
        }
    }
    return self;
}

- (void)drawInContext:(CGContextRef)ctx
{
    if (data == nil) {
        return;
    }
    
    CGRect bounds = [self bounds];
    
    // Flip co-ordinate system to bottom left going up and right.
    CGContextTranslateCTM(ctx, 0, bounds.size.height);
    CGContextScaleCTM(ctx, 1, -1);
    
    CGFloat xScale = bounds.size.width / [data count] * self.scale;
    CGFloat yScale = bounds.size.height / self.maxValue;
    
    // Draw data line.
    CGContextSaveGState(ctx);
    CGContextSetRGBStrokeColor(ctx, 0, 1, 0, 1);
    CGContextSetLineWidth(ctx, 2);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    
    CGContextClipToRect(ctx, bounds);
    
    NSUInteger index = 0;
    while (index < [data count]) {
        NSNumber* value = [data objectAtIndex:index];
        CGFloat x = self.offset + index * xScale;
        CGFloat y = [value doubleValue] * yScale;
        if (index == 0) {
            CGContextMoveToPoint(ctx, x, y);
        }
        else {
            CGContextAddLineToPoint(ctx, x, y);
        }
        index++;
    }
    
    CGContextStrokePath(ctx);
    
    CGContextRestoreGState(ctx);

}

+ (BOOL)needsDisplayForKey:(NSString *)key
{
    if ([key isEqualToString:@"offset"] || [key isEqualToString:@"scale"]) {
        return YES;
    }
    else {
        return [super needsDisplayForKey:key];
    }
}

@end

////////////////////////////////////////////////////////////////////////////

@implementation UCLLineChartView
{
    DataLayer* _dataLayer;
    UIPinchGestureRecognizer* _zoomGestureRecognizer;
    UIPanGestureRecognizer* _panGestureRecognizer;
    double _maxValue;
    CGFloat _leftInset;
    CGFloat _originalScale;
    CGFloat _originalOffset;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _dataLayer = [DataLayer layer];
        [self.layer addSublayer:_dataLayer];
        _dataLayer.anchorPoint = CGPointMake(0, 0);
        _dataLayer.actions = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNull null], @"position", 
                               [NSNull null], @"bounds", 
                               [NSNull null], @"contents", 
                               nil];

        _maxValue = 0;
        
        [self configureLayers];

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
        
        _maxValue = [[_data objectAtIndex:0] doubleValue];
        for (NSNumber* value in _data) {
            double v = [value doubleValue];
            if (v > _maxValue) {
                _maxValue = v;
            }
        }
        
        double yInterval = pow(10, floor(log10(_maxValue)));
        double yIntervalCount = _maxValue / yInterval;
        if (yIntervalCount < 3) {
            yInterval /= 5;
        }
        else if (yIntervalCount < 8) {
            yInterval /= 2;
        }
        self.yInterval = yInterval;
        
        NSUInteger count = [_data count];
        double xInterval = MAX(1, round(floor(count / 10) / 15) * 15);
        while (count / xInterval > 20) {
            xInterval *= 2;
        }
        self.xInterval = xInterval;
        
        [self configureLayers];
    }
    else {
        _data = nil;
        _maxValue = 0;
    }
    [self.layer setNeedsDisplay];
    [_dataLayer setNeedsDisplay];
}

- (void)configureLayers
{
    CGRect bounds = [self bounds];

    int numDigits = 0;
    if (_maxValue > 0) {
        numDigits = ceil(log10(_maxValue));
    }
    NSString* biggestLabel = [NSString stringWithFormat:@"%0*d", numDigits, 0];
    CGRect labelRect = [UCLLineChartView boundsForString:biggestLabel];
    _leftInset = MAX(LINSET, labelRect.size.width + MARKER_LENGTH + 8);
    
    CGFloat chartWidth = bounds.size.width - (_leftInset + RINSET);
    CGFloat chartHeight = bounds.size.height - YINSET*2;
    _dataLayer.bounds = CGRectMake(0, 0, chartWidth, chartHeight);
    _dataLayer.position = CGPointMake(_leftInset, YINSET);

    _dataLayer.offset = 0;
    _dataLayer.scale = 1;
    
    _dataLayer.data = _data;
    _dataLayer.maxValue = _maxValue;
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    if (_data == nil) {
        return;
    }
    
    CGRect bounds = [self bounds];
    
    // Flip co-ordinate system to bottom left going up and right.
    CGContextTranslateCTM(ctx, 0, bounds.size.height);
    CGContextScaleCTM(ctx, 1, -1);
    
    CGFloat chartWidth = bounds.size.width - (_leftInset + RINSET);
    CGFloat chartHeight = bounds.size.height - YINSET*2;
    
    CGFloat scale = [[_dataLayer valueForKey:@"scale"] floatValue];
    CGFloat offset = [[_dataLayer valueForKey:@"offset"] floatValue];
    
    CGFloat xScale = chartWidth / [_data count] * scale;
    CGFloat yScale = chartHeight / _maxValue;
    
    // Draw axes.
    CGContextSetStrokeColorWithColor(ctx, [UIColor darkGrayColor].CGColor);
    CGContextSetLineWidth(ctx, 2);
    CGContextSetLineJoin(ctx, kCGLineJoinMiter);
    CGContextSetLineCap(ctx, kCGLineCapSquare);
    
    CGContextMoveToPoint(ctx, _leftInset, YINSET + chartHeight);
    CGContextAddLineToPoint(ctx, _leftInset, YINSET);
    CGContextAddLineToPoint(ctx, _leftInset + chartWidth, YINSET);
    CGContextStrokePath(ctx);
    
    // Draw markers on axes.
    NSDictionary* axisMarkerAttr = [UCLLineChartView axisMarkerLabelAttributes];
    NSUInteger yMarkerCount = floor(_maxValue / self.yInterval);
    for (NSUInteger i = 1; i <= yMarkerCount; i++) {
        CGFloat y = YINSET + (i * self.yInterval) * yScale;
        CGContextMoveToPoint(ctx, _leftInset, y);
        CGContextAddLineToPoint(ctx, _leftInset - MARKER_LENGTH, y);
        CGContextStrokePath(ctx);
        
        NSString* markerLabel = [NSString stringWithFormat:@"%0.0f", (i * self.yInterval)];
        NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:markerLabel 
                                                                      attributes:axisMarkerAttr];
        CTLineRef line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)attrStr);
        CGRect labelRect = CTLineGetImageBounds(line, ctx);
        CGContextSetTextPosition(ctx, _leftInset - MARKER_LENGTH - labelRect.size.width - 4, y - labelRect.size.height/2);
        CTLineDraw(line, ctx);
        CFRelease(line);
    }
    
    CGContextSaveGState(ctx);
    
    CGContextClipToRect(ctx, CGRectMake(_leftInset, 0, chartWidth, bounds.size.height));
    
    for (NSUInteger i = _xInterval; i < [_data count] * _xInterval; i += _xInterval) {
        CGFloat x = _leftInset + offset + i * xScale;
        CGContextMoveToPoint(ctx, x, YINSET);
        CGContextAddLineToPoint(ctx, x, YINSET - MARKER_LENGTH);
        CGContextStrokePath(ctx);
        
        double minutes = floor(i / 60.0);
        double seconds = round((i / 60.0 - minutes) * 60);
        NSString* markerLabel = [NSString stringWithFormat:@"%.0f:%02.f", minutes, seconds];
        NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:markerLabel 
                                                                      attributes:axisMarkerAttr];
        CTLineRef line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)attrStr);
        CGRect labelRect = CTLineGetImageBounds(line, ctx);
        CGContextSetTextPosition(ctx, x - labelRect.size.width/2, YINSET - MARKER_LENGTH - labelRect.size.height - 4);
        CTLineDraw(line, ctx);
        CFRelease(line);
    }
    
    CGContextRestoreGState(ctx);
}

- (void)handleZoomGesture:(UIPinchGestureRecognizer*)gestureRecognizer
{
    CGFloat gestureScale = gestureRecognizer.scale;
    CGPoint loc = [gestureRecognizer locationInView:self];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        _originalScale = _dataLayer.scale;
        _originalOffset = _dataLayer.offset;
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGFloat newOffset = MIN(0, _dataLayer.offset);
        CABasicAnimation* anim = [CABasicAnimation animationWithKeyPath:@"offset"];
        anim.removedOnCompletion = YES;
        anim.duration = 0.5;
        anim.fromValue = [NSNumber numberWithFloat:_dataLayer.offset];
        anim.toValue = [NSNumber numberWithFloat:newOffset];
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
        [_dataLayer addAnimation:anim forKey:@"animateOffset"];
        _dataLayer.offset = newOffset;

        if ([self.delegate respondsToSelector:@selector(lineChartView:didZoomToRange:)]) {
            [self.delegate lineChartView:self didZoomToRange:[self makeRangeForVisibleData]];
        }
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat newScale = MAX(1, _originalScale * gestureScale);
        
        CGFloat p = (loc.x - _leftInset);
        CGFloat newOffset = p - (p - _originalOffset) * newScale / _originalScale;
        
        _dataLayer.scale = newScale;
        _dataLayer.offset = newOffset;
        
        if ([self.delegate respondsToSelector:@selector(lineChartView:didZoomToRange:)]) {
            [self.delegate lineChartView:self didZoomToRange:[self makeRangeForVisibleData]];
        }
    }

    [self.layer setNeedsDisplay];
    [_dataLayer setNeedsDisplay];
}

- (void)handlePanGesture:(UIPanGestureRecognizer*)gestureRecognizer
{
    CGPoint translation = [gestureRecognizer translationInView:self];
    CGPoint velocity = [gestureRecognizer velocityInView:self];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        _originalOffset = _dataLayer.offset;
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        NSLog(@"end: velocity=%.3f", velocity.x);
        CGRect bounds = [self bounds];
        CGFloat chartWidth = bounds.size.width - (_leftInset + RINSET);
        CGFloat newOffset = _dataLayer.offset;
        CGFloat chartScale = _dataLayer.scale;
        
        CGFloat min = (-chartWidth) * chartScale + chartWidth;
        
        if (newOffset > 0 || newOffset < min) {
            newOffset = MIN(0, newOffset);
            newOffset = MAX(min, newOffset);
            CABasicAnimation* anim = [CABasicAnimation animationWithKeyPath:@"offset"];
            anim.removedOnCompletion = YES;
            anim.duration = 0.5;
            anim.fromValue = [NSNumber numberWithFloat:_dataLayer.offset];
            anim.toValue = [NSNumber numberWithFloat:newOffset];
            anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            [_dataLayer addAnimation:anim forKey:@"animateOffset"];
        }
        else if (abs(velocity.x) > 0) {
            newOffset = newOffset + velocity.x * 0.5;
            newOffset = MIN(0, newOffset);
            newOffset = MAX(min, newOffset);
            CABasicAnimation* anim = [CABasicAnimation animationWithKeyPath:@"offset"];
            anim.removedOnCompletion = YES;
            anim.duration = 0.5;
            anim.fromValue = [NSNumber numberWithFloat:_dataLayer.offset];
            anim.toValue = [NSNumber numberWithFloat:newOffset];
            anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            [_dataLayer addAnimation:anim forKey:@"animateOffset"];
        }
        
        _dataLayer.offset = newOffset;

        if ([self.delegate respondsToSelector:@selector(lineChartView:didZoomToRange:)]) {
            [self.delegate lineChartView:self didZoomToRange:[self makeRangeForVisibleData]];
        }
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        NSLog(@"change: velocity=%.3f", velocity.x);
        CGFloat newOffset = _originalOffset + translation.x;
        _dataLayer.offset = newOffset;

        if ([self.delegate respondsToSelector:@selector(lineChartView:didZoomToRange:)]) {
            [self.delegate lineChartView:self didZoomToRange:[self makeRangeForVisibleData]];
        }
    }
    
    [self.layer setNeedsDisplay];
    [_dataLayer setNeedsDisplay];
}

- (NSRange)makeRangeForVisibleData
{
    CGFloat scale = _dataLayer.scale;
    CGFloat offset = _dataLayer.offset;
    CGRect bounds = [self bounds];
    CGFloat chartWidth = bounds.size.width - (_leftInset + RINSET);
    CGFloat xScale = chartWidth / [_data count] * scale;
    CGFloat posOffset = offset * -1;
    NSUInteger start = MAX(0, ceil(posOffset / xScale));
    NSUInteger length = MIN([_data count], floor((posOffset + chartWidth) / xScale) - start);
    return NSMakeRange(start, length);
}

+ (CGRect)boundsForString:(NSString*)string
{
    UIGraphicsBeginImageContext(CGSizeMake(400, 400));
    
    NSDictionary* axisMarkerAttr = [UCLLineChartView axisMarkerLabelAttributes];
    NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:string 
                                                                  attributes:axisMarkerAttr];
    CTLineRef line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)attrStr);
    CGRect labelRect = CTLineGetImageBounds(line, UIGraphicsGetCurrentContext());
    
    UIGraphicsEndImageContext();
    
    return labelRect;
}

+ (NSDictionary*)axisMarkerLabelAttributes
{
    CTFontRef axisMarkerFont = CTFontCreateUIFontForLanguage(kCTFontSystemFontType, 12, NULL);
    CGColorRef axisMarkerColor = [UIColor whiteColor].CGColor;
    NSDictionary* attr = [NSDictionary dictionaryWithObjectsAndKeys:
                          (__bridge id)axisMarkerFont, kCTFontAttributeName,
                          axisMarkerColor, kCTForegroundColorAttributeName, nil];
    CFRelease(axisMarkerFont);
    return attr;
}

@end



