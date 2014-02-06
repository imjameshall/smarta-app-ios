//
//  StopTimes.m
//  sMARTA
//
//  Created by James Hall on 9/25/13.
//  Copyright (c) 2013 James Hall. All rights reserved.
//

#import "StopTimes.h"
#import "Stops.h"
#import "Trips.h"


@implementation StopTimes

@dynamic arrival_time;
@dynamic departure_time;
@dynamic stop_id;
@dynamic stop_sequence;
@dynamic trip_id;
@dynamic stop;
@dynamic trips;

@synthesize arrivalTime=_arrivalTime;


-(NSDate *)arrivalTime
{

    if (_arrivalTime == nil) {
        NSScanner* timeScanner=[NSScanner scannerWithString:self.arrival_time];
        int hour,minute;
        [timeScanner scanInt:&hour];
        [timeScanner scanString:@":" intoString:nil]; //jump over :
        [timeScanner scanInt:&minute];
//        [timeScanner scanString:@":" intoString:nil]; //jump over :
//        [timeScanner scanInt:&seconds];

        NSDate *now = [NSDate date];
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:now];
        [components setHour:hour];
        [components setMinute:minute];
//        [components setSecond:seconds];
        [calendar setTimeZone:[NSTimeZone localTimeZone]];
        _arrivalTime = [calendar dateFromComponents:components];
    }
    return _arrivalTime;
}

@end
