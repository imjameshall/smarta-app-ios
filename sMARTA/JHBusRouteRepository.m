//
//  JHBusRouteRepository.m
//  sMARTA
//
//  Created by James Hall on 9/17/13.
//  Copyright (c) 2013 James Hall. All rights reserved.
//
#import "Routes.h"
#import "Shapes.h"
#import "Trips.h"
#import "Stops.h"
#import "StopTimes.h"

#import "CHCSVParser.h"
#import "JHBusRouteRepository.h"

@interface JHBusRouteRepository()

@property (nonatomic,strong) NSMutableArray *routes;
@property (nonatomic,strong) NSMutableArray *trips;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectContext *bgManagedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end

static JHBusRouteRepository *_provider;

@implementation JHBusRouteRepository

@synthesize managedObjectContext = _managedObjectContext;
@synthesize bgManagedObjectContext = _bgManagedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (JHBusRouteRepository *)routeProvider
{
    if (_provider == nil) {
        _provider = [[JHBusRouteRepository alloc]init];
    }
    
    return _provider;
}

//
-(void)loadData
{
    NSLog(@"Start");
//    [self loadStops];
//    [self loadShapes];
//    [self loadRoutes];
//    [self loadTrips];
//    [self loadStopTimes];
    NSLog(@"Stop");
}


-(NSInteger)getServiceID:(int)dayOfWeek
{
    switch (dayOfWeek) {
        case 1:
            return 4;
            break;
        case 7:
            return 3;
            break;
        default:
            return 5;
            break;
    }
}

//STOPS
-(void)loadStops
{

    NSString * file = @"/Users/jhall/Desktop/MARTA/google_transit/stops.txt";
    for (NSArray *item in [NSArray arrayWithContentsOfCSVFile:file]) {
        if ([item count] < 5) {
            continue;
        }
//        stop_id,stop_code,stop_name,stop_lat,stop_lon
        NSManagedObjectContext *context = [self managedObjectContext];
        
        Stops *stop = [NSEntityDescription insertNewObjectForEntityForName:@"Stops" inManagedObjectContext:context];
        [stop setStop_id:[NSNumber numberWithInt:[item[0] intValue]]];
        [stop setStop_code:[NSNumber numberWithInt:[item[1] intValue]]];
        [stop setStop_name:item[2]];
        [stop setStop_lat:item[3]];
        [stop setStop_lon:item[4]];

        
        // Save the context.
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    [self saveContext];;
    
}

//
-(Stops *)getStopByID:(NSInteger)stopID
{
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Stops" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"stop_id == %@", [NSString stringWithFormat:@"%d",stopID]];
    
    [request setPredicate:pred];
    
    NSError *error;
    NSArray *stops = [[moc executeFetchRequest:request error:&error] mutableCopy];
    
    if (stops.count == 0) {
        return nil;
    }
    
    return [stops firstObject];
}

//
-(void)loadStopTimes
{
    NSString * file = @"/Users/jhall/Desktop/MARTA/google_transit/stop_times.txt";
    for (NSArray *item in [NSArray arrayWithContentsOfCSVFile:file]) {
        if ([item count] < 5) {
            continue;
        }
        //trip_id,arrival_time,departure_time,stop_id,stop_sequence
        NSManagedObjectContext *context = [self managedObjectContext];
        
        StopTimes *stop = [NSEntityDescription insertNewObjectForEntityForName:@"StopTimes" inManagedObjectContext:context];
        [stop setTrip_id:[NSNumber numberWithInt:[item[0] intValue]]];
        [stop setArrival_time:item[1]];
        [stop setDeparture_time:item[2]];
        [stop setStop_id:[NSNumber numberWithInt:[item[3] intValue]]];
        [stop setStop_sequence:[NSNumber numberWithInt:[item[4] intValue]]];
        
        [stop setStop:[self getStopByID:[item[3] intValue]]];
        [stop setTrips:[self getTripByID:stop.trip_id.integerValue]];
        
        // Save the context.
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    [self saveContext];
}

//
-(void)loadShapes
{
    NSString * file = @"/Users/jhall/Desktop/MARTA/google_transit/shapes.txt";
    for (NSArray *item in [NSArray arrayWithContentsOfCSVFile:file]) {
        if ([item count] < 4) {
            continue;
        }
        //shape_id,shape_pt_lat,shape_pt_lon,shape_pt_sequence
        NSManagedObjectContext *context = [self managedObjectContext];
        
        Shapes *stop = [NSEntityDescription insertNewObjectForEntityForName:@"Shapes" inManagedObjectContext:context];
        [stop setShape_id:[NSNumber numberWithInt:[item[0] intValue]]];
        [stop setShape_lat:item[1]];
        [stop setShape_long:item[2]];
        [stop setShape_sequence:[NSNumber numberWithInt:[item[3] intValue]]];
        
        // Save the context.
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    [self saveContext];
}

-(NSArray *)getFullShapeByID:(NSInteger)shapeID
{
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Shapes" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"shape_id == %@", [NSString stringWithFormat:@"%d",shapeID]];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"shape_sequence"  ascending:YES];
    
    [request setSortDescriptors:@[sortDescriptor]];
    [request setPredicate:pred];
    
    NSError *error;
    NSArray *stops = [[moc executeFetchRequest:request error:&error] mutableCopy];
    
    if (stops.count == 0) {
        return nil;
    }
    
    return stops;
    
}

-(Shapes *)getShapeByID:(NSInteger)shapeID
{
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Shapes" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"shape_id == %@", [NSString stringWithFormat:@"%d",shapeID]];
    
    [request setPredicate:pred];
    
    NSError *error;
    NSArray *stops = [[moc executeFetchRequest:request error:&error] mutableCopy];
    
    if (stops.count == 0) {
        return nil;
    }
    
    return [stops firstObject];
}
-(Trips *)getTripByID:(NSInteger)tripID
{
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Trips" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"trip_id == %@", [NSString stringWithFormat:@"%d",tripID]];
    
    [request setPredicate:pred];
    
    NSError *error;
    NSArray *stops = [[moc executeFetchRequest:request error:&error] mutableCopy];
    
    if (stops.count == 0) {
        return nil;
    }
    
    return [stops firstObject];
}

-(void)loadTrips
{
    NSString * file = @"/Users/jhall/Desktop/MARTA/google_transit/trips.txt";
    for (NSArray *item in [NSArray arrayWithContentsOfCSVFile:file]) {
        if ([item count] < 7) {
            continue;
        }
        //route_id,service_id,trip_id,trip_headsign,direction_id,block_id,shape_id
        NSManagedObjectContext *context = [self managedObjectContext];
        
        Trips *stop = [NSEntityDescription insertNewObjectForEntityForName:@"Trips" inManagedObjectContext:context];
        [stop setRoute_id:[NSNumber numberWithInt:[item[0] intValue]]];
        [stop setService_id:[NSNumber numberWithInt:[item[1] intValue]]];
        [stop setTrip_id:[NSNumber numberWithInt:[item[2] intValue]]];
        [stop setTrip_headsign:item[3]];
        [stop setDirection_id:[NSNumber numberWithInt:[item[4] intValue]]];
        [stop setBlock_id:[NSNumber numberWithInt:[item[5] intValue]]];
        [stop setShape_id:[NSNumber numberWithInt:[item[6] intValue]]];
        
        [stop setShape:[self getShapeByID:[item[6] intValue]]];
        [stop setRoute:[self getRouteByID:stop.route_id.integerValue]];
        
        // Save the context.
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    [self saveContext];;
    
}
-(Routes *)getRouteByID:(NSInteger)routeID
{
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Routes" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"route_id == %@", [NSString stringWithFormat:@"%d",routeID]];
    
    [request setPredicate:pred];
    
    NSError *error;
    NSArray *stops = [[moc executeFetchRequest:request error:&error] mutableCopy];
    
    if (stops.count == 0) {
        return nil;
    }
    
    return [stops firstObject];
}
//
-(void)loadRoutes
{
    NSString * file = @"/Users/jhall/Desktop/MARTA/google_transit/routes.txt";
    for (NSArray *item in [NSArray arrayWithContentsOfCSVFile:file]) {
        if ([item count] < 8) {
            continue;
        }
        //route_id,route_short_name,route_long_name,route_desc,route_type,route_url,route_color,route_text_color
        
        NSManagedObjectContext *context = [self managedObjectContext];
        
        Routes *route = [NSEntityDescription insertNewObjectForEntityForName:@"Routes" inManagedObjectContext:context];
        [route setRoute_id:[NSNumber numberWithInt:[item[0] intValue]]];
        [route setRoute_short_name:item[1]];
        [route setRoute_long_name:item[2]];
        [route setRoute_desc:item[3]];
        [route setRoute_type:[NSNumber numberWithInt:[item[4] intValue]]];
        [route setRoute_url:item[5]];
        [route setRoute_color:item[6]];
        [route setRoute_text_color:item[7]];
        
        
        // Save the context.
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    [self saveContext];
}


//Retrieve Information
-(NSMutableArray *)busRoutes
{
    if (self.routes == nil) {

        NSManagedObjectContext *moc = [self managedObjectContext];
        NSEntityDescription *entityDescription = [NSEntityDescription
                                                  entityForName:@"Routes" inManagedObjectContext:moc];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
                
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"route_long_name"  ascending:YES];
        
        [request setSortDescriptors:@[sortDescriptor]];
        
        NSError *error;
        self.routes = [[moc executeFetchRequest:request error:&error] mutableCopy];
    }
    
    return self.routes;

}

-(NSMutableArray *)routeShape:(NSInteger)routeID
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
    int weekday = [comps weekday];
    NSInteger serviceID = [self getServiceID:weekday];
    
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Trips" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"route_id == %@ && service_id == %@",[NSString stringWithFormat:@"%d",routeID],
                         [NSString stringWithFormat:@"%d",serviceID]];
    
    [request setPredicate:pred];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"trip_id"  ascending:YES];
    
    [request setSortDescriptors:@[sortDescriptor]];
    
    NSError *error;
    NSArray *array = [[moc executeFetchRequest:request error:&error] mutableCopy];

    NSMutableArray *mutableArray = [NSMutableArray array];
    
    for (Trips *obj in array) {
        if (![mutableArray containsObject:obj.shape_id]) {
            [mutableArray addObject:obj.shape_id];
        }
    }
    return mutableArray;
    
}

-(NSMutableArray *)routeTrips:(NSInteger)routeID
{
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Trips" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];

    NSPredicate *pred = [NSPredicate predicateWithFormat:@"route_id == %@ && service_id == 5", [NSString stringWithFormat:@"%d",routeID]];

    [request setPredicate:pred];

    NSError *error;
    NSMutableArray *trips = [[moc executeFetchRequest:request error:&error] mutableCopy];
    
    return trips;
}

-(NSMutableArray *)getStopTimesForRouteInBackground:(NSNumber *)routeID
{
    
    NSManagedObjectContext *moc = [self bgManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Routes" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"route_id == %@", [NSString stringWithFormat:@"%d",[routeID integerValue]]];
    
    [request setPredicate:pred];
    
    NSError *error;
    NSArray *stops = [[moc executeFetchRequest:request error:&error] mutableCopy];
    
    if (stops.count == 0) {
        return nil;
    }
    
    Routes *route = [stops firstObject];
    
    pred = [NSPredicate predicateWithFormat:@"service_id == 5"];
    
    NSMutableArray *array = [NSMutableArray array];

    for (Trips *trip in [route.trip filteredSetUsingPredicate:pred]) {
        NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"stop_sequence" ascending:YES];
        for (StopTimes *stopTimes in [trip.stopTimes sortedArrayUsingDescriptors:[NSArray arrayWithObject:nameDescriptor]]) {
            [array addObject:stopTimes];
//            NSLog(@"    %@-%@",stopTimes.arrivalTime, stopTimes.stop.stop_name);
        }
    }
    
    NSSortDescriptor *dateDescriptor = [NSSortDescriptor
                                        sortDescriptorWithKey:@"arrivalTime"
                                        ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:dateDescriptor];
    NSArray *sortedEventArray = [array sortedArrayUsingDescriptors:sortDescriptors];
    
    return [sortedEventArray mutableCopy];
}


-(NSMutableArray *)tripStopTimes:(NSInteger)tripID
{
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"StopTimes" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"trip_id == %@", [NSString stringWithFormat:@"%d",tripID]];
    
    [request setPredicate:pred];
    
    NSError *error;
    NSMutableArray *trips = [[moc executeFetchRequest:request error:&error] mutableCopy];
    
    return trips;
  
}
// Assumes input like "#00FF00" (#RRGGBB).
- (UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

#pragma mark - Core Data stack

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)bgManagedObjectContext
{
    if (_bgManagedObjectContext != nil) {
        return _bgManagedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _bgManagedObjectContext = [[NSManagedObjectContext alloc] init];
        [_bgManagedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _bgManagedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"RouteInformation" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"RouteInformation.sqlite"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]]) {
        NSURL *preloadURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"RouteInformation" ofType:@"sqlite"]];
        NSError* err = nil;
        
        if (![[NSFileManager defaultManager] copyItemAtURL:preloadURL toURL:storeURL error:&err]) {
            NSLog(@"Oops, could copy preloaded data");
        }
    }
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}



@end
