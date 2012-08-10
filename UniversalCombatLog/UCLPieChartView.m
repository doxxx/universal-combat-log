//
//  UCLPieChartView.m
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-08-08.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <math.h>

#import "UCLPieChartView.h"
#import "UCLSpell.h"

@implementation UCLPieChartView
{
    double _sum;
    NSArray* _segmentColors;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _segmentColors = [NSArray arrayWithObjects:
                          [UIColor redColor], 
                          [UIColor greenColor], 
                          [UIColor blueColor], 
                          [UIColor magentaColor], 
                          [UIColor cyanColor], 
                          [UIColor yellowColor], 
                          [UIColor orangeColor], 
                          [UIColor purpleColor], 
                          [UIColor brownColor], 
                          nil];
    }
    return self;
}

#pragma mark - Properties

@synthesize data = _data;

- (void)setData:(NSDictionary *)data
{
    if (data != nil) {
        _data = data;
        double sum = 0;
        for (NSNumber* value in [data allValues]) {
            sum += [value doubleValue];
        }
        _sum = sum;
        
        NSLog(@"Pie chart data: count=%d, sum=%f", [data count], sum);
    }
    else {
        _data = nil;
    }
    [self setNeedsDisplay];
}

#define INSET 30

- (void)drawRect:(CGRect)rect
{
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextSetStrokeColorSpace(c, rgbColorSpace);
    CGContextSetFillColorSpace(c, rgbColorSpace);
    
    CGRect bounds = [self bounds];
    CGFloat chartWidth = bounds.size.width - INSET*2;
    CGFloat chartHeight = bounds.size.height - INSET*2;

    // Flip co-ordinate system to bottom left going up and right.
    CGContextTranslateCTM(c, 0, bounds.size.height);
    CGContextScaleCTM(c, 1, -1);
    
    CGFloat centerX = bounds.size.width / 2;
    CGFloat centerY = bounds.size.width / 2;
    CGFloat radius = MIN(chartWidth / 2, chartHeight / 2);
    CGFloat startAngle = 0;
    
    NSArray *sortedSpells = [self.data keysSortedByValueUsingComparator:^(NSNumber* amount1, NSNumber* amount2) {
        return [amount2 compare:amount1];
    }];
    
    NSEnumerator* colorEnumerator = [_segmentColors objectEnumerator];
        
    for (UCLSpell* spell in sortedSpells) {
        NSNumber* value = [self.data objectForKey:spell];
        CGFloat ratio = [value doubleValue] / _sum;
        CGFloat endAngle = startAngle + (2 * M_PI * ratio);
        NSLog(@"Pie chart segment: name=%@, ratio=%.3f, startAngle=%.3f, endAngle=%.3f", 
              spell.name, ratio, startAngle, endAngle);
        UIColor* color = [colorEnumerator nextObject];
        if (color == nil) {
            color = [UIColor colorWithRed:(CGFloat)random() / UINT32_MAX 
                                    green:(CGFloat)random() / UINT32_MAX 
                                     blue:(CGFloat)random() / UINT32_MAX 
                                    alpha:1];
        }
        CGContextSetFillColorWithColor(c, color.CGColor);
        CGContextSetStrokeColorWithColor(c, color.CGColor);
        CGContextMoveToPoint(c, centerX, centerY);
        CGContextAddArc(c, centerX, centerY, radius, startAngle, endAngle, 0);
        CGContextAddLineToPoint(c, centerX, centerY);
        CGContextClosePath(c);
        CGContextFillPath(c);
        startAngle = endAngle;
    }
}

@end
