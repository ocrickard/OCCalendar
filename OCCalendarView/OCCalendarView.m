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
#import "OCConstant.h"
#import <QuartzCore/QuartzCore.h>

@implementation OCCalendarView

@synthesize delegate;

- (id)initAtPoint:(CGPoint)p withFrame:(CGRect)frame {
    return [self initAtPoint:p withFrame:frame arrowPosition:OCArrowPositionCentered];
}

- (id)initAtPoint:(CGPoint)p withFrame:(CGRect)frame arrowPosition:(OCArrowPosition)arrowPos {
    //NSLog(@"Arrow Position: %u", arrowPos);
    
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
        
        hDiff = MAX((frame.size.width - MARGIN_LEFT - MARGIN_RIGHT) / 7, DEFAULT_GRID_WIDTH);
        vDiff = MIN((frame.size.height - DEFAULT_DAYS_VIEW_Y - DEFAULT_WEEK_TITLE_HEIGHT) / 7, DEFAULT_GRID_HEIGHT);
        
        selectionView = [[OCSelectionView alloc] initWithFrame:CGRectMake(MARGIN_LEFT, DEFAULT_DAYS_VIEW_Y, hDiff*7, vDiff*6)];
        [self addSubview:selectionView];
        
        daysView = [[OCDaysView alloc] initWithFrame:CGRectMake(MARGIN_LEFT, DEFAULT_DAYS_VIEW_Y, hDiff*7, vDiff*6)];
        [daysView setYear:currentYear];
        [daysView setMonth:currentMonth];
        [daysView resetRows];
        [self addSubview:daysView];
        
        selectionView.frame = CGRectMake(MARGIN_LEFT, DEFAULT_DAYS_VIEW_Y, hDiff * 7, ([daysView addExtraRow] ? 6 : 5)*vDiff);
        
        //Make the view really small and invisible
        CGAffineTransform tranny = CGAffineTransformMakeScale(0.1, 0.1);
        self.transform = tranny;
        self.alpha = 0.0f;
        
        [self performSelector:@selector(animateIn)];
    }
    return self;
}

- (void)animateIn {
    //Animate in the view.
    [UIView beginAnimations:@"animateInCalendar" context:nil];
    [UIView setAnimationDuration:0.4f];
    self.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    self.alpha = 1.0f;
    [UIView commitAnimations];
}

- (void)resetViews {
    [selectionView resetSelection];
    [daysView setMonth:currentMonth];
    [daysView setYear:currentYear];
    [daysView resetRows];
    [daysView setNeedsDisplay];
    [self setNeedsDisplay];
    
    selectionView.frame = CGRectMake(MARGIN_LEFT, DEFAULT_DAYS_VIEW_Y, hDiff * 7, ([daysView addExtraRow] ? 6 : 5)*vDiff);

    [UIView beginAnimations:@"fadeInViews" context:nil];
    [UIView setAnimationDuration:0.1f];
    [daysView setAlpha:1.0f];
    [selectionView setAlpha:1.0f];
    [UIView commitAnimations];
}


#pragma mark - Getter/Setter

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}

- (void)setCalendarDelegate:(id<OCCalendarDelegate>)d {
    delegate = d;
    selectionView.delegate = d;
    daysView.delegate = d;
}

- (CGRect)getLeftArrowRect {
    float x = MARGIN_LEFT;
    float y = MARGIN_TOP + ANCHOR_HEIGHT;
    return CGRectMake(x, y, DEFAULT_ARROWBOX_WIDTH, DEFAULT_ARROWBOX_HEIGHT);
}

- (CGRect)getRightArrowRect {
    float x = self.frame.size.width - MARGIN_RIGHT - hDiff;
    float y = MARGIN_TOP + ANCHOR_HEIGHT;
    return CGRectMake(x, y, DEFAULT_ARROWBOX_WIDTH, DEFAULT_ARROWBOX_HEIGHT);    
}

- (void)setArrowPosition:(OCArrowPosition)pos {
    arrowPosition = pos;
}

- (NSDate *)getStartDate {
    CGPoint startPoint = [selectionView startPoint];
    
    int day = 1;
    int month = currentMonth;
    int year = currentYear;
    
    //NSLog(@"startCurrentMonth:%d", currentMonth);
	
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
        day = startPoint.x - weekdayOfFirst + 2;
    } else {
        int countDays = 1;
        for (int i = 0; i < 6; i++) {
            for(int j = 0; j < 7; j++) {
                int dayNumber = i * 7 + j;
                if(dayNumber >= (weekdayOfFirst - 1)) {
                    if(i == startPoint.y && j == startPoint.x) {
                        day = countDays;
                    }
                    ++countDays;
                } else if(countDays > numDaysInMonth) {
                    if(i == startPoint.y && j == startPoint.x) {
                        day = (countDays - numDaysInMonth);
                        month = currentMonth + 1;
                    }
                    countDays++;
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
    
    //NSLog(@"endPoint:(%f,%f)", endPoint.x, endPoint.y);
    
    int day = 1;
    int month = currentMonth;
    int year = currentYear;
    
    //NSLog(@"endCurrentMonth:%d", currentMonth);
	
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
        day = endPoint.x - weekdayOfFirst + 2;
    } else {
        int countDays = 1;
        for (int i = 0; i < 6; i++) {
            for(int j = 0; j < 7; j++) {
                int dayNumber = i * 7 + j;
                if(dayNumber >= (weekdayOfFirst - 1) && countDays <= numDaysInMonth) {
                    if(i == endPoint.y && j == endPoint.x) {
                        day = countDays;
                        
                        //NSLog(@"endDay:%d", day);
                    }
                    ++countDays;
                } else if(countDays > numDaysInMonth) {
                    if(i == endPoint.y && j == endPoint.x) {
                        day = (countDays - numDaysInMonth);
                        month = currentMonth + 1;
                    }
                    countDays++;
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

- (void)setStartDate:(NSDate *)sDate {
    //NSLog(@"setStartDate");
    
    NSDateComponents *sComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:sDate];
    
    if([sComponents month] != currentMonth) {
        currentMonth = [sComponents month];
    }
    if([sComponents year] != currentYear) {
        currentYear = [sComponents year];
    }
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
    
    BOOL breakLoop = NO;
    int countDays = 1;
    for (int i = 0; i < 6; i++) {
        if(breakLoop) {
            break;
        }
        for(int j = 0; j < 7; j++) {
            int dayNumber = i * 7 + j;
            if(dayNumber >= (weekdayOfFirst - 1) && day <= numDaysInMonth) {
                if(countDays == [sComponents day]) {
                    CGPoint thePoint = CGPointMake(j, i);
                    [selectionView setStartPoint:thePoint];
                    breakLoop = YES;
                    break;
                }
                ++countDays;
            }
        }
    }
    
    [daysView setMonth:currentMonth];
    [daysView setYear:currentYear];
    [daysView resetRows];
    [daysView setNeedsDisplay];
}

- (void)setEndDate:(NSDate *)eDate {
    //NSLog(@"setEndDate");
    NSDateComponents *eComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:eDate];
    
    if([eComponents month] != currentMonth) {
        currentMonth = [eComponents month];
    }
    if([eComponents year] != currentYear) {
        currentYear = [eComponents year];
    }
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
    
    BOOL breakLoop = NO;
    int countDays = 1;
    for (int i = 0; i < 6; i++) {
        if(breakLoop) {
            break;
        }
        for(int j = 0; j < 7; j++) {
            int dayNumber = i * 7 + j;
            if(dayNumber >= (weekdayOfFirst - 1) && day <= numDaysInMonth) {
                if(countDays == [eComponents day]) {
                    CGPoint thePoint = CGPointMake(j, i);
                    [selectionView setEndPoint:thePoint];
                    breakLoop = YES;
                    break;
                }
                ++countDays;
            }
        }
    }
    [daysView setMonth:currentMonth];
    [daysView setYear:currentYear];
    [daysView resetRows];
    [daysView setNeedsDisplay];
}

#pragma mark - Touch events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if(CGRectContainsPoint([self getLeftArrowRect], point)) {
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
    } else if(CGRectContainsPoint([self getRightArrowRect], point)) {
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

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    if(CGRectContainsPoint(selectionView.frame, point)) {
        BOOL isSingleSelection = delegate && [delegate respondsToSelector:@selector(shouldBeSingleSelection)];
        isSingleSelection = isSingleSelection ? [delegate shouldBeSingleSelection] : isSingleSelection;
        
        if (delegate && [delegate respondsToSelector:@selector(selectingWithStartDate:endDate:)]) {
            NSDate *startDate = [[self getStartDate] retain];
            NSDate *endDate = [[self getEndDate] retain];
            
            if (isSingleSelection) {
                if ([startDate compare:endDate] == NSOrderedSame) {
                    [delegate selectingWithStartDate:startDate endDate:endDate];
                }
            } else {
                if([startDate compare:endDate] == NSOrderedAscending)
                    [delegate selectingWithStartDate:startDate endDate:endDate];
                else
                    [delegate selectingWithStartDate:endDate endDate:startDate];
            }
            
            NSLog(@"In SelectionView at date (%@,%@)",startDate,endDate);
            [startDate release];
            [endDate release];
        }
    }
}


#pragma mark - Draw

- (void)drawRect:(CGRect)rect
{    
    NSLog(@"draw in rect(%f,%f,%f,%f)",rect.origin.x,rect.origin.y,rect.size.width,rect.size.height);
    
    //// Get day titles from current Locale
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:[[NSLocale preferredLanguages] objectAtIndex:0]] autorelease]];
    NSArray *dayTitles = [dateFormatter shortStandaloneWeekdaySymbols];
    NSArray *monthTitles = [dateFormatter standaloneMonthSymbols];
    [dateFormatter release];
    
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    CGFloat red = 1.0, green = 1.0, blue = 1.0, alpha =0.0;
    if (delegate && [delegate respondsToSelector:@selector(getCalendarBackgroundColor)]) {
        [[delegate getCalendarBackgroundColor] getRed:&red green:&green blue:&blue alpha:&alpha];
    }
    UIColor* bigBoxInnerShadowColor = [UIColor colorWithRed:red green:green blue:blue alpha: 0.56];
    UIColor* backgroundLightColor = [UIColor colorWithRed: red green: green blue: blue alpha: 1];
    UIColor* lineLightColor = [UIColor colorWithRed: red green: green blue: blue alpha: 0.27];
    UIColor* lightColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.8];
    UIColor* darkColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 1];
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
    
    float h = self.frame.size.height - 7 - vDiff;   // 7 is shadow
    float w = self.frame.size.width - 7;
    float g = 20;
    float arrowPosX = w / 2;
    
    if(arrowPosition == OCArrowPositionLeft) {
        arrowPosX = MARGIN_LEFT + g;
    } else if(arrowPosition == OCArrowPositionRight) {
        arrowPosX = w - MARGIN_LEFT - g;
    }
    
    float arrowPosY = arrowPosition != OCArrowPositionNone ? 0 : ANCHOR_HEIGHT;
    float addedHeight = ([daysView addExtraRow] ? vDiff : 0);
    float newHeight = h + addedHeight;

    [roundedRectanglePath moveToPoint: CGPointMake(0, newHeight - g)];
    [roundedRectanglePath addCurveToPoint: CGPointMake(g, newHeight) controlPoint1: CGPointMake(0, newHeight) controlPoint2: CGPointMake(0, newHeight)];
    [roundedRectanglePath addLineToPoint: CGPointMake(w - g, newHeight)];
    [roundedRectanglePath addCurveToPoint: CGPointMake(w, newHeight - g) controlPoint1: CGPointMake(w, newHeight) controlPoint2: CGPointMake(w, newHeight)];
    [roundedRectanglePath addLineToPoint: CGPointMake(w, ANCHOR_HEIGHT + g)];
    [roundedRectanglePath addCurveToPoint: CGPointMake(w - g, ANCHOR_HEIGHT) controlPoint1: CGPointMake(w, ANCHOR_HEIGHT) controlPoint2: CGPointMake(w, ANCHOR_HEIGHT)];
    [roundedRectanglePath addLineToPoint: CGPointMake(arrowPosX+13.5, ANCHOR_HEIGHT)];
    [roundedRectanglePath addLineToPoint: CGPointMake(arrowPosX, arrowPosY)];
    [roundedRectanglePath addLineToPoint: CGPointMake(arrowPosX-13.5, ANCHOR_HEIGHT)];
    [roundedRectanglePath addLineToPoint: CGPointMake(g, ANCHOR_HEIGHT)];
    [roundedRectanglePath addCurveToPoint: CGPointMake(0, ANCHOR_HEIGHT + g) controlPoint1: CGPointMake(0, ANCHOR_HEIGHT) controlPoint2: CGPointMake(0, ANCHOR_HEIGHT)];
    [roundedRectanglePath addLineToPoint: CGPointMake(0, newHeight - g)];
    
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
    float prefiX = MARGIN_LEFT + hDiff - 8;
    float divHeight = vDiff * 5 + addedHeight + DEFAULT_WEEK_TITLE_HEIGHT;
    for(int i = 0; i < dayTitles.count-1; i++) {
        //// divider Drawing
        UIBezierPath* dividerPath = [UIBezierPath bezierPathWithRect: CGRectMake(prefiX+i*hDiff, DEFAULT_WEEK_TITLE_Y, 0.5, divHeight)];
        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow);
        [lineLightColor setFill];
        [dividerPath fill];
        CGContextRestoreGState(context);
    }
    
    
    //// Rounded Rectangle 2 Drawing
    UIBezierPath* roundedRectangle2Path = [UIBezierPath bezierPath];
    [roundedRectangle2Path moveToPoint: CGPointMake(0, newHeight - g)];
    [roundedRectangle2Path addCurveToPoint: CGPointMake(g, newHeight) controlPoint1: CGPointMake(0, newHeight) controlPoint2: CGPointMake(0, newHeight)];
    [roundedRectangle2Path addLineToPoint: CGPointMake(w - g, newHeight)];
    [roundedRectangle2Path addCurveToPoint: CGPointMake(w, newHeight - g) controlPoint1: CGPointMake(w, newHeight) controlPoint2: CGPointMake(w, newHeight)];
    [roundedRectangle2Path addLineToPoint: CGPointMake(w, ANCHOR_HEIGHT + g)];
    [roundedRectangle2Path addCurveToPoint: CGPointMake(w - g, ANCHOR_HEIGHT) controlPoint1: CGPointMake(w, ANCHOR_HEIGHT) controlPoint2: CGPointMake(w, ANCHOR_HEIGHT)];
    [roundedRectangle2Path addLineToPoint: CGPointMake(arrowPosX+13.5, ANCHOR_HEIGHT)];
    [roundedRectangle2Path addLineToPoint: CGPointMake(arrowPosX, arrowPosY)];
    [roundedRectangle2Path addLineToPoint: CGPointMake(arrowPosX-13.5, ANCHOR_HEIGHT)];
    [roundedRectangle2Path addLineToPoint: CGPointMake(g, ANCHOR_HEIGHT)];
    [roundedRectangle2Path addCurveToPoint: CGPointMake(0, ANCHOR_HEIGHT + g) controlPoint1: CGPointMake(0, ANCHOR_HEIGHT) controlPoint2: CGPointMake(0, ANCHOR_HEIGHT)];
    [roundedRectangle2Path addLineToPoint: CGPointMake(0, newHeight - g)];
    
    [roundedRectangle2Path closePath];
    CGContextSaveGState(context);
    [roundedRectangle2Path addClip];
    float endPoint = newHeight;
    CGContextDrawLinearGradient(context, gradient2, CGPointMake(1, endPoint), CGPointMake(1, 0), 0);
    CGContextRestoreGState(context);
    
    for(int i = 0; i < dayTitles.count; i++) {
        //// dayHeader Drawing
        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, shadow2Offset, shadow2BlurRadius, shadow2);
        CGRect dayHeaderFrame = CGRectMake(MARGIN_LEFT - 5 +i * hDiff, DEFAULT_WEEK_TITLE_Y, 30, 14);
        [[UIColor whiteColor] setFill];
        [((NSString *)[dayTitles objectAtIndex:i]) drawInRect: dayHeaderFrame withFont: [UIFont fontWithName: @"Helvetica" size: 10] lineBreakMode: UILineBreakModeWordWrap alignment: UITextAlignmentCenter];
        CGContextRestoreGState(context);
    }
    
    int month = currentMonth;
    int year = currentYear;
    
	NSString *monthTitle = [NSString stringWithFormat:@"%@ %d", [monthTitles objectAtIndex:(month - 1)], year];
    
    //// Month Header Drawing
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadow2Offset, shadow2BlurRadius, shadow2);
    CGRect textFrame = CGRectMake((w - DEFAULT_MON_TITLE_WIDTH)/2, g, DEFAULT_MON_TITLE_WIDTH, DEFAULT_MON_TITLE_HEIGHT);
    [[UIColor whiteColor] setFill];
    [monthTitle drawInRect: textFrame withFont: [UIFont fontWithName: @"Helvetica" size: 12] lineBreakMode: UILineBreakModeWordWrap alignment: UITextAlignmentCenter];
    CGContextRestoreGState(context);
    
    //// backArrow Drawing
    CGRect r = [self getLeftArrowRect];
    float aX = r.origin.x + r.size.width * 0.667;
    float aY = r.origin.y;
    //NSLog(@"< left pos(%f,%f)",aX,aY);
    UIBezierPath* backArrowPath = [UIBezierPath bezierPath];
    [backArrowPath moveToPoint: CGPointMake(aX, aY)];
    [backArrowPath addLineToPoint: CGPointMake(aX - 6, aY + 4)];
    [backArrowPath addCurveToPoint: CGPointMake(aX, aY + 8) controlPoint1: CGPointMake(aX - 6, aY + 4) controlPoint2: CGPointMake(aX, aY + 8)];
    [backArrowPath addCurveToPoint: CGPointMake(aX, aY) controlPoint1: CGPointMake(aX - 6, aY + 4) controlPoint2: CGPointMake(aX, aY)];
    [backArrowPath closePath];
    [[UIColor whiteColor] setFill];
    [backArrowPath fill];
    
    //// forwardArrow Drawing
    r = [self getRightArrowRect];
    aX = r.origin.x + r.size.width * 0.333;
    aY = r.origin.y;
    //NSLog(@"> right pos(%f,%f)",aX,aY);
    UIBezierPath* forwardArrowPath = [UIBezierPath bezierPath];
    [forwardArrowPath moveToPoint: CGPointMake(aX, aY)];
    [forwardArrowPath addLineToPoint: CGPointMake(aX + 6, aY + 4)];
    [forwardArrowPath addCurveToPoint: CGPointMake(aX, aY + 8) controlPoint1: CGPointMake(aX + 6, aY + 4) controlPoint2: CGPointMake(aX, aY + 8)];
    [forwardArrowPath addCurveToPoint: CGPointMake(aX, aY) controlPoint1: CGPointMake(aX + 6, aY + 4) controlPoint2: CGPointMake(aX, aY)];
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
