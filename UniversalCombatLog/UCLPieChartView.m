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
#import "UCLSpell.h"

@implementation UCLPieChartView
{
    double _sum;
    NSArray* _segmentColors;
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
        
        UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] 
                                                 initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:tapRecognizer];
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
    CGFloat chartWidth = (bounds.size.width - INSET*2) / 2;
    CGFloat chartHeight = bounds.size.height - INSET*2;

    // Flip co-ordinate system to bottom left going up and right.
    CGContextTranslateCTM(c, 0, bounds.size.height);
    CGContextScaleCTM(c, 1, -1);
    
    CTFontRef font = CTFontCreateUIFontForLanguage(kCTFontSystemFontType, 12, NULL);
    double lineHeight = CTFontGetAscent(font) + CTFontGetDescent(font) + CTFontGetLeading(font);

    CGFloat centerX = bounds.size.width / 4; // center of left side
    CGFloat centerY = bounds.size.height / 2;
    CGFloat radius = MIN(chartWidth / 2, chartHeight / 2);
    CGFloat startAngle = 0;
    
    NSArray *sortedSpells = [self.data keysSortedByValueUsingComparator:^(NSNumber* amount1, NSNumber* amount2) {
        return [amount2 compare:amount1];
    }];
    
    NSEnumerator* colorEnumerator = [_segmentColors objectEnumerator];
    
    CGFloat textY = INSET + chartHeight;
        
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
        
        double percent = [value doubleValue] / _sum * 100;
        NSString* text = [NSString stringWithFormat:@"%@", spell.name];
        CGColorRef fontColor = color.CGColor;
        NSDictionary* fontAttr = [NSDictionary dictionaryWithObjectsAndKeys:
                                  (__bridge id)font, kCTFontAttributeName,
                                  fontColor, kCTForegroundColorAttributeName, nil];
        NSAttributedString* attributedText = [[NSAttributedString alloc]
                                              initWithString:text
                                              attributes:fontAttr];
        CTLineRef line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)attributedText);
        textY -= lineHeight;
        CGContextSetTextPosition(c, bounds.size.width/2 + INSET, textY);
        CTLineDraw(line, c);
        CFRelease(line);
        
        text = [NSString stringWithFormat:@"%0.1f", percent];
        attributedText = [[NSAttributedString alloc] initWithString:text attributes:fontAttr];
        line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)attributedText);
        double lineWidth = CTLineGetTypographicBounds(line, NULL, NULL, NULL);
        CGContextSetTextPosition(c, bounds.size.width - INSET - lineWidth, textY);
        CTLineDraw(line, c);
        CFRelease(line);
    }
}

- (void)handleTap:(UIGestureRecognizer*)sender
{
    CGPoint loc = [sender locationOfTouch:0 inView:self];
    NSLog(@"Tap @ %f, %f", loc.x, loc.y);
}

@end
