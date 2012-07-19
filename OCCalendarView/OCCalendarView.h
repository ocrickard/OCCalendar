//
//  OCCalendarView.h
//  OCCalendar
//
//  Created by Oliver Rickard on 3/30/12.
//  Copyright (c) 2012 UC Berkeley. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    OCArrowPositionLeft = -1,
    OCArrowPositionCentered = 0,
    OCArrowPositionRight = 1
} OCArrowPosition;

typedef enum {
    OCArrowVerticalPositionTop = 0,
    OCArrowVerticalPositionBottom = 1
} OCArrowVerticalPosition;

typedef enum {
    OCSelectionSingleDate = 0,
    OCSelectionDateRange = 1
} OCSelectionMode;


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
    int arrowVerticalPosition;
    int selectionMode;
}

- (id)initAtPoint:(CGPoint)p withFrame:(CGRect)frame;
- (id)initAtPoint:(CGPoint)p withFrame:(CGRect)frame arrowPosition:(OCArrowPosition)arrowPos;
- (id)initAtPoint:(CGPoint)p withFrame:(CGRect)frame arrowPosition:(OCArrowPosition)arrowPos arrowVerticalPosition:(OCArrowVerticalPosition)arrowVerticalPos;
- (id)initAtPoint:(CGPoint)p withFrame:(CGRect)frame arrowPosition:(OCArrowPosition)arrowPos arrowVerticalPosition:(OCArrowVerticalPosition)arrowVerticalPos selectionMode:(OCSelectionMode)selMode;

//Valid Positions: OCArrowPositionLeft, OCArrowPositionCentered, OCArrowPositionRight
- (void)setArrowPosition:(OCArrowPosition)pos;
//Valid Positions: OCArrowVerticalPositionTop, OCArrowVerticalPositionBottom
- (void)setArrowVerticalPosition:(OCArrowVerticalPosition)pos;

- (NSDate *)getStartDate;
- (NSDate *)getEndDate;

- (void)setStartDate:(NSDate *)sDate;
- (void)setEndDate:(NSDate *)eDate;

@end
