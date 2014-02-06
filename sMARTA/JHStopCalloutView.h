//
//  JHStopCalloutView.h
//  sMARTA
//
//  Created by James Hall on 1/16/14.
//  Copyright (c) 2014 James Hall. All rights reserved.
//

#import "JHRouteDetailViewController.h"
#import <UIKit/UIKit.h>




@interface JHStopCalloutView : UIView

@property (strong, nonatomic) UILabel *lblStopName;
@property (strong, nonatomic) UIScrollView *svStopTimes;

@property (weak, nonatomic) JHRouteDetailViewController *parent;

@end
