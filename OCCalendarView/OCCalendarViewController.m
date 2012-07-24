//
//  OCCalendarViewController.m
//  OCCalendar
//
//  Created by Oliver Rickard on 3/31/12.
//  Copyright (c) 2012 UC Berkeley. All rights reserved.
//

#import "OCCalendarViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface OCCalendarViewController ()

@end

@implementation OCCalendarViewController

@synthesize delegate, startDate, endDate, autoSelectDate, selectionColor, todayMarkerColor;

- (id)initAtPoint:(CGPoint)point inView:(UIView *)v arrowPosition:(OCArrowPosition)ap arrowVerticalPosition:(OCArrowVerticalPosition)avp selectionMode:(OCSelectionMode)selMode
{
  self = [super initWithNibName:nil bundle:nil];
  if(self) {
      insertPoint = point;
      parentView = v;
      arrowPos = ap;
      arrowVerticalPos = avp;
      selectionMode = selMode;
      self.selectionColor = [UIColor colorWithRed: 0.82 green: 0.08 blue: 0 alpha: 0.86];
      self.todayMarkerColor = [UIColor colorWithRed: 0.98 green: 0.24 blue: 0.09 alpha: 1];
  }
  return self;
}

- (id)initAtPoint:(CGPoint)point inView:(UIView *)v {
  return [self initAtPoint:point inView:v arrowPosition:OCArrowPositionCentered arrowVerticalPosition:OCArrowVerticalPositionTop selectionMode:OCSelectionDateRange];
}


- (id)initAtPoint:(CGPoint)point inView:(UIView *)v arrowPosition:(OCArrowPosition)ap
{
    return [self initAtPoint:point inView:v arrowPosition:ap arrowVerticalPosition:OCArrowVerticalPositionTop selectionMode:OCSelectionDateRange];
}

- (id)initAtPoint:(CGPoint)point inView:(UIView *)v arrowPosition:(OCArrowPosition)ap arrowVerticalPosition:(OCArrowVerticalPosition)avp {
    return [self initAtPoint:point inView:v arrowPosition:ap arrowVerticalPosition:avp selectionMode:OCSelectionDateRange];
}

- (void)loadView {
    [super loadView];
    self.view.frame = parentView.frame;
    
    
    //this view sits behind the calendar and receives touches.  It tells the calendar view to disappear when tapped.
    bgView = [[UIView alloc] initWithFrame:self.view.frame];
    bgView.backgroundColor = [UIColor clearColor];
    tapG = [[UITapGestureRecognizer alloc] init];
    tapG.delegate = self;
    [bgView addGestureRecognizer:[tapG autorelease]];
    [bgView setUserInteractionEnabled:YES];
    
    [self.view addSubview:[bgView autorelease]];
    
    int width = 390;
    int height = 300;
    
    float arrowPosX = 208;
    float arrowPosY = 31.4;
    
    if(arrowPos == OCArrowPositionLeft) {
        arrowPosX = 67;
    } else if(arrowPos == OCArrowPositionRight) {
        arrowPosX = 346;
    }
    
    if (arrowVerticalPos == OCArrowVerticalPositionBottom)
    {
        arrowPosY = 268.9;
    }
    
    calView = [[OCCalendarView alloc] initAtPoint:insertPoint withFrame:CGRectMake(insertPoint.x - arrowPosX, insertPoint.y - arrowPosY, width, height) arrowPosition:arrowPos arrowVerticalPosition:arrowVerticalPos selectionMode:selectionMode];
    calView.delegate = self;
    [calView setSelectionColor:selectionColor];
    [calView setTodayMarkerColor:todayMarkerColor];
    
    if(self.startDate) {
        [calView setStartDate:startDate];
    }
    if(self.endDate) {
        [calView setEndDate:endDate];
    }
    [self.view addSubview:[calView autorelease]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)setSelectionColor:(UIColor *)selColor
{
    if(selectionColor) {
        [selectionColor release];
        selectionColor = nil;
    }
    selectionColor = [selColor retain];
    [calView setSelectionColor:selectionColor];
}

- (void) setTodayMarkerColor:(UIColor *)todayColor
{
    if(todayMarkerColor) {
        [todayMarkerColor release];
        todayMarkerColor = nil;
    }
    todayMarkerColor = [todayColor retain];
    [calView setTodayMarkerColor:todayMarkerColor];
}


- (void)setStartDate:(NSDate *)sDate {
    if(startDate) {
        [startDate release];
        startDate = nil;
    }
    startDate = [sDate retain];
    [calView setStartDate:startDate];
    if (selectionMode == OCSelectionSingleDate)
    {
        [self setEndDate:startDate];
    }
}

- (void)setEndDate:(NSDate *)eDate {
    if(endDate) {
        [endDate release];
        endDate = nil;
    }
    endDate = [eDate retain];
    [calView setEndDate:endDate];
}

- (void)removeCalView {
    startDate = [[calView getStartDate] retain];
    endDate = [[calView getEndDate] retain];
    
    //NSLog(@"startDate:%@ endDate:%@", startDate.description, endDate.description);
    
    if (calView != nil)
    {
        [calView removeFromSuperview];
        calView = nil;
        
        if([startDate compare:endDate] == NSOrderedAscending)
            [self.delegate completedWithStartDate:startDate endDate:endDate];
        else
            [self.delegate completedWithStartDate:endDate endDate:startDate];
    }
}

- (void) removeCalViewWithAnimation
{
    [UIView beginAnimations:@"animateOutCalendar" context:nil];
    [UIView setAnimationDuration:0.4f];
    calView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    calView.alpha = 0.0f;
    [UIView commitAnimations];
    
    [self performSelector:@selector(removeCalView) withObject:nil afterDelay:0.4f];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if(calView) {
        //Animate out the calendar view if it already exists
        [self removeCalViewWithAnimation];
    } else {
        //Recreate the calendar if it doesn't exist.
        
        //CGPoint insertPoint = CGPointMake(200+130*0.5, 200+10);
        CGPoint point = [touch locationInView:self.view];
        int width = 390;
        int height = 300;
        
        float arrowPosY = 31.4;
        if (arrowVerticalPos == OCArrowVerticalPositionBottom)
        {
            arrowPosY = 268.9;
        }
        
        calView = [[OCCalendarView alloc] initAtPoint:point withFrame:CGRectMake(point.x - width*0.5, point.y - arrowPosY, width, height) arrowPosition:arrowPos arrowVerticalPosition:arrowVerticalPos selectionMode:selectionMode];
        calView.delegate = self;
        
        [self.view addSubview:[calView autorelease]];
    }
    
    return YES;
}

- (void) remove
{
    self.delegate = nil;
    calView.delegate = nil;
    [bgView removeGestureRecognizer:tapG];
    [self.view removeFromSuperview];
}


- (void) endDateSelected
{
    if (self.autoSelectDate)
    {
        [self performSelector:@selector(removeCalViewWithAnimation) withObject:nil afterDelay:0.1];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)dealloc {
    self.startDate = nil;
    self.endDate = nil;
    [super dealloc];
}

@end
