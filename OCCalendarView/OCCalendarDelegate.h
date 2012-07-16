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

// impl this method for single selection, otherwise multiple date selection will be default choise
- (BOOL)shouldBeSingleSelection;
// just selected the date(which will be triggered after touch end on OCSelectionView)
- (void)selectingWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;
- (void)completedWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;

- (UIColor*)getCalendarBackgroundColor;
- (UIColor*)getDateSelectionColor;
- (UIColor*)getTodayColor;

@end

