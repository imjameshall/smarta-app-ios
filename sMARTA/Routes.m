//
//  Routes.m
//  sMARTA
//
//  Created by James Hall on 9/25/13.
//  Copyright (c) 2013 James Hall. All rights reserved.
//

#import "Routes.h"
#import "Trips.h"


@implementation Routes

@dynamic route_color;
@dynamic route_desc;
@dynamic route_id;
@dynamic route_long_name;
@dynamic route_short_name;
@dynamic route_text_color;
@dynamic route_type;
@dynamic route_url;
@dynamic trip;

@synthesize route_Number=_route_Number;


-(double)route_Number
{
    return [self.route_short_name doubleValue];
}

@end
