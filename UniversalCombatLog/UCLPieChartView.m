//
//  UCLPieChartView.m
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-08-08.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <math.h>
#import <CoreText/CoreText.h>

#import "UCLPieChartView.h"

@implementation UCLPieChartView
{
    double _sum;
    uint16_t _selectedSegmentIndex;
    NSArray* _segmentPaths;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] 
                                                 initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:tapRecognizer];
    }
    return self;
}

#pragma mark - Properties

@synthesize delegate = _delegate;
@synthesize data = _data;

- (void)setData:(NSArray *)data
{
    if (data != nil) {
        _data = data;
        double sum = 0;
        for (NSNumber* value in data) {
            sum += [value doubleValue];
        }
        _sum = sum;
        
        _selectedSegmentIndex = -1;
    }
    else {
        _data = nil;
        _segmentPaths = nil;
    }
    [self setNeedsDisplay];
}

- (void)selectSegment:(NSUInteger)segmentIndex
{
    _selectedSegmentIndex = segmentIndex;
    [self setNeedsDisplay];
}

#pragma mark - View Methods

#define INSET 30

- (void)drawRect:(CGRect)rect
{
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextSetStrokeColorSpace(c, rgbColorSpace);
    CGContextSetFillColorSpace(c, rgbColorSpace);
    CGColorSpaceRelease(rgbColorSpace);
    
    CGRect bounds = [self bounds];
    CGFloat chartWidth = (bounds.size.width - INSET*2);
    CGFloat chartHeight = bounds.size.height - INSET*2;

    // Flip co-ordinate system to bottom left going up and right.
    CGContextTranslateCTM(c, 0, bounds.size.height);
    CGContextScaleCTM(c, 1, -1);
    
    // Calculate pie chart center and radius.
    CGFloat centerX = bounds.size.width / 2;
    CGFloat centerY = bounds.size.height / 2;
    CGFloat radius = MIN(chartWidth / 2, chartHeight / 2);
    CGFloat startAngle = 0;
    uint16_t segmentIndex = 0;
    NSMutableArray* segmentPaths = [NSMutableArray arrayWithCapacity:[self.data count]];
        
    for (NSNumber* value in self.data) {
        CGFloat ratio = [value doubleValue] / _sum;
        CGFloat endAngle = startAngle + (2 * M_PI * ratio);
        CGFloat segmentOriginX = centerX;
        CGFloat segmentOriginY = centerY;

        if (segmentIndex == _selectedSegmentIndex) {
            CGFloat middleAngle = (startAngle + endAngle) / 2;
            segmentOriginX = centerX + 10 * cos(middleAngle);
            segmentOriginY = centerY + 10 * sin(middleAngle);
        }
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, segmentOriginX, segmentOriginY);
        CGPathAddArc(path, NULL, segmentOriginX, segmentOriginY, radius, startAngle, endAngle, 0);
        CGPathAddLineToPoint(path, NULL, segmentOriginX, segmentOriginY);
        CGPathCloseSubpath(path);

        UIColor* color = [self.delegate pieChartView:self colorForSegment:segmentIndex];
        CGContextSetFillColorWithColor(c, color.CGColor);
        CGContextAddPath(c, path);
        CGContextFillPath(c);

        if (segmentIndex == _selectedSegmentIndex) {
            CGContextSetStrokeColorWithColor(c, [UIColor whiteColor].CGColor);
            CGContextAddPath(c, path);
            CGContextSetLineJoin(c, kCGLineJoinMiter);
            CGContextSetLineWidth(c, 2);
            CGContextStrokePath(c);
        }
        
        [segmentPaths addObject:(__bridge_transfer id)CGPathCreateCopy(path)];
        
        CGPathRelease(path);

        segmentIndex++;
        startAngle = endAngle;
    }
    
    _segmentPaths = segmentPaths;
}

- (void)handleTap:(UIGestureRecognizer*)sender
{
    CGPoint loc = [sender locationOfTouch:0 inView:self];
    CGRect bounds = [self bounds];
    CGAffineTransform xform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0, bounds.size.height), 1, -1);
    
    for (uint16_t i = 0; i < [self.data count]; i++) {
        CGPathRef path = (__bridge CGPathRef)[_segmentPaths objectAtIndex:i];
        if (CGPathContainsPoint(path, &xform, loc, FALSE)) {
            _selectedSegmentIndex = i;
            [self.delegate pieChartView:self didSelectSegmentAtIndex:i];
            [self setNeedsDisplay];
            return;
        }
    }
    
    _selectedSegmentIndex = -1;
    [self setNeedsDisplay];
}

@end
