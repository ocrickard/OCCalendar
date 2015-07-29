//
//  OCSelectionView.h
//  OCCalendar
//
//  Created by Oliver Rickard on 3/30/12.
//  Copyright (c) 2012 UC Berkeley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OCTypes.h"
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

- (void)resetSelection;

-(CGPoint)startPoint;
-(CGPoint)endPoint;

-(void)setStartPoint:(CGPoint)sPoint;
-(void)setEndPoint:(CGPoint)ePoint;
@property(nonatomic, assign) OCSelectionMode selectionMode;
@property (nonatomic, assign) BOOL selected;

@end
