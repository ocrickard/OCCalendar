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
  
  UIView *parentView;
}

@property (nonatomic, assign) id <OCCalendarDelegate> delegate;

- (id)initAtPoint:(CGPoint)point inView:(UIView *)v;
- (id)initAtPoint:(CGPoint)point inView:(UIView *)v arrowPosition:(OCArrowPosition)ap;

@end
