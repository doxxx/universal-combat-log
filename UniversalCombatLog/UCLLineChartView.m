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
#pragma mark - LinesView

@interface LinesView : UIView

@property (nonatomic) double scale;
@property (nonatomic,readonly) uint32_t maxDataCount;
@property (nonatomic,readonly) double maxValue;
@property (nonatomic,readonly) double yInterval;

- (void)addLineWithValues:(NSArray*)values forKey:(NSString*)key;
- (void)removeLineForKey:(NSString*)key;
- (void)removeAllLines;
- (void)recalculate;
- (void)beginZoom;
- (void)endZoom;

@end


@implementation LinesView
{
    NSMutableDictionary* _lines;
    CGSize _sizeAtZoomStart;
    double _scaleAtZoomStart;
    CGFloat _xScale;
    CGFloat _yScale;
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
        
        self.contentMode = UIViewContentModeRedraw;
        self.layer.geometryFlipped = YES;
        self.opaque = YES;
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (void)setTransform:(CGAffineTransform)transform
{
    self.scale = _scaleAtZoomStart * transform.a;
    self.frame = CGRectMake(0, 0, _sizeAtZoomStart.width * self.scale, _sizeAtZoomStart.height);
}

- (void)addLineWithValues:(NSArray *)values forKey:(NSString *)key
{
    [_lines removeObjectForKey:key];
    [_lines setObject:values forKey:key];
    [self recalculate];
    [self setNeedsDisplay];
}

- (void)removeLineForKey:(NSString *)key
{
    NSArray* values = [_lines objectForKey:key];
    if (values != nil) {
        [_lines removeObjectForKey:key];
        [self recalculate];
        [self setNeedsDisplay];
    }
}

- (void)removeAllLines
{
    [_lines removeAllObjects];
    [self recalculate];
    [self setNeedsDisplay];
}

- (void)recalculate
{
    double newMaxValue = 0;
    double newMaxDataCount = 0;
    
    for (NSString* key in _lines) {
        NSArray* values = [_lines objectForKey:key];
        for (NSNumber* value in values) {
            double v = [value doubleValue];
            if (v > newMaxValue) {
                newMaxValue = v;
            }
        }
        if (values.count > newMaxDataCount) {
            newMaxDataCount = values.count;
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
        
        CGSize size = self.frame.size;
        _xScale = size.width / _maxDataCount;
        _yScale = size.height / _maxValue;
    }
}

- (void)beginZoom
{
    _sizeAtZoomStart = CGSizeApplyAffineTransform(self.frame.size, CGAffineTransformMakeScale(1/self.scale, 1));
    _scaleAtZoomStart = self.scale;
}

- (void)endZoom
{
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // Setup line color and style
    CGContextSetRGBStrokeColor(ctx, 0, 1, 0, 1);
    CGContextSetLineWidth(ctx, 2);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    CGContextSetLineCap(ctx, kCGLineCapRound);

    // Draw line(s)
    for (NSString* key in _lines) {
        NSArray* values = [_lines objectForKey:key];
        NSUInteger index = 0;
        for (NSNumber* value in values) {
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
}

- (void)layoutSubviews
{
    [self recalculate];
}

@end



////////////////////////////////////////////////////////////////////////////
#pragma mark - UCLLineChartView

@implementation UCLLineChartView
{
    NSDictionary* _textAttributes;
    UIScrollView* _scrollView;
    LinesView* _linesView;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _textAttributes = [UCLLineChartView axisMarkerLabelAttributes];
        
        CGRect scrollViewRect = CGRectMake(kChartInset, 0, self.bounds.size.width - kChartInset, self.bounds.size.height - kChartInset);

        _scrollView = [[UIScrollView alloc] initWithFrame:scrollViewRect];
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.maximumZoomScale = 10.0;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        _scrollView.alwaysBounceHorizontal = YES;
        _scrollView.scrollsToTop = NO;
        _scrollView.opaque = YES;
        [self addSubview:_scrollView];
        
        CGRect chartRect = CGRectMake(0, 0, scrollViewRect.size.width, scrollViewRect.size.height);
        _linesView = [[LinesView alloc] initWithFrame:chartRect];
        [_scrollView addSubview:_linesView];
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
    [_linesView addLineWithValues:values forKey:key];
    [self relayoutScrollview];
    [self setNeedsDisplay];
}

- (void)removeLineForKey:(NSString *)key
{
    [_linesView removeLineForKey:key];
    [self relayoutScrollview];
    [self setNeedsDisplay];
}

- (void)removeAllLines
{
    [_linesView removeAllLines];
    [self relayoutScrollview];
    [self setNeedsDisplay];
}

- (void)resetZoom
{
    CGSize size = _scrollView.bounds.size;
    _linesView.scale = 1;
    _linesView.frame = CGRectMake(0, 0, size.width, size.height);
    _scrollView.contentSize = size;
    _scrollView.contentOffset = CGPointMake(0, 0);
    
    [self setNeedsDisplay];
}

#pragma mark - ScrollView Delegate Methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _linesView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    [_linesView beginZoom];
}

#define kMinZoomScale 1.0
#define kMaxZoomScale 10.0

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)zoomScale
{
    CGSize size = scrollView.bounds.size;
    CGPoint contentOffset = _scrollView.contentOffset;
    CGSize contentSize = _linesView.frame.size;
    
    double scale = _linesView.scale;
    double newScale = MIN(MAX(scale, kMinZoomScale), kMaxZoomScale);
    
    _scrollView.minimumZoomScale = kMinZoomScale / newScale;
    _scrollView.maximumZoomScale = kMaxZoomScale / newScale;
    
    CGSize newContentSize = CGSizeMake(size.width * newScale, size.height);
    CGFloat newOffsetX = (contentOffset.x + size.width/2) / contentSize.width * newContentSize.width - (size.width/2);
    
    if (newScale == kMinZoomScale) {
        newOffsetX = 0;
    }
    
    CGPoint newContentOffset = CGPointMake(newOffsetX, 0);

    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionAllowAnimatedContent
                     animations:^{
                         _linesView.scale = newScale;
                         _linesView.frame = CGRectMake(0, 0, newContentSize.width, newContentSize.height);
                         _scrollView.contentSize = newContentSize;
                         [_scrollView setContentOffset:newContentOffset animated:YES];
                     }
                     completion:^(BOOL fininshed){
                     }];
    
    [_linesView endZoom];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self setNeedsDisplay];
    if (self.delegate) {
        NSRange range = [self makeRangeForVisibleData];
        [self.delegate lineChartView:self didZoomToRange:range];
    }
}

#pragma mark - View Methods

- (void)drawRect:(CGRect)rect
{
    if (_linesView.maxDataCount == 0) {
        return;
    }
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGSize size = _scrollView.frame.size;
    
    CGFloat xScale = size.width / _linesView.maxDataCount * _linesView.scale;
    CGFloat yScale = size.height / _linesView.maxValue;

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
    NSUInteger yMarkerCount = floor(_linesView.maxValue / _linesView.yInterval);
    for (NSUInteger i = 1; i <= yMarkerCount; i++) {
        CGFloat y = (i * _linesView.yInterval) * yScale;
        CGContextMoveToPoint(ctx, 0, y);
        CGContextAddLineToPoint(ctx, -kAxisMarkerLength, y);
        CGContextStrokePath(ctx);
        
        NSString* markerLabel = [NSString stringWithFormat:@"%.0f", (i * _linesView.yInterval)];
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
    [self relayoutScrollview];
}

#pragma mark - Helper Methods

- (void)relayoutScrollview
{
    CGSize viewSize = self.bounds.size;
    CGFloat maxLabelWidth = [UCLLineChartView labelWidthForMaxValue:_linesView.maxValue];
    CGFloat xInset = MAX(kChartInset, maxLabelWidth + kAxisMarkerLength + 8);
    CGRect newScrollFrame = CGRectMake(xInset, kChartInset, viewSize.width - (xInset + kChartInset), viewSize.height - kChartInset*2);
    double scale = _linesView.frame.size.width / _scrollView.frame.size.width;
    CGSize newContentSize = CGSizeApplyAffineTransform(newScrollFrame.size, CGAffineTransformMakeScale(scale, 1));

    CGPoint offset = _scrollView.contentOffset;
    double offsetRatio = offset.x / _scrollView.contentSize.width;
    offset.x = offsetRatio * newContentSize.width;

    _scrollView.frame = newScrollFrame;
    _linesView.frame = CGRectMake(0, 0, newContentSize.width, newContentSize.height);
    _scrollView.contentSize = newContentSize;
    
    // TODO: Not quite right, but it'll do for now.
    [_scrollView setContentOffset:offset animated:YES];
}

- (NSRange)makeRangeForVisibleData
{
    CGFloat chartWidth = _scrollView.contentSize.width;
    CGFloat visibleWidth = _scrollView.bounds.size.width;
    CGFloat xScale = chartWidth / _linesView.maxDataCount;
    CGFloat posOffset = _scrollView.contentOffset.x;
    NSUInteger start = MAX(0, ceil(posOffset / xScale));
    NSUInteger length = MIN(_linesView.maxDataCount, floor((posOffset + visibleWidth) / xScale) - start);
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



