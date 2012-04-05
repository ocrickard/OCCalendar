//
//  OCDaysView.m
//  OCCalendar
//
//  Created by Oliver Rickard on 3/30/12.
//  Copyright (c) 2012 UC Berkeley. All rights reserved.
//

#import "OCDaysView.h"

@implementation OCDaysView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        
        startCellX = 3;
        startCellY = 0;
        endCellX = 3;
        endCellY = 0;
        
        hDiff = 43;
        vDiff = 30;
        
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
    
    NSLog(@"weekdayOfFirst:%d", weekdayOfFirst);

	int numDaysInMonth = [calendar rangeOfUnit:NSDayCalendarUnit 
										inUnit:NSMonthCalendarUnit 
                                       forDate:dateOnFirst].length;
    
    NSLog(@"month:%d, numDaysInMonth:%d", currentMonth, numDaysInMonth);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    didAddExtraRow = NO;
	
	int day = 1;
	for (int i = 0; i < 6; i++) {
		for(int j = 0; j < 7; j++) {
			int dayNumber = i * 7 + j;
			
			if(dayNumber >= (weekdayOfFirst-1) && day <= numDaysInMonth) {
                NSString *str = [NSString stringWithFormat:@"%d", day];
                
                CGContextSaveGState(context);
                CGContextSetShadowWithColor(context, shadow2Offset, shadow2BlurRadius, shadow2);
                CGRect dayHeader2Frame = CGRectMake(j*hDiff, i*vDiff, 21, 14);
                [[UIColor whiteColor] setFill];
                [str drawInRect: dayHeader2Frame withFont: [UIFont fontWithName: @"Helvetica" size: 12] lineBreakMode: UILineBreakModeWordWrap alignment: UITextAlignmentCenter];
                CGContextRestoreGState(context);
                
                if(i == 5) {
                    didAddExtraRow = YES;
                    NSLog(@"didAddExtraRow");
                }
                
				++day;
			}
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
                    NSLog(@"didAddExtraRow");
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
