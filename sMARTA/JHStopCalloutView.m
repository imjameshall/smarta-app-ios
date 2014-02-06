//
//  JHStopCalloutView.m
//  sMARTA
//
//  Created by James Hall on 1/16/14.
//  Copyright (c) 2014 James Hall. All rights reserved.
//
#import "MPFoldTransition.h"
#import "JHStopCalloutView.h"

@implementation JHStopCalloutView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.lblStopName = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
        [self addSubview:self.lblStopName];
        self.svStopTimes = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 30, 320, 410)];
        [self addSubview:self.svStopTimes];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(0, 446, 320, 40)];
        [btn setTitle:@"View Map" forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor lightGrayColor]];
        [btn addTarget:self action:@selector(btnPress) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }
    return self;
}


-(void)btnPress
{
    dispatch_async(dispatch_get_main_queue(),^
    {
        [self.parent btnCloseStop];
    });
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
