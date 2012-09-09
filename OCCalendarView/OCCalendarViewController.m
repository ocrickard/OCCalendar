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
@synthesize delegate, startDate, endDate, selectionMode;

- (id)initAtPoint:(CGPoint)point inView:(UIView *)v arrowPosition:(OCArrowPosition)ap selectionMode:(OCSelectionMode)sm {
    self = [super initWithNibName:nil bundle:nil];
    if(self) {
        insertPoint = point;
        parentView = v;
        arrowPos = ap;
        selectionMode = sm;
    }
    return self;
}

- (id)initAtPoint:(CGPoint)point inView:(UIView *)v arrowPosition:(OCArrowPosition)ap {
    return [self initAtPoint:point inView:v arrowPosition:ap selectionMode:OCSelectionDateRange];
}

- (id)initAtPoint:(CGPoint)point inView:(UIView *)v {
    return [self initAtPoint:point inView:v arrowPosition:OCArrowPositionCentered];
}

- (void)loadView {
    [super loadView];
    self.view.frame = parentView.frame;
    
    
    //this view sits behind the calendar and receives touches.  It tells the calendar view to disappear when tapped.
    UIView *bgView = [[UIView alloc] initWithFrame:self.view.frame];
    bgView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *tapG = [[UITapGestureRecognizer alloc] init];
    tapG.delegate = self;
    [bgView addGestureRecognizer:[tapG autorelease]];
    [bgView setUserInteractionEnabled:YES];
    
    [self.view addSubview:[bgView autorelease]];
    
    int width = 390;
    int height = 300;
    
    float arrowPosX = 208;
    
    if(arrowPos == OCArrowPositionLeft) {
        arrowPosX = 67;
    } else if(arrowPos == OCArrowPositionRight) {
        arrowPosX = 346;
    }
    
    calView = [[OCCalendarView alloc] initAtPoint:insertPoint withFrame:CGRectMake(insertPoint.x - arrowPosX, insertPoint.y - 31.4, width, height) arrowPosition:arrowPos];
    [calView setSelectionMode:selectionMode];
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

- (void)setStartDate:(NSDate *)sDate {
    if(startDate) {
        [startDate release];
        startDate = nil;
    }
    startDate = [sDate retain];
    [calView setStartDate:startDate];
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
    
    //NSLog(@"CalView Selected:%d", [calView selected]);
    
    if([calView selected]) {
        if([startDate compare:endDate] == NSOrderedAscending)
            [self.delegate completedWithStartDate:startDate endDate:endDate];
        else
            [self.delegate completedWithStartDate:endDate endDate:startDate];
    } else {
        [self.delegate completedWithNoSelection];
    }
    
    [calView removeFromSuperview];
    calView = nil;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if(calView) {
        //Animate out the calendar view if it already exists
        [UIView beginAnimations:@"animateOutCalendar" context:nil];
        [UIView setAnimationDuration:0.4f];
        calView.transform = CGAffineTransformMakeScale(0.1, 0.1);
        calView.alpha = 0.0f;
        [UIView commitAnimations];
        
        [self performSelector:@selector(removeCalView) withObject:nil afterDelay:0.4f];
    } else {
        //Recreate the calendar if it doesn't exist.
        
        //CGPoint insertPoint = CGPointMake(200+130*0.5, 200+10);
        CGPoint point = [touch locationInView:self.view];
        int width = 390;
        int height = 300;
        
        calView = [[OCCalendarView alloc] initAtPoint:point withFrame:CGRectMake(point.x - width*0.5, point.y - 31.4, width, height)];
        [self.view addSubview:[calView autorelease]];
    }
    
    return YES;
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
