//
//  Stops.h
//  sMARTA
//
//  Created by James Hall on 9/25/13.
//  Copyright (c) 2013 James Hall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class StopTimes;

@interface Stops : NSManagedObject

@property (nonatomic, retain) NSNumber * stop_code;
@property (nonatomic, retain) NSNumber * stop_id;
@property (nonatomic, retain) NSString * stop_lat;
@property (nonatomic, retain) NSString * stop_lon;
@property (nonatomic, retain) NSString * stop_name;
@property (nonatomic, retain) NSSet *stopTimes;
@end

@interface Stops (CoreDataGeneratedAccessors)

- (void)addStopTimesObject:(StopTimes *)value;
- (void)removeStopTimesObject:(StopTimes *)value;
- (void)addStopTimes:(NSSet *)values;
- (void)removeStopTimes:(NSSet *)values;

-(NSMutableArray *)orderedStopTimes;

@end
