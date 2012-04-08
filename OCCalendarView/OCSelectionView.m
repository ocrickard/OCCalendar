//
//  OCSelectionView.m
//  OCCalendar
//
//  Created by Oliver Rickard on 3/30/12.
//  Copyright (c) 2012 UC Berkeley. All rights reserved.
//

#import "OCSelectionView.h"

@implementation OCSelectionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        
        selected = NO;
        startCellX = -1;
        startCellY = -1;
        endCellX = -1;
        endCellY = -1;
        
        hDiff = 43;
        vDiff = 30;
        
        self.userInteractionEnabled = YES;
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    if(selected) {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGColorRef backgroundShadow = [UIColor blackColor].CGColor;
        CGSize backgroundShadowOffset = CGSizeMake(2, 3);
        CGFloat backgroundShadowBlurRadius = 5;
        
        UIColor* darkColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.72];
        
        UIColor* color = [UIColor colorWithRed: 0.82 green: 0.08 blue: 0 alpha: 0.86];
        UIColor* color2 = [UIColor colorWithRed: 0.66 green: 0.02 blue: 0.04 alpha: 0.88];
        NSArray* gradient3Colors = [NSArray arrayWithObjects: 
                                    (id)color.CGColor, 
                                    (id)color2.CGColor, nil];
        CGFloat gradient3Locations[] = {0, 1};
        CGGradientRef gradient3 = CGGradientCreateWithColors(colorSpace, (CFArrayRef)gradient3Colors, gradient3Locations);
        
        int tempStart = MIN(startCellY, endCellY);
        int tempEnd = MAX(startCellY, endCellY);
        for(int i = tempStart; i <= tempEnd; i++) {
            //// selectedRect Drawing
            int thisRowEndCell;
            int thisRowStartCell;
            if(startCellY == i) {
                thisRowStartCell = startCellX;
                if (startCellY > endCellY) {
                    thisRowStartCell = 0; thisRowEndCell = startCellX;
                }
            } else {
                thisRowStartCell = 0;
            }
            
            if(endCellY == i) {
                thisRowEndCell = endCellX;
                if (startCellY > endCellY) {
                    thisRowStartCell = endCellX; thisRowEndCell = 6;
                }
            } else if (!(startCellY > endCellY)) {
                thisRowEndCell = 6;
            }
            
            //// selectedRect Drawing
            UIBezierPath* selectedRectPath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(MIN(thisRowStartCell, thisRowEndCell)*hDiff, i*vDiff, (ABS(thisRowEndCell-thisRowStartCell))*hDiff+20, 21) cornerRadius: 10];
            CGContextSaveGState(context);
            [selectedRectPath addClip];
            CGContextDrawLinearGradient(context, gradient3, CGPointMake((MIN(thisRowStartCell, thisRowEndCell)+.5)*hDiff, (i+1)*vDiff), CGPointMake((MIN(thisRowStartCell, thisRowEndCell)+.5)*hDiff, i*vDiff), 0);
            CGContextRestoreGState(context);
            
            CGContextSaveGState(context);
            CGContextSetShadowWithColor(context, backgroundShadowOffset, backgroundShadowBlurRadius, backgroundShadow);
            [darkColor setStroke];
            selectedRectPath.lineWidth = 0.5;
            [selectedRectPath stroke];
            CGContextRestoreGState(context);
        }
        
        CGGradientRelease(gradient3);
        CGColorSpaceRelease(colorSpace);
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    selected = YES;
    
    UITouch *touch = [touches anyObject];
    
    CGPoint point = [touch locationInView:self];
    
    startCellX = MIN((int)(point.x)/hDiff,6);
    startCellY = (int)(point.y)/vDiff;
    
    endCellX = MIN(startCellX,6);
    endCellY = startCellY;
    
    [self setNeedsDisplay];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    CGPoint point = [touch locationInView:self];
    
    if(CGRectContainsPoint(self.bounds, point)) {
        endCellX = MIN((int)(point.x)/hDiff,6);
        endCellY = (int)(point.y)/vDiff;
        
        [self setNeedsDisplay];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    CGPoint point = [touch locationInView:self];
    
    if(CGRectContainsPoint(self.bounds, point)) {
        endCellX = MIN((int)(point.x)/hDiff,6);
        endCellY = (int)(point.y)/vDiff;
        
        [self setNeedsDisplay];
    }
}

-(void)resetSelection {
    startCellX = -1;
    startCellY = -1;
    endCellY = -1;
    endCellX = -1;
    selected = NO;
    [self setNeedsDisplay];
}

-(CGPoint)startPoint {
    return CGPointMake(startCellX, startCellY);
}

-(CGPoint)endPoint {
    return CGPointMake(endCellX, endCellY);
}

@end
