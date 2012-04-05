//
//  OCCalendarView.h
//  OCCalendar
//
//  Created by Oliver Rickard on 3/30/12.
//  Copyright (c) 2012 UC Berkeley. All rights reserved.
//

#import <UIKit/UIKit.h>

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

- (id)initAtPoint:(CGPoint)p withFrame:(CGRect)frame;
- (id)initAtPoint:(CGPoint)p withFrame:(CGRect)frame arrowPosition:(int)arrowPosition;

//-1 means it's in the upper-left, 0 means it's in the middle, and 1 means it's in the upper-right.
- (void)setArrowPosition:(int)pos;

- (NSDate *)getStartDate;
- (NSDate *)getEndDate;

@end
