//
//  OCCalendarViewController.m
//  OCCalendar
//
//  Created by Oliver Rickard on 3/31/12.
//  Copyright (c) 2012 UC Berkeley. All rights reserved.
//

#import "OCCalendarViewController.h"
#import "OCCalendarView.h"
#import <QuartzCore/QuartzCore.h>

@interface OCCalendarViewController ()

@end

@implementation OCCalendarViewController
@synthesize delegate;

- (id)initAtPoint:(CGPoint)point inView:(UIView *)v {
    self = [super initWithNibName:nil bundle:nil];
    if(self) {
        insertPoint = point;
        parentView = v;
    }
    return self;
}

- (void)loadView {
    [super loadView];
    self.view.frame = parentView.frame;
    [parentView addSubview:self.view];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
    //this view sits behind the calendar and receives touches.  It tells the calendar view to disappear when tapped.
    UIView *bgView = [[UIView alloc] initWithFrame:self.view.frame];
    bgView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *tapG = [[UITapGestureRecognizer alloc] init];
    tapG.delegate = self;
    [bgView addGestureRecognizer:[tapG autorelease]];
    [bgView setUserInteractionEnabled:YES];
    
    [self.view addSubview:[bgView autorelease]];
    
    //insertPoint = CGPointMake(200+130*0.5, 200+10);
    int width = 390;
    int height = 300;
    
    calView = [[OCCalendarView alloc] initAtPoint:insertPoint withFrame:CGRectMake(insertPoint.x - width*0.5, insertPoint.y - 31.4, width, height)];
    [self.view addSubview:[calView autorelease]];
}

- (void)removeCalView {
    NSDate *startDate = [calView getStartDate];
    NSDate *endDate = [calView getEndDate];
    
    [calView removeFromSuperview];
    calView = nil;
    
    [self.delegate completedWithStartDate:startDate endDate:endDate];
    [self.view removeFromSuperview];
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
        CGPoint insertPoint = [touch locationInView:self.view];
        int width = 390;
        int height = 300;
        
        calView = [[OCCalendarView alloc] initAtPoint:insertPoint withFrame:CGRectMake(insertPoint.x - width*0.5, insertPoint.y - 31.4, width, height)];
        [self.view addSubview:[calView autorelease]];
    }
    
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
