//
//  OCDaysView.m
//  OCCalendar
//
//  Created by Oliver Rickard on 3/30/12.
//  Copyright (c) 2012 UC Berkeley. All rights reserved.
//

#import "OCDaysView.h"

@implementation OCDaysView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        
        startCellX = 3;
        startCellY = 0;
        endCellX = 3;
        endCellY = 0;
        
        hDiff = frame.size.width / 7;
        vDiff = frame.size.height / 6;
        
        cellWidth = hDiff / 2;
        cellHeight = vDiff / 2;
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    
    CGSize shadow2Offset = CGSizeMake(1, 1);
    CGFloat shadow2BlurRadius = 1;
    CGColorRef shadow2 = [UIColor blackColor].CGColor;
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
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
    
    //NSLog(@"weekdayOfFirst:%d", weekdayOfFirst);

	int numDaysInMonth = [calendar rangeOfUnit:NSDayCalendarUnit 
										inUnit:NSMonthCalendarUnit 
                                       forDate:dateOnFirst].length;
    
    //NSLog(@"month:%d, numDaysInMonth:%d", currentMonth, numDaysInMonth);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    didAddExtraRow = NO;
    
    
    
    //Find number of days in previous month
    NSDateComponents *prevDateParts = [[NSDateComponents alloc] init];
	[prevDateParts setMonth:month-1];
	[prevDateParts setYear:year];
	[prevDateParts setDay:1];
    
    NSDate *prevDateOnFirst = [calendar dateFromComponents:prevDateParts];
    
    [prevDateParts release];
    
    int numDaysInPrevMonth = [calendar rangeOfUnit:NSDayCalendarUnit 
										inUnit:NSMonthCalendarUnit 
                                       forDate:prevDateOnFirst].length;
    
    NSDateComponents *today = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
    
    //Draw the text for each of those days.
    for(int i = 0; i <= weekdayOfFirst-2; i++) {
        int day = numDaysInPrevMonth - weekdayOfFirst + 2 + i;
        
        NSString *str = [NSString stringWithFormat:@"%d", day];
        
        
        
        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, shadow2Offset, shadow2BlurRadius, shadow2);
        CGRect dayHeader2Frame = CGRectMake((i)*hDiff, 0, cellWidth, cellHeight);
        [[UIColor colorWithWhite:0.6f alpha:1.0f] setFill];
        [str drawInRect: dayHeader2Frame withFont: [UIFont fontWithName: @"Helvetica" size: 12] lineBreakMode: UILineBreakModeWordWrap alignment: UITextAlignmentCenter];
        CGContextRestoreGState(context);
    }
    
    
    BOOL endedOnSat = NO;
	int finalRow = 0;
	int day = 1;
	for (int i = 0; i < 6; i++) {
		for(int j = 0; j < 7; j++) {
			int dayNumber = i * 7 + j;
			
			if(dayNumber >= (weekdayOfFirst-1) && day <= numDaysInMonth) {
                NSString *str = [NSString stringWithFormat:@"%d", day];
                
                CGContextSaveGState(context);
                CGContextSetShadowWithColor(context, shadow2Offset, shadow2BlurRadius, shadow2);
                CGRect dayHeader2Frame = CGRectMake(j*hDiff, i*vDiff, cellWidth, cellHeight);
                if([today day] == day && [today month] == month && [today year] == year) {
                    CGFloat red = 0.98, green = 0.24, blue = 0.09, alpha =0.0;
                    if (delegate && [delegate respondsToSelector:@selector(getTodayColor)]) {
                        [[delegate getTodayColor] getRed:&red green:&green blue:&blue alpha:&alpha];
                    }
                    [[UIColor colorWithRed: red green: green blue: blue alpha: 1] setFill];
                } else {
                    [[UIColor whiteColor] setFill];
                }
                [str drawInRect: dayHeader2Frame withFont: [UIFont fontWithName: @"Helvetica" size: 12] lineBreakMode: UILineBreakModeWordWrap alignment: UITextAlignmentCenter];
                CGContextRestoreGState(context);
                
                finalRow = i;
                
                if(day == numDaysInMonth && j == 6) {
                    endedOnSat = YES;
                }
                
                if(i == 5) {
                    didAddExtraRow = YES;
                    //NSLog(@"didAddExtraRow");
                }
                
				++day;
			}
		}
	}
    
    //Find number of days in previous month
    NSDateComponents *nextDateParts = [[NSDateComponents alloc] init];
	[nextDateParts setMonth:month+1];
	[nextDateParts setYear:year];
	[nextDateParts setDay:1];
    
    NSDate *nextDateOnFirst = [calendar dateFromComponents:nextDateParts];
    
    [nextDateParts release];
    
    NSDateComponents *nextWeekdayComponents = [calendar components:NSWeekdayCalendarUnit fromDate:nextDateOnFirst];
	int weekdayOfNextFirst = [nextWeekdayComponents weekday];
    
    if(!endedOnSat) {
        //Draw the text for each of those days.
        for(int i = weekdayOfNextFirst - 1; i < 7; i++) {
            int day = i - weekdayOfNextFirst + 2;
            
            NSString *str = [NSString stringWithFormat:@"%d", day];
            
            CGContextSaveGState(context);
            CGContextSetShadowWithColor(context, shadow2Offset, shadow2BlurRadius, shadow2);
            CGRect dayHeader2Frame = CGRectMake((i)*hDiff, finalRow * vDiff, cellWidth, cellHeight);
            [[UIColor colorWithWhite:0.6f alpha:1.0f] setFill];
            [str drawInRect: dayHeader2Frame withFont: [UIFont fontWithName: @"Helvetica" size: 12] lineBreakMode: UILineBreakModeWordWrap alignment: UITextAlignmentCenter];
            CGContextRestoreGState(context);
        }
    }
}

- (void)setMonth:(int)month {
    currentMonth = month;
    [self setNeedsDisplay];
}

- (void)setYear:(int)year {
    currentYear = year;
    [self setNeedsDisplay];
}

- (void)resetRows {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
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
    didAddExtraRow = NO;
	
	int day = 1;
	for (int i = 0; i < 6; i++) {
		for(int j = 0; j < 7; j++) {
			int dayNumber = i * 7 + j;
			if(dayNumber >= (weekdayOfFirst - 1) && day <= numDaysInMonth) {
                if(i == 5) {
                    didAddExtraRow = YES;
                    //NSLog(@"didAddExtraRow");
                }
				++day;
			}
		}
	}
}

- (BOOL)addExtraRow {
    return didAddExtraRow;
}


@end
