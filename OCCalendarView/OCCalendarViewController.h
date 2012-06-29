//
//  OCCalendarViewController.h
//  OCCalendar
//
//  Created by Oliver Rickard on 3/31/12.
//  Copyright (c) 2012 UC Berkeley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OCCalendarView.h"

@class OCCalendarView;

@protocol OCCalendarDelegate <NSObject>

@optional
-(void)completedWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;

@end

@interface OCCalendarViewController : UIViewController <UIGestureRecognizerDelegate> {
    id <OCCalendarDelegate> delegate;
    
    UILabel *toolTipLabel;
    OCCalendarView *calView;
    
    CGPoint insertPoint;
    OCArrowPosition arrowPos;
    
    UIView *parentView;
    
    NSDate *startDate;
    NSDate *endDate;
    
    NSInteger calendarWidth;
    NSInteger calendarHeight;
}

@property (nonatomic, assign) id <OCCalendarDelegate> delegate;
@property (nonatomic, retain) NSDate    *startDate;
@property (nonatomic, retain) NSDate    *endDate;
@property (nonatomic, assign) NSInteger calendarWidth;
@property (nonatomic, assign) NSInteger calendarHeight;

- (id)initAtPoint:(CGPoint)point inView:(UIView *)v;
- (id)initAtPoint:(CGPoint)point inView:(UIView *)v arrowPosition:(OCArrowPosition)ap;


@end
