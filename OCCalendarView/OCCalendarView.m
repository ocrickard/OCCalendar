//
//  OCCalendarView.m
//  OCCalendar
//
//  Created by Oliver Rickard on 3/30/12.
//  Copyright (c) 2012 UC Berkeley. All rights reserved.
//

#import "OCCalendarView.h"
#import "OCSelectionView.h"
#import "OCDaysView.h"
#import <QuartzCore/QuartzCore.h>

@implementation OCCalendarView

- (id)initAtPoint:(CGPoint)p withFrame:(CGRect)frame {
  return [self initAtPoint:p withFrame:frame arrowPosition:OCArrowPositionCentered];
}

- (id)initAtPoint:(CGPoint)p withFrame:(CGRect)frame arrowPosition:(OCArrowPosition)arrowPos {
  NSLog(@"Arrow Position: %u", arrowPos);
  
  //    CGRect frame = CGRectMake(p.x - 390*0.5, p.y - 31.4, 390, 270);
  self = [super initWithFrame:frame];
  if(self) {
    self.backgroundColor = [UIColor clearColor];
    
    calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		
		NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
		NSDateComponents *dateParts = [calendar components:unitFlags fromDate:[NSDate date]];
		currentMonth = [dateParts month];
		currentYear = [dateParts year];
    
    arrowPosition = arrowPos;
    
    selected = NO;
    startCellX = -1;
    startCellY = -1;
    endCellX = -1;
    endCellY = -1;
    
    hDiff = 43;
    vDiff = 30;
    
    selectionView = [[OCSelectionView alloc] initWithFrame:CGRectMake(66, 95, hDiff*7, vDiff*6)];
    [self addSubview:selectionView];
    
    daysView = [[OCDaysView alloc] initWithFrame:CGRectMake(65, 98, hDiff*7, vDiff*6)];
    [daysView setYear:currentYear];
    [daysView setMonth:currentMonth];
    [daysView resetRows];
    [self addSubview:daysView];
    
    selectionView.frame = CGRectMake(66, 95, hDiff * 7, ([daysView addExtraRow] ? 6 : 5)*vDiff);
    
    //Make the view really small and invisible
    CGAffineTransform tranny = CGAffineTransformMakeScale(0.1, 0.1);
    self.transform = tranny;
    self.alpha = 0.0f;
    
    //Animate in the view.
    [UIView beginAnimations:@"animateInCalendar" context:nil];
    [UIView setAnimationDuration:0.4f];
    self.transform = CGAffineTransformMakeScale(1.0, 1.0);
    self.alpha = 1.0f;
    [UIView commitAnimations];
  }
  return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if(CGRectContainsPoint(CGRectMake(55, 40, 30, 35), point)) {
        //User tapped the prevMonth button
        if(currentMonth == 1) {
            currentMonth = 12;
            currentYear--;
        } else {
            currentMonth--;
        }
        [UIView beginAnimations:@"fadeOutViews" context:nil];
        [UIView setAnimationDuration:0.1f];
        [daysView setAlpha:0.0f];
        [selectionView setAlpha:0.0f];
        [UIView commitAnimations];
        
        [self performSelector:@selector(resetViews) withObject:nil afterDelay:0.1f];
    } else if(CGRectContainsPoint(CGRectMake(335, 40, 30, 35), point)) {
        //User tapped the nextMonth button
        if(currentMonth == 12) {
            currentMonth = 1;
            currentYear++;
        } else {
            currentMonth++;
        }
        [UIView beginAnimations:@"fadeOutViews" context:nil];
        [UIView setAnimationDuration:0.1f];
        [daysView setAlpha:0.0f];
        [selectionView setAlpha:0.0f];
        [UIView commitAnimations];
        
        [self performSelector:@selector(resetViews) withObject:nil afterDelay:0.1f];
    }
}

- (void)resetViews {
    [selectionView resetSelection];
    [daysView setMonth:currentMonth];
    [daysView setYear:currentYear];
    [daysView resetRows];
    [daysView setNeedsDisplay];
    [self setNeedsDisplay];
    
    selectionView.frame = CGRectMake(66, 95, hDiff * 7, ([daysView addExtraRow] ? 6 : 5)*vDiff);
    
    [UIView beginAnimations:@"fadeInViews" context:nil];
    [UIView setAnimationDuration:0.1f];
    [daysView setAlpha:1.0f];
    [selectionView setAlpha:1.0f];
    [UIView commitAnimations];
}

- (void)setArrowPosition:(OCArrowPosition)pos {
    arrowPosition = pos;
}

- (NSDate *)getStartDate {
    CGPoint startPoint = [selectionView startPoint];
    
    int day = 1;
    int month = currentMonth;
    int year = currentYear;
	
	//Get the first day of the month
	NSDateComponents *dateParts = [[NSDateComponents alloc] init];
	[dateParts setMonth:month];
	[dateParts setYear:year];
	[dateParts setDay:1];
	NSDate *dateOnFirst = [calendar dateFromComponents:dateParts];
	[dateParts release];
	NSDateComponents *weekdayComponents = [calendar components:NSWeekdayCalendarUnit fromDate:dateOnFirst];
	int weekdayOfFirst = [weekdayComponents weekday];	
    
	int numDaysInMonth = [calendar rangeOfUnit:NSDayCalendarUnit 
										inUnit:NSMonthCalendarUnit 
                                       forDate:dateOnFirst].length;
    
    if(startPoint.y == 0 && startPoint.x+1 < weekdayOfFirst) {
        day = startPoint.x - weekdayOfFirst+2;
    } else {
        int countDays = 1;
        for (int i = 0; i < 6; i++) {
            for(int j = 0; j < 7; j++) {
                int dayNumber = i * 7 + j;
                if(dayNumber >= (weekdayOfFirst - 1) && day <= numDaysInMonth) {
                    if(i == startPoint.y && j == startPoint.x) {
                        day = countDays;
                    }
                    ++countDays;
                }
            }
        }
    }
    
    NSDateComponents *comps = [[[NSDateComponents alloc] init] autorelease];
    [comps setDay:day];
    [comps setMonth:month];
    [comps setYear:year];
    NSDate *retDate = [calendar dateFromComponents:comps];
    
    return retDate;
}

- (NSDate *)getEndDate {
    CGPoint endPoint = [selectionView endPoint];
    
    int day = 1;
    int month = currentMonth;
    int year = currentYear;
	
	//Get the first day of the month
	NSDateComponents *dateParts = [[NSDateComponents alloc] init];
	[dateParts setMonth:month];
	[dateParts setYear:year];
	[dateParts setDay:1];
	NSDate *dateOnFirst = [calendar dateFromComponents:dateParts];
	[dateParts release];
	NSDateComponents *weekdayComponents = [calendar components:NSWeekdayCalendarUnit fromDate:dateOnFirst];
	int weekdayOfFirst = [weekdayComponents weekday];	
    
	int numDaysInMonth = [calendar rangeOfUnit:NSDayCalendarUnit 
										inUnit:NSMonthCalendarUnit 
                                       forDate:dateOnFirst].length;
	if(endPoint.y == 0 && endPoint.x+1 < weekdayOfFirst) {
        day = endPoint.x - weekdayOfFirst+2;
    } else {
        int countDays = 1;
        for (int i = 0; i < 6; i++) {
            for(int j = 0; j < 7; j++) {
                int dayNumber = i * 7 + j;
                if(dayNumber >= (weekdayOfFirst - 1) && day <= numDaysInMonth) {
                    if(i == endPoint.y && j == endPoint.x) {
                        day = countDays;
                    }
                    ++countDays;
                }
            }
        }
    }
        
    NSDateComponents *comps = [[[NSDateComponents alloc] init] autorelease];
    [comps setDay:day];
    [comps setMonth:month];
    [comps setYear:year];
    NSDate *retDate = [calendar dateFromComponents:comps];
    
    return retDate;
}

- (void)drawRect:(CGRect)rect
{    
    //// Get day titles from current Locale
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSArray *dayTitles = [dateFormatter shortStandaloneWeekdaySymbols];
    NSArray *monthTitles = [dateFormatter standaloneMonthSymbols];
            
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* bigBoxInnerShadowColor = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.56];
    UIColor* backgroundLightColor = [UIColor colorWithWhite:0.2 alpha: 1];
    UIColor* lineLightColor = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.27];
    UIColor* lightColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.15];
    UIColor* darkColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.72];
    UIColor* boxStroke = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.59];
    
    //// Gradient Declarations
    NSArray* gradient2Colors = [NSArray arrayWithObjects: 
                                (id)darkColor.CGColor, 
                                (id)lightColor.CGColor, nil];
    CGFloat gradient2Locations[] = {0, 1};
    CGGradientRef gradient2 = CGGradientCreateWithColors(colorSpace, (CFArrayRef)gradient2Colors, gradient2Locations);
    
    //// Shadow Declarations
    CGColorRef bigBoxInnerShadow = bigBoxInnerShadowColor.CGColor;
    CGSize bigBoxInnerShadowOffset = CGSizeMake(0, 1);
    CGFloat bigBoxInnerShadowBlurRadius = 1;
    CGColorRef shadow = [UIColor blackColor].CGColor;
    CGSize shadowOffset = CGSizeMake(-1, -0);
    CGFloat shadowBlurRadius = 0;
    CGColorRef shadow2 = [UIColor blackColor].CGColor;
    CGSize shadow2Offset = CGSizeMake(1, 1);
    CGFloat shadow2BlurRadius = 1;
    CGColorRef backgroundShadow = [UIColor blackColor].CGColor;
    CGSize backgroundShadowOffset = CGSizeMake(2, 3);
    CGFloat backgroundShadowBlurRadius = 5;
    
    
    //////// Draw background of popover
    UIBezierPath* roundedRectanglePath = [UIBezierPath bezierPath];
    
    float arrowPosX = 208;
    
    if(arrowPosition == OCArrowPositionLeft) {
        arrowPosX = 67;
    } else if(arrowPosition == OCArrowPositionRight) {
        arrowPosX = 346;
    }
    
    if([daysView addExtraRow]) {
        NSLog(@"Added extra row");
        [roundedRectanglePath moveToPoint: CGPointMake(42, 267.42)];
        [roundedRectanglePath addCurveToPoint: CGPointMake(52, 278.4) controlPoint1: CGPointMake(42, 273.49) controlPoint2: CGPointMake(46.48, 278.4)];
        [roundedRectanglePath addLineToPoint: CGPointMake(361.5, 278.4)];
        [roundedRectanglePath addCurveToPoint: CGPointMake(371.5, 267.42) controlPoint1: CGPointMake(367.02, 278.4) controlPoint2: CGPointMake(371.5, 273.49)];
        [roundedRectanglePath addLineToPoint: CGPointMake(371.5, 53.9)];
        [roundedRectanglePath addCurveToPoint: CGPointMake(361.5, 43.9) controlPoint1: CGPointMake(371.5, 48.38) controlPoint2: CGPointMake(367.02, 43.9)];
        [roundedRectanglePath addLineToPoint: CGPointMake(arrowPosX+13.5, 43.9)];
        [roundedRectanglePath addLineToPoint: CGPointMake(arrowPosX, 31.4)];
        [roundedRectanglePath addLineToPoint: CGPointMake(arrowPosX-13.5, 43.9)];
        [roundedRectanglePath addLineToPoint: CGPointMake(52, 43.9)];
        [roundedRectanglePath addCurveToPoint: CGPointMake(42, 53.9) controlPoint1: CGPointMake(46.48, 43.9) controlPoint2: CGPointMake(42, 48.38)];
        [roundedRectanglePath addLineToPoint: CGPointMake(42, 267.42)];
    } else {
        [roundedRectanglePath moveToPoint: CGPointMake(42, 246.4)];
        [roundedRectanglePath addCurveToPoint: CGPointMake(52, 256.4) controlPoint1: CGPointMake(42, 251.92) controlPoint2: CGPointMake(46.48, 256.4)];
        [roundedRectanglePath addLineToPoint: CGPointMake(361.5, 256.4)];
        [roundedRectanglePath addCurveToPoint: CGPointMake(371.5, 246.4) controlPoint1: CGPointMake(367.02, 256.4) controlPoint2: CGPointMake(371.5, 251.92)];
        [roundedRectanglePath addLineToPoint: CGPointMake(371.5, 53.9)];
        [roundedRectanglePath addCurveToPoint: CGPointMake(361.5, 43.9) controlPoint1: CGPointMake(371.5, 48.38) controlPoint2: CGPointMake(367.02, 43.9)];
        [roundedRectanglePath addLineToPoint: CGPointMake(arrowPosX+13.5, 43.9)];
        [roundedRectanglePath addLineToPoint: CGPointMake(arrowPosX, 31.4)];
        [roundedRectanglePath addLineToPoint: CGPointMake(arrowPosX-13.5, 43.9)];
        [roundedRectanglePath addLineToPoint: CGPointMake(52, 43.9)];
        [roundedRectanglePath addCurveToPoint: CGPointMake(42, 53.9) controlPoint1: CGPointMake(46.48, 43.9) controlPoint2: CGPointMake(42, 48.38)];
        [roundedRectanglePath addLineToPoint: CGPointMake(42, 246.4)];
        NSLog(@"did not add extra row");
    }
    
    [roundedRectanglePath closePath];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, backgroundShadowOffset, backgroundShadowBlurRadius, backgroundShadow);
    [backgroundLightColor setFill];
    [roundedRectanglePath fill];
    
    ////// background Inner Shadow
    CGRect roundedRectangleBorderRect = CGRectInset([roundedRectanglePath bounds], -bigBoxInnerShadowBlurRadius, -bigBoxInnerShadowBlurRadius);
    roundedRectangleBorderRect = CGRectOffset(roundedRectangleBorderRect, -bigBoxInnerShadowOffset.width, -bigBoxInnerShadowOffset.height);
    roundedRectangleBorderRect = CGRectInset(CGRectUnion(roundedRectangleBorderRect, [roundedRectanglePath bounds]), -1, -1);
    
    UIBezierPath* roundedRectangleNegativePath = [UIBezierPath bezierPathWithRect: roundedRectangleBorderRect];
    [roundedRectangleNegativePath appendPath: roundedRectanglePath];
    roundedRectangleNegativePath.usesEvenOddFillRule = YES;
    
    CGContextSaveGState(context);
    {
        CGFloat xOffset = bigBoxInnerShadowOffset.width + round(roundedRectangleBorderRect.size.width);
        CGFloat yOffset = bigBoxInnerShadowOffset.height;
        CGContextSetShadowWithColor(context,
                                    CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset)),
                                    bigBoxInnerShadowBlurRadius,
                                    bigBoxInnerShadow);
        
        [roundedRectanglePath addClip];
        CGAffineTransform transform = CGAffineTransformMakeTranslation(-round(roundedRectangleBorderRect.size.width), 0);
        [roundedRectangleNegativePath applyTransform: transform];
        [[UIColor grayColor] setFill];
        [roundedRectangleNegativePath fill];
    }
    CGContextRestoreGState(context);
    
    CGContextRestoreGState(context);
    
    [boxStroke setStroke];
    roundedRectanglePath.lineWidth = 0.5;
    [roundedRectanglePath stroke];
    
    
    //Dividers
    float addedHeight = ([daysView addExtraRow] ? 24 : 0);
    for(int i = 0; i < dayTitles.count-1; i++) {
        //// divider Drawing
        UIBezierPath* dividerPath = [UIBezierPath bezierPathWithRect: CGRectMake(96+i*hDiff, 73.5, 0.5, 168+addedHeight)];
        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow);
        [lineLightColor setFill];
        [dividerPath fill];
        CGContextRestoreGState(context);
    }
    
    
    //// Rounded Rectangle 2 Drawing
    UIBezierPath* roundedRectangle2Path = [UIBezierPath bezierPath];
    if([daysView addExtraRow]) {
        [roundedRectangle2Path moveToPoint: CGPointMake(42, 267.42)];
        [roundedRectangle2Path addCurveToPoint: CGPointMake(52, 278.4) controlPoint1: CGPointMake(42, 273.49) controlPoint2: CGPointMake(46.48, 278.4)];
        [roundedRectangle2Path addLineToPoint: CGPointMake(361.5, 278.4)];
        [roundedRectangle2Path addCurveToPoint: CGPointMake(371.5, 267.42) controlPoint1: CGPointMake(367.02, 278.4) controlPoint2: CGPointMake(371.5, 273.49)];
        [roundedRectangle2Path addLineToPoint: CGPointMake(371.5, 53.9)];
        [roundedRectangle2Path addCurveToPoint: CGPointMake(361.5, 43.9) controlPoint1: CGPointMake(371.5, 48.38) controlPoint2: CGPointMake(367.02, 43.9)];
        [roundedRectangle2Path addLineToPoint: CGPointMake(arrowPosX+13.5, 43.9)];
        [roundedRectangle2Path addLineToPoint: CGPointMake(arrowPosX, 31.4)];
        [roundedRectangle2Path addLineToPoint: CGPointMake(arrowPosX-13.5, 43.9)];
        [roundedRectangle2Path addLineToPoint: CGPointMake(52, 43.9)];
        [roundedRectangle2Path addCurveToPoint: CGPointMake(42, 53.9) controlPoint1: CGPointMake(46.48, 43.9) controlPoint2: CGPointMake(42, 48.38)];
        [roundedRectangle2Path addLineToPoint: CGPointMake(42, 267.42)];
    } else {
        [roundedRectangle2Path moveToPoint: CGPointMake(42, 246.4)];
        [roundedRectangle2Path addCurveToPoint: CGPointMake(52, 256.4) controlPoint1: CGPointMake(42, 251.92) controlPoint2: CGPointMake(46.48, 256.4)];
        [roundedRectangle2Path addLineToPoint: CGPointMake(361.5, 256.4)];
        [roundedRectangle2Path addCurveToPoint: CGPointMake(371.5, 246.4) controlPoint1: CGPointMake(367.02, 256.4) controlPoint2: CGPointMake(371.5, 251.92)];
        [roundedRectangle2Path addLineToPoint: CGPointMake(371.5, 53.9)];
        [roundedRectangle2Path addCurveToPoint: CGPointMake(361.5, 43.9) controlPoint1: CGPointMake(371.5, 48.38) controlPoint2: CGPointMake(367.02, 43.9)];
        [roundedRectangle2Path addLineToPoint: CGPointMake(arrowPosX+13.5, 43.9)];
        [roundedRectangle2Path addLineToPoint: CGPointMake(arrowPosX, 31.4)];
        [roundedRectangle2Path addLineToPoint: CGPointMake(arrowPosX-13.5, 43.9)];
        [roundedRectangle2Path addLineToPoint: CGPointMake(52, 43.9)];
        [roundedRectangle2Path addCurveToPoint: CGPointMake(42, 53.9) controlPoint1: CGPointMake(46.48, 43.9) controlPoint2: CGPointMake(42, 48.38)];
        [roundedRectangle2Path addLineToPoint: CGPointMake(42, 246.4)];
    }
    [roundedRectangle2Path closePath];
    CGContextSaveGState(context);
    [roundedRectangle2Path addClip];
    float endPoint = ([daysView addExtraRow] ? 278.4 : 256.4);
    CGContextDrawLinearGradient(context, gradient2, CGPointMake(206.75, endPoint), CGPointMake(206.75, 31.4), 0);
    CGContextRestoreGState(context);
    
    for(int i = 0; i < dayTitles.count; i++) {
        //// dayHeader Drawing
        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, shadow2Offset, shadow2BlurRadius, shadow2);
        CGRect dayHeaderFrame = CGRectMake(60+i*hDiff, 75, 30, 14);
        [[UIColor whiteColor] setFill];
        [((NSString *)[dayTitles objectAtIndex:i]) drawInRect: dayHeaderFrame withFont: [UIFont fontWithName: @"Helvetica" size: 12] lineBreakMode: UILineBreakModeWordWrap alignment: UITextAlignmentCenter];
        CGContextRestoreGState(context);
    }
    
    int month = currentMonth;
    int year = currentYear;
    
	NSString *monthTitle = [NSString stringWithFormat:@"%@ %d", [monthTitles objectAtIndex:(month - 1)], year];
    
    //// Month Header Drawing
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadow2Offset, shadow2BlurRadius, shadow2);
    CGRect textFrame = CGRectMake(94, 53, 220, 18);
    [[UIColor whiteColor] setFill];
    [monthTitle drawInRect: textFrame withFont: [UIFont fontWithName: @"Helvetica" size: 12] lineBreakMode: UILineBreakModeWordWrap alignment: UITextAlignmentCenter];
    CGContextRestoreGState(context);
    
    //// backArrow Drawing
    UIBezierPath* backArrowPath = [UIBezierPath bezierPath];
    [backArrowPath moveToPoint: CGPointMake(66, 58.5)];
    [backArrowPath addLineToPoint: CGPointMake(60, 62.5)];
    [backArrowPath addCurveToPoint: CGPointMake(66, 65.5) controlPoint1: CGPointMake(60, 62.5) controlPoint2: CGPointMake(66, 65.43)];
    [backArrowPath addCurveToPoint: CGPointMake(66, 58.5) controlPoint1: CGPointMake(66, 65.57) controlPoint2: CGPointMake(66, 58.5)];
    [backArrowPath closePath];
    [[UIColor whiteColor] setFill];
    [backArrowPath fill];
    
    //// forwardArrow Drawing
    UIBezierPath* forwardArrowPath = [UIBezierPath bezierPath];
    [forwardArrowPath moveToPoint: CGPointMake(349.5, 58.5)];
    [forwardArrowPath addLineToPoint: CGPointMake(355.5, 62)];
    [forwardArrowPath addCurveToPoint: CGPointMake(349.5, 65.5) controlPoint1: CGPointMake(355.5, 62) controlPoint2: CGPointMake(349.5, 65.43)];
    [forwardArrowPath addCurveToPoint: CGPointMake(349.5, 58.5) controlPoint1: CGPointMake(349.5, 65.57) controlPoint2: CGPointMake(349.5, 58.5)];
    [forwardArrowPath closePath];
    [[UIColor whiteColor] setFill];
    [forwardArrowPath fill];
    
    //// Cleanup
    CGGradientRelease(gradient2);
    CGColorSpaceRelease(colorSpace);
}

- (void)dealloc {
    
    [selectionView release];
    [calendar release];
    
    [super dealloc];
    
}

@end
