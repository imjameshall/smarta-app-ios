//
//  JHStopAnnotationView.h
//  sMARTA
//
//  Created by James Hall on 2/1/14.
//  Copyright (c) 2014 James Hall. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "JHStopTimeCalloutView.h"

@interface JHStopAnnotationView : MKAnnotationView
{
    BOOL _showCustomCallout;
}

@property (nonatomic,strong) JHStopTimeCalloutView *calloutView;



@end
