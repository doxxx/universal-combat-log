//
//  UCLLineChart.m
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-08-03.
//  Copyright (c) 2012 Gordon Tyler. All rights reserved.
//

#import <CoreText/CoreText.h>
#import <QuartzCore/QuartzCore.h>

#import "UCLLineChartView.h"

#define kChartInset 30
#define kAxisMarkerLength 5
#define kAxisLineWidth 2

////////////////////////////////////////////////////////////////////////////
#pragma mark - ChartLine

@interface ChartLine : NSObject

@property (strong, nonatomic) CALayer* layer;
@property (strong, nonatomic) NSArray* values;
@property (nonatomic) CGFloat xScale;
@property (nonatomic) CGFloat yScale;

- (id)initWithValues:(NSArray*)values;

@end


@implementation ChartLine

@synthesize layer = _layer;
@synthesize values = _values;
@synthesize xScale = _xScale;
@synthesize yScale = _yScale;

- (id)initWithValues:(NSArray*)values
{
    self = [super init];
    if (self) {
        _layer = [CALayer layer];
        _layer.delegate = self;
        _values = values;
    }
    return self;
}

- (void)drawLayer:(CALayer *)l inContext:(CGContextRef)ctx
{
    // Setup line color and style
    CGContextSetRGBStrokeColor(ctx, 0, 1, 0, 1);
    CGContextSetLineWidth(ctx, 2);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    
    //    CGContextClipToRect(ctx, CGRectMake(0, 0, size.width, size.height));
    
    // Draw line(s)
    NSUInteger index = 0;
    NSUInteger count = [_values count];
    while (index < count) {
        NSNumber* value = [_values objectAtIndex:index];
        CGFloat x = index * _xScale;
        CGFloat y = [value doubleValue] * _yScale;
        if (index == 0) {
            CGContextMoveToPoint(ctx, x, y);
        }
        else {
            CGContextAddLineToPoint(ctx, x, y);
        }
        index++;
    }
    CGContextStrokePath(ctx);
}

@end



////////////////////////////////////////////////////////////////////////////
#pragma mark - ChartView

@interface ChartView : UIView

@property (nonatomic) double scale;
@property (nonatomic,readonly) uint32_t maxDataCount;
@property (nonatomic,readonly) double maxValue;
@property (nonatomic,readonly) double yInterval;

- (void)addLineWithValues:(NSArray*)values forKey:(NSString*)key;
- (void)removeLineForKey:(NSString*)key;
- (void)removeAllLines;
- (void)recalculate;
- (void)beginZoom;

@end


@implementation ChartView
{
    NSMutableDictionary* _lines;
    double _originalScale;
    CGRect _bounds;
    CGRect _frame;
    CGPoint _center;
}

@synthesize scale = _scale;
@synthesize maxDataCount = _maxDataCount;
@synthesize maxValue = _maxValue;
@synthesize yInterval = _yInterval;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _lines = [NSMutableDictionary dictionary];
        _scale = 1.0;
        _maxDataCount = 0;
        _maxValue = 0;
        _yInterval = 0;
        _bounds = self.bounds;
        _frame = self.frame;
        _center = self.center;
        
        self.contentMode = UIViewContentModeRedraw;
        self.layer.geometryFlipped = YES;
        self.opaque = YES;
    }
    return self;
}

- (void)setScale:(double)scale
{
    [super setTransform:CGAffineTransformIdentity];
    _scale = scale;
    
    [self recalculate];
    [self setNeedsDisplay];
}

- (void)setFrame:(CGRect)frame
{
    NSLog(@"setFrame");
    [super setFrame:frame];
}

- (void)setBounds:(CGRect)bounds
{
    NSLog(@"setBounds");
    [super setBounds:bounds];
}

- (void)setCenter:(CGPoint)center
{
    NSLog(@"setCenter");
    [super setCenter:center];
}

- (void)setTransform:(CGAffineTransform)transform
{
//    NSLog(@"chartview frame: %.3f, %.3f, %.3f, %.3f", self.frame.origin.x, self.frame.origin.y, 
//          self.frame.size.width, self.frame.size.height);
    NSLog(@"chartview bounds: %.3f, %.3f, %.3f, %.3f", self.bounds.origin.x, self.bounds.origin.y, 
          self.bounds.size.width, self.bounds.size.height);
    NSLog(@"chartview center: %.3f, %.3f", self.center.x, self.center.y);
    
    CGAffineTransform constrained = CGAffineTransformIdentity;
    constrained.a = transform.a;

//    [super setTransform:transform];
    [super setTransform:constrained];

    NSLog(@"----------------");
//    NSLog(@"chartview frame: %.3f, %.3f, %.3f, %.3f", self.frame.origin.x, self.frame.origin.y, 
//          self.frame.size.width, self.frame.size.height);
    NSLog(@"chartview bounds: %.3f, %.3f, %.3f, %.3f", self.bounds.origin.x, self.bounds.origin.y, 
          self.bounds.size.width, self.bounds.size.height);
    NSLog(@"chartview center: %.3f, %.3f", self.center.x, self.center.y);
    
//    self.frame = CGRectApplyAffineTransform(_frame, constrained);
////    self.bounds = CGRectApplyAffineTransform(_bounds, constrained);
//    self.center = CGPointApplyAffineTransform(_center, constrained);
    
//    
//    for (NSString* key in _lines) {
//        ChartLine* line = [_lines objectForKey:key];
//        [line.layer setNeedsDisplay];
//    }

//    self.scale = transform.a;
//    self.frame = CGRectMake(self.center.x - self.bounds.size.width * self.scale/2, self.center.y,
//                            self.bounds.size.width * self.scale, self.bounds.size.height);

//    NSLog(@"chart center: %.3f, %.3f, bounds: %.3f, %.3f, %.3f, %.3f", self.center.x, self.center.y, 
//          self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
//    _scale = _originalScale * transform.a;
//    [self recalculate];
//    for (NSString* key in _lines) {
//        ChartLine* line = [_lines objectForKey:key];
//        [line.layer setNeedsDisplay];
//    }
}

- (void)addLineWithValues:(NSArray *)values forKey:(NSString *)key
{
    ChartLine* line = [[ChartLine alloc] initWithValues:values];
    CGSize size = self.layer.bounds.size;
    line.layer.frame = CGRectMake(0, 0, size.width, size.height);
    [self.layer addSublayer:line.layer];
    [_lines setObject:line forKey:key];
    [self recalculate];
    
    [line.layer setNeedsDisplay];
}

- (void)removeLineForKey:(NSString *)key
{
    ChartLine* line = [_lines objectForKey:key];
    if (line != nil) {
        [line.layer removeFromSuperlayer];
        [_lines removeObjectForKey:key];
        [self recalculate];
    }
}

- (void)removeAllLines
{
    for (NSString* key in _lines) {
        ChartLine* line = [_lines objectForKey:key];
        [line.layer removeFromSuperlayer];
    }
    [_lines removeAllObjects];
    [self recalculate];
}

- (void)recalculate
{
    double newMaxValue = 0;
    double newMaxDataCount = 0;
    
    for (NSString* key in _lines) {
        ChartLine* line = [_lines objectForKey:key];
        for (NSNumber* value in line.values) {
            double v = [value doubleValue];
            if (v > newMaxValue) {
                newMaxValue = v;
            }
        }
        if (line.values.count > newMaxDataCount) {
            newMaxDataCount = line.values.count;
        }
    }
    
    _maxValue = newMaxValue;
    _maxDataCount = newMaxDataCount;
    
    if (_maxDataCount > 0) {
        double newYInterval = pow(10, floor(log10(newMaxValue)));
        double yIntervalCount = newMaxValue / newYInterval;
        if (yIntervalCount < 3) {
            newYInterval /= 5;
        }
        else if (yIntervalCount < 8) {
            newYInterval /= 2;
        }
        _yInterval = newYInterval;
        
        CGSize size = self.bounds.size;
        CGFloat xScale = size.width / _maxDataCount * _scale;
        CGFloat yScale = size.height / _maxValue;
        
        for (NSString* key in _lines) {
            ChartLine* line = [_lines objectForKey:key];
            line.xScale = xScale;
            line.yScale = yScale;
        }
    }
}

- (void)beginZoom
{
    _originalScale = _scale;
}

- (void)layoutSubviews
{
    NSLog(@"chartview layout subviews");
    for (NSString* key in _lines) {
        ChartLine* line = [_lines objectForKey:key];
        line.layer.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    }
}

- (void)setNeedsDisplay
{
    [super setNeedsDisplay];
    for (NSString* key in _lines) {
        ChartLine* line = [_lines objectForKey:key];
        [line.layer setNeedsDisplay];
    }
}

@end



////////////////////////////////////////////////////////////////////////////
#pragma mark - UCLLineChartView

@implementation UCLLineChartView
{
    NSDictionary* _textAttributes;
    UIScrollView* _scrollView;
    ChartView* _chartView;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _textAttributes = [UCLLineChartView axisMarkerLabelAttributes];
        
        CGRect scrollViewRect = CGRectMake(kChartInset, 0, self.bounds.size.width - kChartInset, self.bounds.size.height - kChartInset);

        _scrollView = [[UIScrollView alloc] initWithFrame:scrollViewRect];
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.maximumZoomScale = 10.0;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.alwaysBounceHorizontal = YES;
        _scrollView.scrollsToTop = NO;
        _scrollView.opaque = YES;
        [self addSubview:_scrollView];
        
        CGRect chartRect = CGRectMake(0, 0, scrollViewRect.size.width, scrollViewRect.size.height);
        _chartView = [[ChartView alloc] initWithFrame:chartRect];
        [_scrollView addSubview:_chartView];
        _scrollView.contentSize = chartRect.size;
        
        _scrollView.delegate = self;
        
    }
    return self;
}

#pragma mark - Properties

@synthesize delegate = _chartDelegate;
@synthesize rotating;

- (void)addLineWithValues:(NSArray *)values forKey:(NSString *)key
{
    [_chartView addLineWithValues:values forKey:key];
    [self setNeedsDisplay];
}

- (void)removeLineForKey:(NSString *)key
{
    [_chartView removeLineForKey:key];
    [self setNeedsDisplay];
}

- (void)removeAllLines
{
    [_chartView removeAllLines];
    [self setNeedsDisplay];
}

- (void)resetView
{
    // TODO: Implement this?
    _scrollView.zoomScale = 1.0;
    [self setNeedsDisplay];
}

#pragma mark - ScrollView Delegate Methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _chartView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    [_chartView beginZoom];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    NSLog(@"scrollViewDidEndZooming: scale=%.3f, contentOffset=%.3f,%.3f", scale, scrollView.contentOffset.x, scrollView.contentOffset.y);
    NSLog(@"scrollViewDidEndZooming: contentSize=%.3f,%.3f", scrollView.contentSize.width, scrollView.contentSize.height);
    NSLog(@"scrollViewDidEndZooming: chart center: %.3f, %.3f", _chartView.center.x, _chartView.center.y);
    NSLog(@"scrollViewDidEndZooming: chart bounds size: %.3f, %.3f", _chartView.bounds.size.width, _chartView.bounds.size.height);
    NSLog(@"scrollViewDidEndZooming: scroll bounds: %.3f, %.3f, %.3f, %.3f", _scrollView.bounds.origin.x, _scrollView.bounds.origin.y, _scrollView.bounds.size.width, _scrollView.bounds.size.height);
//    _chartView.scale = scale;
//    _scrollView.zoomScale = 1.0;
//    [_chartView recalculate];
//    [_chartView setNeedsDisplay];
//    NSLog(@"-------------------------");
//    NSLog(@"scrollViewDidEndZooming: scale=%.3f, contentOffset=%.3f,%.3f", _scrollView.zoomScale, scrollView.contentOffset.x, scrollView.contentOffset.y);
//    NSLog(@"scrollViewDidEndZooming: contentSize=%.3f,%.3f", scrollView.contentSize.width, scrollView.contentSize.height);
//    NSLog(@"scrollViewDidEndZooming: chart frame: %.3f, %.3f, %.3f, %.3f", _chartView.frame.origin.x, _chartView.frame.origin.y, _chartView.frame.size.width, _chartView.frame.size.height);
//    NSLog(@"scrollViewDidEndZooming: scroll bounds: %.3f, %.3f, %.3f, %.3f", _scrollView.bounds.origin.x, _scrollView.bounds.origin.y, _scrollView.bounds.size.width, _scrollView.bounds.size.height);
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewDidZoom: scale=%.3f, contentOffset=%.3f,%.3f", scrollView.zoomScale, scrollView.contentOffset.x, scrollView.contentOffset.y);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self setNeedsDisplay];
    if (self.delegate) {
        [self.delegate lineChartView:self didZoomToRange:[self makeRangeForVisibleData]];
    }
}

#pragma mark - View Methods

- (void)drawRect:(CGRect)rect
{
    if (_chartView.maxDataCount == 0) {
        return;
    }
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGSize size = _scrollView.frame.size;
    
    CGFloat xScale = size.width / _chartView.maxDataCount * _scrollView.zoomScale;
    CGFloat yScale = size.height / _chartView.maxValue;

    // Flip geometry
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -self.bounds.size.height);
    
    // Do all drawing relative to the 0,0 point on the axes
    CGPoint origin = _scrollView.frame.origin; // even though this is actually top-left, it works because it's symmetrical
    CGContextTranslateCTM(ctx, origin.x - kAxisLineWidth, origin.y - kAxisLineWidth);
    
    // Draw axes.
    CGContextSetStrokeColorWithColor(ctx, [UIColor darkGrayColor].CGColor);
    CGContextSetLineWidth(ctx, kAxisLineWidth);
    CGContextSetLineJoin(ctx, kCGLineJoinMiter);
    CGContextSetLineCap(ctx, kCGLineCapSquare);
    
    CGContextMoveToPoint(ctx, 0, size.height);
    CGContextAddLineToPoint(ctx, 0, 0);
    CGContextAddLineToPoint(ctx, size.width, 0);
    CGContextStrokePath(ctx);
    
    // Draw markers on axes.
    NSUInteger yMarkerCount = floor(_chartView.maxValue / _chartView.yInterval);
    for (NSUInteger i = 1; i <= yMarkerCount; i++) {
        CGFloat y = (i * _chartView.yInterval) * yScale;
        CGContextMoveToPoint(ctx, 0, y);
        CGContextAddLineToPoint(ctx, -kAxisMarkerLength, y);
        CGContextStrokePath(ctx);
        
        NSString* markerLabel = [NSString stringWithFormat:@"%.0f", (i * _chartView.yInterval)];
        NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:markerLabel 
                                                                      attributes:_textAttributes];
        CTLineRef line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)attrStr);
        CGRect labelRect = CTLineGetImageBounds(line, ctx);
        CGContextSetTextPosition(ctx, -kAxisMarkerLength - labelRect.size.width - 4, y - labelRect.size.height/2);
        CTLineDraw(line, ctx);
        CFRelease(line);
    }
    
    NSUInteger count = size.width / xScale;
    double xInterval = MAX(1, round(floor(count / 10) / 15) * 15);
    while (count / xInterval > 20) {
        xInterval *= 5;
    }
    
    double posOffset = _scrollView.contentOffset.x;
    NSUInteger markerStart = MAX(0, ceil(posOffset / xScale / xInterval) * xInterval);
    NSUInteger markerEnd = round((posOffset + size.width) / xScale);
    
    for (NSUInteger i = markerStart; i < markerEnd; i += xInterval) {
        CGFloat x = i * xScale - _scrollView.contentOffset.x;
        CGContextMoveToPoint(ctx, x, 0);
        CGContextAddLineToPoint(ctx, x, -kAxisMarkerLength);
        CGContextStrokePath(ctx);
        
        double minutes = floor(i / 60.0);
        double seconds = round((i / 60.0 - minutes) * 60);
        NSString* markerLabel = [NSString stringWithFormat:@"%.0f:%02.f", minutes, seconds];
        NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:markerLabel 
                                                                      attributes:_textAttributes];
        CTLineRef line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)attrStr);
        CGRect labelRect = CTLineGetImageBounds(line, ctx);
        CGContextSetTextPosition(ctx, x - labelRect.size.width/2, -kAxisMarkerLength - labelRect.size.height - 4);
        CTLineDraw(line, ctx);
        CFRelease(line);
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!self.rotating) {
        CGSize viewSize = self.bounds.size;
        CGFloat maxLabelWidth = [UCLLineChartView labelWidthForMaxValue:_chartView.maxValue];
        CGFloat xInset = MAX(kChartInset, maxLabelWidth + kAxisMarkerLength + 8);
        CGSize chartSize = CGSizeMake(viewSize.width - (xInset + kChartInset), viewSize.height - kChartInset*2);
        CGRect newScrollFrame = CGRectMake(xInset, kChartInset, chartSize.width, chartSize.height);
        _scrollView.frame = newScrollFrame;
        _scrollView.contentSize = chartSize;

        _chartView.frame = CGRectMake(0, 0, chartSize.width, chartSize.height);
        
        [_chartView recalculate];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
//    [self configureLayersWithAnimation:YES overDuration:duration];
}

#pragma mark - Helper Methods

- (NSRange)makeRangeForVisibleData
{
    CGFloat scale = _scrollView.zoomScale;
    CGFloat chartWidth = _chartView.bounds.size.width;
    CGFloat xScale = chartWidth / _chartView.maxDataCount * scale;
    CGFloat posOffset = _scrollView.contentOffset.x;
    NSUInteger start = MAX(0, ceil(posOffset / xScale));
    NSUInteger length = MIN(_chartView.maxDataCount, floor((posOffset + chartWidth) / xScale) - start);
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



