//
//  JHStopTimeCalloutView.h
//  sMARTA
//
//  Created by James Hall on 2/1/14.
//  Copyright (c) 2014 James Hall. All rights reserved.
//

#import <UIKit/UIKit.h>


@class JHRouteDetailViewController;

@interface JHStopTimeCalloutView : UIView

@property (strong, nonatomic) IBOutlet UILabel *stopLabel;
@property (strong, nonatomic) IBOutlet UIButton *viewStopsBtn;
@property (weak, nonatomic) JHRouteDetailViewController *parent;

-(IBAction)viewStopsBtnPress:(id)sender;

@end
