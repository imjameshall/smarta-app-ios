//
//  JHHeaderView.m
//  sMARTA
//
//  Created by James Hall on 3/4/14.
//  Copyright (c) 2014 James Hall. All rights reserved.
//

#import "JHHeaderView.h"

@interface JHHeaderView()

@property (strong, nonatomic) UILabel *routeDescLabel;


@end

@implementation JHHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}
- (void)layoutSubviews
{
    if (self.routeDescLabel == nil) {
        self.routeDescLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 6, 320, 50)];
        [self.routeDescLabel setFont:[UIFont fontWithName:@"GillSans-Bold" size:24.0f]];
        [self addSubview:self.routeDescLabel];
    }
    self.routeDescLabel.text = self.headerText;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
+ (NSString *)kind
{
    return (NSString *)@"JHHeaderView";
}

@end
