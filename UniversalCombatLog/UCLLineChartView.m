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

@interface ChartLayer : CALayer

@property (strong, nonatomic) NSDictionary* textAttributes;
@property (nonatomic) CGPoint chartOrigin;
@property (nonatomic) CGSize chartSize;
@property (weak, nonatomic) NSArray* data;
@property (nonatomic) NSUInteger xInterval;
@property (nonatomic) NSUInteger yInterval;
@property (nonatomic) double maxValue;
@property (nonatomic) CGFloat offset;
@property (nonatomic) CGFloat scale;

@end

@implementation ChartLayer

- (id)initWithLayer:(id)layer
{
    self = [super initWithLayer:layer];
    if (self != nil) {
        if ([layer isKindOfClass:[ChartLayer class]]) {
            ChartLayer* other = layer;
            self.textAttributes = other.textAttributes;
            self.chartOrigin = other.chartOrigin;
            self.chartSize = other.chartSize;
            self.data = other.data;
            self.xInterval = other.xInterval;
            self.yInterval = other.yInterval;
            self.maxValue = other.maxValue;
            self.offset = other.offset;
            self.scale = other.scale;
        }
    }
    return self;
}

@synthesize textAttributes, chartOrigin, data=_data, xInterval=_xInterval, yInterval=_yInterval;
@synthesize maxValue=_maxValue;
@dynamic chartSize, offset, scale;

- (void)setData:(NSArray *)data
{
    _data = data;
    
    double maxValue = [[_data objectAtIndex:0] doubleValue];
    for (NSNumber* value in _data) {
        double v = [value doubleValue];
        if (v > maxValue) {
            maxValue = v;
        }
    }
    self.maxValue = maxValue;
    
    double yInterval = pow(10, floor(log10(maxValue)));
    double yIntervalCount = maxValue / yInterval;
    if (yIntervalCount < 3) {
        yInterval /= 5;
    }
    else if (yIntervalCount < 8) {
        yInterval /= 2;
    }
    self.yInterval = yInterval;
}

- (void)drawInContext:(CGContextRef)ctx
{
    if (self.data == nil) {
        return;
    }
    
    CGSize size = self.chartSize;
    CGFloat xScale = size.width / [self.data count] * self.scale;
    CGFloat yScale = size.height / self.maxValue;
    
    // Draw data line.
    CGContextSaveGState(ctx);
    CGContextSetRGBStrokeColor(ctx, 0, 1, 0, 1);
    CGContextSetLineWidth(ctx, 2);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    
    CGContextClipToRect(ctx, CGRectMake(0, 0, size.width, size.height));
    
    NSUInteger index = 0;
    while (index < [self.data count]) {
        NSNumber* value = [self.data objectAtIndex:index];
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

    // Draw axes.
    CGContextSetStrokeColorWithColor(ctx, [UIColor darkGrayColor].CGColor);
    CGContextSetLineWidth(ctx, 2);
    CGContextSetLineJoin(ctx, kCGLineJoinMiter);
    CGContextSetLineCap(ctx, kCGLineCapSquare);
    
    CGContextMoveToPoint(ctx, 0, size.height);
    CGContextAddLineToPoint(ctx, 0, 0);
    CGContextAddLineToPoint(ctx, size.width, 0);
    CGContextStrokePath(ctx);
    
    // Draw markers on axes.
    NSUInteger yMarkerCount = floor(self.maxValue / self.yInterval);
    for (NSUInteger i = 1; i <= yMarkerCount; i++) {
        CGFloat y = (i * self.yInterval) * yScale;
        CGContextMoveToPoint(ctx, 0, y);
        CGContextAddLineToPoint(ctx, -MARKER_LENGTH, y);
        CGContextStrokePath(ctx);
        
        NSString* markerLabel = [NSString stringWithFormat:@"%u", (i * self.yInterval)];
        NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:markerLabel 
                                                                      attributes:textAttributes];
        CTLineRef line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)attrStr);
        CGRect labelRect = CTLineGetImageBounds(line, ctx);
        CGContextSetTextPosition(ctx, -MARKER_LENGTH - labelRect.size.width - 4, y - labelRect.size.height/2);
        CTLineDraw(line, ctx);
        CFRelease(line);
    }
    
    CGContextSaveGState(ctx);
    
    NSUInteger count = size.width / xScale;
    double xInterval = MAX(1, round(floor(count / 10) / 15) * 15);
    while (count / xInterval > 20) {
        xInterval *= 5;
    }

    double posOffset = (0 - self.offset);
    NSUInteger markerStart = MAX(0, ceil(posOffset / xScale / xInterval) * xInterval);
    NSUInteger markerEnd = round((posOffset + size.width) / xScale);
    
    for (NSUInteger i = markerStart; i < markerEnd; i += xInterval) {
        CGFloat x = self.offset + i * xScale;
        CGContextMoveToPoint(ctx, x, 0);
        CGContextAddLineToPoint(ctx, x, -MARKER_LENGTH);
        CGContextStrokePath(ctx);
        
        double minutes = floor(i / 60.0);
        double seconds = round((i / 60.0 - minutes) * 60);
        NSString* markerLabel = [NSString stringWithFormat:@"%.0f:%02.f", minutes, seconds];
        NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:markerLabel 
                                                                      attributes:textAttributes];
        CTLineRef line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)attrStr);
        CGRect labelRect = CTLineGetImageBounds(line, ctx);
        CGContextSetTextPosition(ctx, x - labelRect.size.width/2, -MARKER_LENGTH - labelRect.size.height - 4);
        CTLineDraw(line, ctx);
        CFRelease(line);
    }
    
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
    ChartLayer* _chartLayer;
    UIPinchGestureRecognizer* _zoomGestureRecognizer;
    UIPanGestureRecognizer* _panGestureRecognizer;
    CGFloat _originalScale;
    CGFloat _originalOffset;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        // We want all CALayer drawing to be done from the bottom left
        self.layer.sublayerTransform = CATransform3DMakeScale(1, -1, 1);

        _chartLayer = [ChartLayer layer];
        [self.layer addSublayer:_chartLayer];
        _chartLayer.needsDisplayOnBoundsChange = YES;
        _chartLayer.contentsScale = [UIScreen mainScreen].scale;
        _chartLayer.anchorPoint = CGPointMake(0, 0);
        _chartLayer.position = CGPointMake(0, 0);
        _chartLayer.actions = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNull null], @"position", 
                               [NSNull null], @"bounds", 
                               [NSNull null], @"contents", 
                               nil];
        _chartLayer.textAttributes = [UCLLineChartView axisMarkerLabelAttributes];
        _chartLayer.hidden = YES;

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
@synthesize data = _data;

- (void)setData:(NSArray *)data
{
    if (data != nil) {
        _data = [data copy];
        _chartLayer.data = _data;
        _chartLayer.offset = 0;
        _chartLayer.scale = 1;
        [self configureLayersWithAnimation:NO overDuration:0];
        _chartLayer.hidden = NO;
        [_chartLayer setNeedsDisplay];
    }
    else {
        _data = nil;
        _chartLayer.hidden = YES;
    }
}

#pragma mark - View Methods

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self configureLayersWithAnimation:YES overDuration:duration];
}

#pragma mark - View Configuration

- (void)configureLayersWithAnimation:(BOOL)animate overDuration:(NSTimeInterval)duration
{
    CGRect bounds = self.bounds;
    CGFloat maxLabelWidth = [UCLLineChartView labelWidthForMaxValue:_chartLayer.maxValue];
    CGFloat xInset = MAX(LINSET, maxLabelWidth + MARKER_LENGTH + 8);
    CGRect newChartBounds = CGRectMake(-xInset, -YINSET, 
                                       bounds.size.width, bounds.size.height);
    CGSize newChartSize = CGSizeMake(bounds.size.width - (xInset + RINSET), 
                                     bounds.size.height - YINSET*2);
    if (animate) {
        [CATransaction begin];

        CABasicAnimation* anim = [CABasicAnimation animationWithKeyPath:@"bounds.size.width"];
        anim.removedOnCompletion = YES;
        anim.duration = duration;
        anim.fromValue = [NSNumber numberWithFloat:_chartLayer.bounds.size.width];
        anim.toValue = [NSNumber numberWithFloat:newChartBounds.size.width];
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
        [_chartLayer addAnimation:anim forKey:@"animateBoundsWidth"];
        
        anim = [CABasicAnimation animationWithKeyPath:@"bounds.size.height"];
        anim.removedOnCompletion = YES;
        anim.duration = duration;
        anim.fromValue = [NSNumber numberWithFloat:_chartLayer.bounds.size.height];
        anim.toValue = [NSNumber numberWithFloat:newChartBounds.size.height];
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
        [_chartLayer addAnimation:anim forKey:@"animateBoundsHeight"];

        anim = [CABasicAnimation animationWithKeyPath:@"chartSize.width"];
        anim.removedOnCompletion = YES;
        anim.duration = duration;
        anim.fromValue = [NSNumber numberWithFloat:_chartLayer.chartSize.width];
        anim.toValue = [NSNumber numberWithFloat:newChartSize.width];
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
        [_chartLayer addAnimation:anim forKey:@"animateChartSizeWidth"];
        
        anim = [CABasicAnimation animationWithKeyPath:@"chartSize.height"];
        anim.removedOnCompletion = YES;
        anim.duration = duration;
        anim.fromValue = [NSNumber numberWithFloat:_chartLayer.chartSize.height];
        anim.toValue = [NSNumber numberWithFloat:newChartSize.height];
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
        [_chartLayer addAnimation:anim forKey:@"animateChartSizeHeight"];

        [CATransaction commit];
    }
    _chartLayer.bounds = newChartBounds;
    _chartLayer.chartSize = newChartSize;
}

#pragma mark - Gesture Handlers

- (void)handleZoomGesture:(UIPinchGestureRecognizer*)gestureRecognizer
{
    CGFloat gestureScale = gestureRecognizer.scale;
    CGPoint loc = [gestureRecognizer locationInView:self];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        _originalScale = _chartLayer.scale;
        _originalOffset = _chartLayer.offset;
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGFloat newOffset = MIN(0, _chartLayer.offset);
        CABasicAnimation* anim = [CABasicAnimation animationWithKeyPath:@"offset"];
        anim.removedOnCompletion = YES;
        anim.duration = 0.5;
        anim.fromValue = [NSNumber numberWithFloat:_chartLayer.offset];
        anim.toValue = [NSNumber numberWithFloat:newOffset];
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
        [_chartLayer addAnimation:anim forKey:@"animateOffset"];
        _chartLayer.offset = newOffset;

        if ([self.delegate respondsToSelector:@selector(lineChartView:didZoomToRange:)]) {
            [self.delegate lineChartView:self didZoomToRange:[self makeRangeForVisibleData]];
        }
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat newScale = MAX(1, _originalScale * gestureScale);
        
        CGFloat p = (loc.x + _chartLayer.bounds.origin.x); // TODO: correct?
        CGFloat newOffset = p - (p - _originalOffset) * newScale / _originalScale;
        
        _chartLayer.scale = newScale;
        _chartLayer.offset = newOffset;
        
        if ([self.delegate respondsToSelector:@selector(lineChartView:didZoomToRange:)]) {
            [self.delegate lineChartView:self didZoomToRange:[self makeRangeForVisibleData]];
        }
    }

    [self.layer setNeedsDisplay];
    [_chartLayer setNeedsDisplay];
}

- (void)handlePanGesture:(UIPanGestureRecognizer*)gestureRecognizer
{
    CGPoint translation = [gestureRecognizer translationInView:self];
    CGPoint velocity = [gestureRecognizer velocityInView:self];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        _originalOffset = _chartLayer.offset;
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        NSLog(@"end: velocity=%.3f", velocity.x);
        CGFloat chartWidth = _chartLayer.chartSize.width;
        CGFloat newOffset = _chartLayer.offset;
        CGFloat chartScale = _chartLayer.scale;
        
        CGFloat min = (-chartWidth) * chartScale + chartWidth;
        
        if (newOffset > 0 || newOffset < min) {
            newOffset = MIN(0, newOffset);
            newOffset = MAX(min, newOffset);
            CABasicAnimation* anim = [CABasicAnimation animationWithKeyPath:@"offset"];
            anim.removedOnCompletion = YES;
            anim.duration = 0.5;
            anim.fromValue = [NSNumber numberWithFloat:_chartLayer.offset];
            anim.toValue = [NSNumber numberWithFloat:newOffset];
            anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
            [_chartLayer addAnimation:anim forKey:@"animateOffset"];
        }
        else if (abs(velocity.x) > 0) {
            newOffset = newOffset + velocity.x * 0.5;
            newOffset = MIN(0, newOffset);
            newOffset = MAX(min, newOffset);
            CABasicAnimation* anim = [CABasicAnimation animationWithKeyPath:@"offset"];
            anim.removedOnCompletion = YES;
            anim.duration = 0.5;
            anim.fromValue = [NSNumber numberWithFloat:_chartLayer.offset];
            anim.toValue = [NSNumber numberWithFloat:newOffset];
            anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
            [_chartLayer addAnimation:anim forKey:@"animateOffset"];
        }
        
        _chartLayer.offset = newOffset;

        if ([self.delegate respondsToSelector:@selector(lineChartView:didZoomToRange:)]) {
            [self.delegate lineChartView:self didZoomToRange:[self makeRangeForVisibleData]];
        }
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        NSLog(@"change: velocity=%.3f", velocity.x);
        CGFloat newOffset = _originalOffset + translation.x;
        _chartLayer.offset = newOffset;

        if ([self.delegate respondsToSelector:@selector(lineChartView:didZoomToRange:)]) {
            [self.delegate lineChartView:self didZoomToRange:[self makeRangeForVisibleData]];
        }
    }
    
    [self.layer setNeedsDisplay];
    [_chartLayer setNeedsDisplay];
}

#pragma mark - Helper Methods

- (NSRange)makeRangeForVisibleData
{
    CGFloat scale = _chartLayer.scale;
    CGFloat offset = _chartLayer.offset;
    CGFloat chartWidth = _chartLayer.chartSize.width;
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

+ (CGFloat)labelWidthForMaxValue:(double)value
{
    int numDigits = 0;
    if (value > 0) {
        numDigits = ceil(log10(value));
    }
    NSString* biggestLabel = [NSString stringWithFormat:@"%0*d", numDigits, 0];
    CGRect labelRect = [UCLLineChartView boundsForString:biggestLabel];
    return labelRect.size.width;
}

@end



