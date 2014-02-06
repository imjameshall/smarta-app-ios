//
//  StopTimes.h
//  sMARTA
//
//  Created by James Hall on 9/25/13.
//  Copyright (c) 2013 James Hall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Stops, Trips;

@interface StopTimes : NSManagedObject

@property (nonatomic, retain) NSString * arrival_time;
@property (nonatomic, retain) NSString * departure_time;
@property (nonatomic, retain) NSNumber * stop_id;
@property (nonatomic, retain) NSNumber * stop_sequence;
@property (nonatomic, retain) NSNumber * trip_id;
@property (nonatomic, retain) Stops *stop;
@property (nonatomic, retain) Trips *trips;
@property (nonatomic, retain) NSDate *arrivalTime;

@end
