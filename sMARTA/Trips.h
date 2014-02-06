//
//  Trips.h
//  sMARTA
//
//  Created by James Hall on 9/25/13.
//  Copyright (c) 2013 James Hall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Routes, Shapes, StopTimes;

@interface Trips : NSManagedObject

@property (nonatomic, retain) NSNumber * block_id;
@property (nonatomic, retain) NSNumber * direction_id;
@property (nonatomic, retain) NSNumber * route_id;
@property (nonatomic, retain) NSNumber * service_id;
@property (nonatomic, retain) NSNumber * shape_id;
@property (nonatomic, retain) NSString * trip_headsign;
@property (nonatomic, retain) NSNumber * trip_id;
@property (nonatomic, retain) Routes *route;
@property (nonatomic, retain) Shapes *shape;
@property (nonatomic, retain) NSSet *stopTimes;
@end

@interface Trips (CoreDataGeneratedAccessors)

- (void)addStopTimesObject:(StopTimes *)value;
- (void)removeStopTimesObject:(StopTimes *)value;
- (void)addStopTimes:(NSSet *)values;
- (void)removeStopTimes:(NSSet *)values;

@end
