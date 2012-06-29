//
//  OCCalendarDelegate.h
//  OCCalendar
//
//  Created by Lin Robi on 12-6-30.
//  Copyright (c) 2012年 UC Berkeley. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OCCalendarDelegate <NSObject>

@optional

- (BOOL)shouldBeSingleSelection;
- (void)selectingWithStartDate:(NSData *)startDate endDate:(NSData *)endDate;
- (void)completedWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;

- (UIColor*)getCalendarBackgroundColor;
- (UIColor*)getCalendarTextColor;


@end

