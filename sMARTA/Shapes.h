//
//  Shapes.h
//  sMARTA
//
//  Created by James Hall on 9/25/13.
//  Copyright (c) 2013 James Hall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Trips;

@interface Shapes : NSManagedObject

@property (nonatomic, retain) NSNumber * shape_id;
@property (nonatomic, retain) NSString * shape_lat;
@property (nonatomic, retain) NSString * shape_long;
@property (nonatomic, retain) NSNumber * shape_sequence;
@property (nonatomic, retain) Trips *trip;

@end
