//
//  OCCalendarViewController.m
//  OCCalendar
//
//  Created by Oliver Rickard on 3/31/12.
//  Copyright (c) 2012 UC Berkeley. All rights reserved.
//

#import "OCCalendarViewController.h"
#import "OCConstant.h"
#import <QuartzCore/QuartzCore.h>

@interface OCCalendarViewController ()

@end

@implementation OCCalendarViewController
@synthesize delegate, startDate, endDate;
@synthesize calendarWidth, calendarHeight;

- (id)initAtPoint:(CGPoint)point inView:(UIView *)v arrowPosition:(OCArrowPosition)ap {
    self = [super initWithNibName:nil bundle:nil];
    if(self) {
        insertPoint = point;
        parentView = v;
        arrowPos = ap;

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            calendarWidth = DEFAULT_PHONE_WIDTH;
            calendarHeight = DEFAULT_PHONE_HEIGHT;
        } else {
            calendarWidth = DEFAULT_PAD_WIDTH;
            calendarHeight = DEFAULT_PAD_HEIGHT;
        }
    }
    return self;
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
    
    int width = calendarWidth;
    int height = calendarHeight;
    
    float arrowPosX = width / 2;
    
    if(arrowPos == OCArrowPositionLeft) {
        arrowPosX = 30;
    } else if(arrowPos == OCArrowPositionRight) {
        arrowPosX = width - 30;
    }
    
    calView = [[OCCalendarView alloc] initAtPoint:insertPoint withFrame:CGRectMake(insertPoint.x - arrowPosX, insertPoint.y, width, height) arrowPosition:arrowPos];
    if(self.startDate) {
        [calView setStartDate:startDate];
    }
    if(self.endDate) {
        [calView setEndDate:endDate];
    }
    calView.delegate = self.delegate;
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
    
    NSLog(@"startDate:%@ endDate:%@", startDate.description, endDate.description);
    
    [calView removeFromSuperview];
    calView = nil;
    
    if([startDate compare:endDate] == NSOrderedAscending)
        [self.delegate completedWithStartDate:startDate endDate:endDate];
    else
        [self.delegate completedWithStartDate:endDate endDate:startDate];
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
        int width = calendarWidth;
        int height = calendarHeight;
        
        calView = [[OCCalendarView alloc] initAtPoint:point withFrame:CGRectMake(point.x - width*0.5, point.y - 31.4, width, height)];
        calView.delegate = self.delegate;
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
