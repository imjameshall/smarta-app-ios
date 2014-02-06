//
//  JHStopAnnotationView.m
//  sMARTA
//
//  Created by James Hall on 2/1/14.
//  Copyright (c) 2014 James Hall. All rights reserved.
//

#import "JHStopAnnotationView.h"



@implementation JHStopAnnotationView



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setShowCustomCallout:(BOOL)showCustomCallout
{
    [self setShowCustomCallout:showCustomCallout animated:NO];
}

- (void)setShowCustomCallout:(BOOL)showCustomCallout animated:(BOOL)animated
{
    if (_showCustomCallout == showCustomCallout) return;
    
    _showCustomCallout = showCustomCallout;
    
    void (^animationBlock)(void) = nil;
    void (^completionBlock)(BOOL finished) = nil;
    
    if (_showCustomCallout) {
        self.calloutView.alpha = 0.0f;
        
        animationBlock = ^{
            self.calloutView.alpha = 1.0f;
            [self addSubview:self.calloutView];
        };
        
    } else {
        animationBlock = ^{ self.calloutView.alpha = 0.0f; };
        completionBlock = ^(BOOL finished) { [self.calloutView removeFromSuperview]; };
    }
    
    if (animated) {
        [UIView animateWithDuration:0.2f animations:animationBlock completion:completionBlock];
        
    } else {
        animationBlock();
        completionBlock(YES);
    }
}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (_showCustomCallout && CGRectContainsPoint(self.calloutView.frame, point)) {
        return self.calloutView;
        
    } else {
        return nil;
    }
}
@end
