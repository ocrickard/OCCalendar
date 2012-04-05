//
//  OCViewController.h
//  OCCalendar
//
//  Created by Oliver Rickard on 3/30/12.
//  Copyright (c) 2012 UC Berkeley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OCCalendarViewController.h"

@interface OCViewController : UIViewController <UIGestureRecognizerDelegate, OCCalendarDelegate> {
    OCCalendarViewController *calVC;
    
    UILabel *toolTipLabel;
}

@end
