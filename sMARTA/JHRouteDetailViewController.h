//
//  JHRouteDetailViewController.h
//  sMARTA
//
//  Created by James Hall on 9/18/13.
//  Copyright (c) 2013 James Hall. All rights reserved.
//
#import "Shapes.h"
#import "Trips.h"
#import "Routes.h"
#import "Stops.h"
#import "StopTimes.h"
#import "JHStopPointAnnotation.h"
#import "JHStopTimeCalloutView.h"
#import "JHStopAnnotationView.h"
#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>

@interface JHRouteDetailViewController : UIViewController<MKMapViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UIScrollViewDelegate>

@property (nonatomic,strong) Routes *routeInfo;

- (IBAction)btnCloseAllStopsPress:(id)sender;

- (IBAction)btnViewAllStopsPress:(id)sender;

- (void)btnCloseStop;
-(void)viewStopTimes;
@end
