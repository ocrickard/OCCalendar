//
//  OCViewController.m
//  OCCalendar
//
//  Created by Oliver Rickard on 3/30/12.
//  Copyright (c) 2012 UC Berkeley. All rights reserved.
//

#import "OCViewController.h"
#import "OCCalendarViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface OCViewController ()

@end

@implementation OCViewController


#pragma mark - 
#pragma mark View Lifecycle

- (void)loadView {
    [super loadView];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //This view just detects touches, and then creates a new calendar
    UIView *bgView = [[UIView alloc] initWithFrame:self.view.frame];
    bgView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *tapG = [[UITapGestureRecognizer alloc] init];
    tapG.delegate = self;
    [bgView addGestureRecognizer:[tapG autorelease]];
    [bgView setUserInteractionEnabled:YES];
    
    [self.view addSubview:[bgView autorelease]];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    //Here's where the magic happens
    calVC = [[OCCalendarViewController alloc] initAtPoint:CGPointMake(167, 50) inView:self.view arrowPosition:OCArrowPositionCentered];
    calVC.delegate = self;
	//Test ONLY
	calVC.selectionMode = OCSelectionSingleDate;
    //Now we're going to optionally set the start and end date of a pre-selected range.
    //This is totally optional.
	NSDateComponents *dateParts = [[NSDateComponents alloc] init];
	[dateParts setMonth:5];
	[dateParts setYear:2012];
	[dateParts setDay:8];
    
	NSDate *sDate = [calendar dateFromComponents:dateParts];
	[dateParts release];
    
    dateParts = [[NSDateComponents alloc] init];
	[dateParts setMonth:5];
	[dateParts setYear:2012];
	[dateParts setDay:14];
    
	NSDate *eDate = [calendar dateFromComponents:dateParts];
	[dateParts release];
    
    [calVC setStartDate:sDate];
    [calVC setEndDate:eDate];
    
    //Add to the view.
    [self.view addSubview:calVC.view];
}


#pragma mark - 
#pragma mark OCCalendarDelegate Methods

- (void)completedWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterShortStyle];
    
    NSLog(@"startDate:%@, endDate:%@", startDate, endDate);
    
    [self showToolTip:[NSString stringWithFormat:@"%@ - %@", [df stringFromDate:startDate], [df stringFromDate:endDate]]];
    
    [df release];
    
    [calVC.view removeFromSuperview];
    
    calVC.delegate = nil;
    [calVC release];
    calVC = nil;
}

-(void) completedWithNoSelection{
    [calVC.view removeFromSuperview];
    calVC.delegate = nil;
    [calVC release];
    calVC = nil;
}


#pragma mark - 
#pragma mark Prettifying Methods...


//Create our little toast notifications.....
- (void)showToolTip:(NSString *)str {
    if(toolTipLabel) {
        [toolTipLabel removeFromSuperview];
        toolTipLabel = nil;
    }
    
    toolTipLabel = [ [UILabel alloc ] initWithFrame:CGRectMake(self.view.frame.size.width-260.0, self.view.frame.size.height-35.0, 250.0, 25) ];
    toolTipLabel.textAlignment =  UITextAlignmentCenter;
    toolTipLabel.textColor = [UIColor whiteColor];
    toolTipLabel.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    toolTipLabel.layer.cornerRadius = 5.0f;
    toolTipLabel.font = [UIFont fontWithName:@"Arial" size:(16.0)];
    toolTipLabel.text = str;
    
    toolTipLabel.alpha = 0.0f;
    
    [self.view addSubview:[toolTipLabel autorelease]];
    
    [UIView beginAnimations:@"fadeInToolTip" context:nil];
    [UIView setAnimationDuration:0.1f];
    toolTipLabel.alpha = 1.0f;
    [UIView commitAnimations];
    
    [self performSelector:@selector(fadeOutToolTip) withObject:nil afterDelay:2.5f];
}

- (void)fadeOutToolTip {
    if(toolTipLabel) {
        [UIView beginAnimations:@"fadeOutToolTip" context:nil];
        [UIView setAnimationDuration:0.1f];
        toolTipLabel.alpha = 0.0f;
        [UIView commitAnimations];
        [toolTipLabel performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.1f];
        
        toolTipLabel = nil;
    }
}


#pragma mark - 
#pragma mark Gesture Recognizer

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint insertPoint = [touch locationInView:self.view];
    
    calVC = [[OCCalendarViewController alloc] initAtPoint:insertPoint inView:self.view arrowPosition:OCArrowPositionCentered selectionMode:OCSelectionSingleDate];
    calVC.delegate = self;
    [self.view addSubview:calVC.view];
    
    return YES;
}



#pragma mark - 
#pragma mark Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
