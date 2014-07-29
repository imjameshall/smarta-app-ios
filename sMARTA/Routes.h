//
//  Routes.h
//  sMARTA
//
//  Created by James Hall on 9/25/13.
//  Copyright (c) 2013 James Hall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Trips;

@interface Routes : NSManagedObject

@property (nonatomic, retain) NSString * route_color;
@property (nonatomic, retain) NSString * route_desc;
@property (nonatomic, retain) NSNumber * route_id;
@property (nonatomic, retain) NSString * route_long_name;
@property (nonatomic, retain) NSString * route_short_name;
@property (nonatomic, retain) NSString * route_text_color;
@property (nonatomic, retain) NSNumber * route_type;
@property (nonatomic, retain) NSString * route_url;
@property (nonatomic, retain) NSSet *trip;
@property (nonatomic, readonly) double route_Number;
@end

@interface Routes (CoreDataGeneratedAccessors)

- (void)addTripObject:(Trips *)value;
- (void)removeTripObject:(Trips *)value;
- (void)addTrip:(NSSet *)values;
- (void)removeTrip:(NSSet *)values;

@end
