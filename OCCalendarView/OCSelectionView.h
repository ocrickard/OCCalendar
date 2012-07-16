//
//  OCSelectionView.h
//  OCCalendar
//
//  Created by Oliver Rickard on 3/30/12.
//  Copyright (c) 2012 UC Berkeley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OCCalendarDelegate.h"

@interface OCSelectionView : UIView {
    BOOL selected;
    int startCellX;
    int startCellY;
    int endCellX;
    int endCellY;
    
    float xOffset;
    float yOffset;
    
    float hDiff;
    float vDiff;

}

@property (nonatomic, assign) id<OCCalendarDelegate>    delegate;

- (void)resetSelection;

-(CGPoint)startPoint;
-(CGPoint)endPoint;

-(void)setStartPoint:(CGPoint)sPoint;
-(void)setEndPoint:(CGPoint)ePoint;

@end
