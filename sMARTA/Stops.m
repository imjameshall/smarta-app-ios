//
//  Stops.m
//  sMARTA
//
//  Created by James Hall on 9/25/13.
//  Copyright (c) 2013 James Hall. All rights reserved.
//

#import "Stops.h"
#import "StopTimes.h"


@implementation Stops

@dynamic stop_code;
@dynamic stop_id;
@dynamic stop_lat;
@dynamic stop_lon;
@dynamic stop_name;
@dynamic stopTimes;


-(NSMutableArray *)orderedStopTimes
{

    NSSortDescriptor *dateDescriptor = [NSSortDescriptor
                                        sortDescriptorWithKey:@"arrivalTime"
                                        ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:dateDescriptor];
    NSArray *sortedEventArray = [[self.stopTimes allObjects] sortedArrayUsingDescriptors:sortDescriptors];
    
    return [sortedEventArray mutableCopy];
}
@end
