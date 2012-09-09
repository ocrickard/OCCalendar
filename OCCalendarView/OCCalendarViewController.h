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

-(void)completedWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;

-(void)completedWithNoSelection;

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
    
    OCSelectionMode selectionMode;
}

@property (nonatomic, assign) id <OCCalendarDelegate> delegate;
@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, retain) NSDate *endDate;
@property (nonatomic, assign) OCSelectionMode selectionMode;

- (id)initAtPoint:(CGPoint)point inView:(UIView *)v;
- (id)initAtPoint:(CGPoint)point inView:(UIView *)v arrowPosition:(OCArrowPosition)ap;
- (id)initAtPoint:(CGPoint)point inView:(UIView *)v arrowPosition:(OCArrowPosition)ap selectionMode:(OCSelectionMode)sm;


@end
