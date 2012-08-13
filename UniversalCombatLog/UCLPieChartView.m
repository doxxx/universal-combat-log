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
    NSArray* _sortedSpells;
    NSArray* _segmentColors;
    uint16_t _selectedSpellIndex;
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
        
        _sortedSpells = [self.data keysSortedByValueUsingComparator:^(NSNumber* amount1, NSNumber* amount2) {
            return [amount2 compare:amount1];
        }];
        
        NSMutableArray* segmentColors = [NSMutableArray arrayWithCapacity:[_sortedSpells count]];
        [segmentColors addObjectsFromArray:[NSArray arrayWithObjects:
                                            [UIColor colorWithRed:1 green:0 blue:0 alpha:1], 
                                            [UIColor colorWithRed:1 green:0.5 blue:0 alpha:1], 
                                            [UIColor colorWithRed:1 green:1 blue:0 alpha:1], 
                                            [UIColor colorWithRed:0.5 green:1 blue:0 alpha:1], 
                                            [UIColor colorWithRed:1 green:0 blue:0.5 alpha:1], 
                                            [UIColor colorWithRed:1 green:61.0/255.0 blue:61.0/255.0 alpha:1], 
                                            [UIColor colorWithRed:1 green:122.0/255.0 blue:122.0/255.0 alpha:1], 
                                            [UIColor colorWithRed:0 green:1 blue:0 alpha:1], 
                                            [UIColor colorWithRed:1 green:0 blue:1 alpha:1], 
                                            [UIColor colorWithRed:122.0/255.0 green:1 blue:1 alpha:1],
                                            [UIColor colorWithRed:61.0/255.0 green:1 blue:1 alpha:1],
                                            [UIColor colorWithRed:0 green:1 blue:0.5 alpha:1],
                                            [UIColor colorWithRed:0.5 green:0 blue:1 alpha:1],
                                            [UIColor colorWithRed:0 green:0 blue:1 alpha:1],
                                            [UIColor colorWithRed:0 green:0.5 blue:1 alpha:1],
                                            [UIColor colorWithRed:0 green:1 blue:1 alpha:1],
                                            [UIColor colorWithRed:1 green:1 blue:61.0/255.0 alpha:1],
                                            [UIColor colorWithRed:1 green:1 blue:122.0/255.0 alpha:1],
                                            [UIColor colorWithRed:1 green:122.0/255.0 blue:61.0/255.0 alpha:1],
                                            [UIColor colorWithRed:61.0/255.0 green:61.0/255.0 blue:1 alpha:1],
                                            nil]];

        if ([segmentColors count] < [_sortedSpells count]) {
            NSLog(@"WARNING: Insufficient colors for number of data points");
            while ([segmentColors count] < [_sortedSpells count]) {
                UIColor* color = [UIColor whiteColor];
                [segmentColors addObject:color];
            }
            
        }
        
        _segmentColors = [NSArray arrayWithArray:segmentColors];
        
        _selectedSpellIndex = -1;
        
        NSLog(@"Pie chart data: count=%d, sum=%f", [data count], sum);
    }
    else {
        _data = nil;
        _sortedSpells = nil;
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
    CGColorSpaceRelease(rgbColorSpace);
    
    CGRect bounds = [self bounds];
    CGFloat chartWidth = (bounds.size.width - INSET*2) / 2;
    CGFloat chartHeight = bounds.size.height - INSET*2;

    // Flip co-ordinate system to bottom left going up and right.
    CGContextTranslateCTM(c, 0, bounds.size.height);
    CGContextScaleCTM(c, 1, -1);
    
    CTFontRef font = CTFontCreateUIFontForLanguage(kCTFontSystemFontType, 15, NULL);
    double lineHeight = CTFontGetAscent(font) + CTFontGetDescent(font) + CTFontGetLeading(font);

    CGFloat centerX = bounds.size.width / 4; // center of left side
    CGFloat centerY = bounds.size.height / 2;
    CGFloat radius = MIN(chartWidth / 2, chartHeight / 2);
    CGFloat startAngle = 0;
    
    NSEnumerator* colorEnumerator = [_segmentColors objectEnumerator];
    
    CGFloat textY = INSET + chartHeight - lineHeight;
    uint16_t spellIndex = 0;
        
    for (UCLSpell* spell in _sortedSpells) {
        NSNumber* value = [self.data objectForKey:spell];
        CGFloat ratio = [value doubleValue] / _sum;
        CGFloat endAngle = startAngle + (2 * M_PI * ratio);
        NSLog(@"Pie chart segment: name=%@, ratio=%.3f, startAngle=%.3f, endAngle=%.3f", 
              spell.name, ratio, startAngle, endAngle);
        
        CGFloat segmentOriginX = centerX;
        CGFloat segmentOriginY = centerY;

        if (spellIndex == _selectedSpellIndex) {
            CGFloat middleAngle = (startAngle + endAngle) / 2;
            segmentOriginX = centerX + 10 * cos(middleAngle);
            segmentOriginY = centerY + 10 * sin(middleAngle);
        }
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, segmentOriginX, segmentOriginY);
        CGPathAddArc(path, NULL, segmentOriginX, segmentOriginY, radius, startAngle, endAngle, 0);
        CGPathAddLineToPoint(path, NULL, segmentOriginX, segmentOriginY);
        CGPathCloseSubpath(path);

        UIColor* color = [colorEnumerator nextObject];
        CGContextSetFillColorWithColor(c, color.CGColor);
        CGContextAddPath(c, path);
        CGContextFillPath(c);

        if (spellIndex == _selectedSpellIndex) {
            CGContextSetStrokeColorWithColor(c, [UIColor whiteColor].CGColor);
            CGContextAddPath(c, path);
            CGContextSetLineJoin(c, kCGLineJoinMiter);
            CGContextSetLineWidth(c, 2);
            CGContextStrokePath(c);
        }
        
        CGPathRelease(path);

        if (spellIndex < 14) {
            CGFloat textLeft = bounds.size.width/2 + INSET;
            CGFloat textRight = bounds.size.width - INSET;
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
            CGContextSetTextPosition(c, textLeft, textY);
            CTLineDraw(line, c);
            CFRelease(line);
            
            text = [NSString stringWithFormat:@"%0.1f%%", percent];
            attributedText = [[NSAttributedString alloc] initWithString:text attributes:fontAttr];
            line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)attributedText);
            double lineWidth = CTLineGetTypographicBounds(line, NULL, NULL, NULL);
            CGContextSetTextPosition(c, textRight - lineWidth, textY);
            CTLineDraw(line, c);
            CFRelease(line);
            
            if (spellIndex == _selectedSpellIndex) {
                CGRect rect = CGRectMake(textLeft - 2, textY - 4, textRight - textLeft + 4, lineHeight + 4);
                CGContextSetStrokeColorWithColor(c, [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1].CGColor);
                CGContextSetLineJoin(c, kCGLineJoinMiter);
                CGContextSetLineWidth(c, 2);
                CGContextStrokeRect(c, rect);
            }

        }
        
        spellIndex++;
        startAngle = endAngle;
        textY -= lineHeight + 5;
    }
}

- (void)handleTap:(UIGestureRecognizer*)sender
{
    CGPoint loc = [sender locationOfTouch:0 inView:self];
    NSLog(@"Tap @ %f, %f", loc.x, loc.y);

    CGRect bounds = [self bounds];
    if (loc.x >= bounds.size.width/2 + INSET && loc.x < bounds.size.width-INSET) {
        CTFontRef font = CTFontCreateUIFontForLanguage(kCTFontSystemFontType, 15, NULL);
        double lineHeight = CTFontGetAscent(font) + CTFontGetDescent(font) + CTFontGetLeading(font);
        CGFloat relY = loc.y - INSET;
        uint16_t index = relY / (lineHeight + 5);
        NSLog(@"Tap on index %d", index);
        if (index >= 0 && index < [_sortedSpells count]) {
            _selectedSpellIndex = index;
        }
        else {
            _selectedSpellIndex = -1;
        }
        [self setNeedsDisplay];
    }
    else {
        _selectedSpellIndex = -1;
        [self setNeedsDisplay];
    }
}

@end
