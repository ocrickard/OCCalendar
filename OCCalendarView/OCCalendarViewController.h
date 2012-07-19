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

@end

@interface OCCalendarViewController : UIViewController <UIGestureRecognizerDelegate> {
    id <OCCalendarDelegate> delegate;
    
    UILabel *toolTipLabel;
    OCCalendarView *calView;
    
    CGPoint insertPoint;
    OCArrowPosition arrowPos;
    OCArrowVerticalPosition arrowVerticalPos;
    OCSelectionMode selectionMode;
    
    UIView *parentView;
    UIView *bgView;    
    UITapGestureRecognizer *tapG;
    NSDate *startDate;
    NSDate *endDate;
}

@property (nonatomic, assign) id <OCCalendarDelegate> delegate;
@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, retain) NSDate *endDate;

- (id)initAtPoint:(CGPoint)point inView:(UIView *)v;
- (id)initAtPoint:(CGPoint)point inView:(UIView *)v arrowPosition:(OCArrowPosition)ap arrowVerticalPosition:(OCArrowVerticalPosition)avp;
- (id)initAtPoint:(CGPoint)point inView:(UIView *)v arrowPosition:(OCArrowPosition)ap arrowVerticalPosition:(OCArrowVerticalPosition)avp selectionMode:(OCSelectionMode)selMode;

- (void) remove;

@end
