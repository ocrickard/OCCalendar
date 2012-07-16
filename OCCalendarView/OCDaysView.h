//
//  OCDaysView.h
//  OCCalendar
//
//  Created by Oliver Rickard on 3/30/12.
//  Copyright (c) 2012 UC Berkeley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OCCalendarDelegate.h"

@interface OCDaysView : UIView {
    int startCellX;
    int startCellY;
    int endCellX;
    int endCellY;
    
    float xOffset;
    float yOffset;
    
    float hDiff;
    float vDiff;
    
    float cellWidth;
    float cellHeight;
    
    int currentMonth;
    int currentYear;
    
    BOOL didAddExtraRow;
}

@property (nonatomic, assign) id<OCCalendarDelegate>    delegate;

- (void)setMonth:(int)month;
- (void)setYear:(int)year;

- (void)resetRows;

- (BOOL)addExtraRow;

@end
