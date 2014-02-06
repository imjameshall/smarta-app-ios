//
//  JHBusRouteRepository.h
//  sMARTA
//
//  Created by James Hall on 9/17/13.
//  Copyright (c) 2013 James Hall. All rights reserved.
//
#import "Stops.h"
#import <Foundation/Foundation.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface JHBusRouteRepository : NSObject


+ (JHBusRouteRepository *)routeProvider;

-(void)loadData;

-(NSMutableArray *)busRoutes;
-(NSMutableArray *)routeTrips:(NSInteger)routeID;
-(NSMutableArray *)routeShape:(NSInteger)routeID;

-(NSMutableArray *)tripStopTimes:(NSInteger)tripID;

-(NSMutableArray *)getStopTimesForRouteInBackground:(NSNumber *)routeID;


-(Stops *)getStopByID:(NSInteger)stopID;


-(NSArray *)getFullShapeByID:(NSInteger)shapeID;

//Utilities
- (UIColor *)colorFromHexString:(NSString *)hexString;
@end
