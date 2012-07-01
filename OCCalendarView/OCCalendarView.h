//
//  OCCalendarView.h
//  OCCalendar
//
//  Created by Oliver Rickard on 3/30/12.
//  Copyright (c) 2012 UC Berkeley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OCCalendarDelegate.h"

typedef enum {
    OCArrowPositionLeft = -1,
    OCArrowPositionCentered = 0,
    OCArrowPositionRight = 1,
    OCArrowPositionNone = NSIntegerMax
} OCArrowPosition;

@class OCSelectionView;
@class OCDaysView;

@interface OCCalendarView : UIView {
    NSCalendar *calendar;
    
    int currentMonth;
    int currentYear;
    
    BOOL selected;
    int startCellX;
    int startCellY;
    int endCellX;
    int endCellY;
    
    float hDiff;
    float vDiff;
    
    OCSelectionView *selectionView;
    OCDaysView *daysView;
    
    int arrowPosition;
}

@property (nonatomic, assign, setter = setCalendarDelegate:) id<OCCalendarDelegate>    delegate;

- (id)initAtPoint:(CGPoint)p withFrame:(CGRect)frame;
- (id)initAtPoint:(CGPoint)p withFrame:(CGRect)frame arrowPosition:(OCArrowPosition)arrowPos;

//Valid Positions: OCArrowPositionLeft, OCArrowPositionCentered, OCArrowPositionRight
- (void)setArrowPosition:(OCArrowPosition)pos;

- (NSDate *)getStartDate;
- (NSDate *)getEndDate;

- (void)setStartDate:(NSDate *)sDate;
- (void)setEndDate:(NSDate *)eDate;

- (void)setCalendarDelegate:(id<OCCalendarDelegate>)d;

@end
