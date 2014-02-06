//
//  JHRouteDetailViewController.m
//  sMARTA
//
//  Created by James Hall on 9/18/13.
//  Copyright (c) 2013 James Hall. All rights reserved.
//

#import "JHBusRouteRepository.h"
#import "JHRouteDetailViewController.h"
#import "JHBusCalloutView.h"
#import "JHStopCalloutView.h"
#import "MMStopDetailLayout.h"
#import "MPFoldTransition.h"
#define METERS_PER_MILE 1609.344


@interface JHRouteDetailViewController ()
@property (strong, nonatomic) IBOutlet UIButton *btnSouth;
@property (strong, nonatomic) IBOutlet UIButton *btnNorth;

@property (nonatomic,strong) NSMutableArray *routeTrips;
@property (nonatomic,strong) IBOutlet MKMapView *mapView;
@property (nonatomic,strong) NSMutableArray *polylines;
@property (strong, nonatomic) IBOutlet UIView *detailsView;
@property (strong, nonatomic) IBOutlet UIView *routeTimesView;

@property (strong,nonatomic) NSMutableArray *northStops;
@property (strong,nonatomic) NSMutableArray *southStops;

@property (strong,nonatomic) NSMutableArray *buses;
@property (strong, nonatomic) UIScrollView *svBuses;

@property (strong, nonatomic) NSMutableArray *mapStops;

@property (strong,nonatomic) NSMutableArray *stopTimes;
@property (strong,nonatomic) NSMutableArray *stopTimeArray;
@property (strong,nonatomic) NSMutableDictionary *stopTimeDictionary;

@property (strong, nonatomic) IBOutlet UIView *containerView;

@property (strong, nonatomic) JHStopCalloutView *calloutView;

@property (strong, nonatomic) IBOutlet UIView *mapControlsView;

@property (weak,nonatomic) id<MKAnnotation> selectedAnnotation;


@property (strong, nonatomic) IBOutlet UIButton *busInfoButton;
- (IBAction)busInfoButtonPress:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *showBusStopsButton;
- (IBAction)showBusStopsButtonPress:(id)sender;

@end

@implementation JHRouteDetailViewController

@synthesize routeInfo = _routeInfo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)setRouteInfo:(Routes *)info
{
    _routeInfo = info;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [self.stopTimeView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
//    [self.stopTimeView setCollectionViewLayout:[[MMStopDetailLayout alloc]init]];
    
    [self.mapView setDelegate:self];
    self.title = [self.routeInfo route_long_name];
    

    self.mapStops= [NSMutableArray array];
    self.stopTimeDictionary = [NSMutableDictionary dictionary];
    self.stopTimeArray = [NSMutableArray array];
    self.northStops = [NSMutableArray array];
    self.southStops = [NSMutableArray array];
    
    dispatch_queue_t stopTimes = dispatch_queue_create("com.jhh.bus_stop_times", NULL); // create my serial queue
    dispatch_async(stopTimes, ^{
        self.stopTimes = [[JHBusRouteRepository routeProvider] getStopTimesForRouteInBackground:self.routeInfo.route_id];
        for (StopTimes *st in self.stopTimes) {
            
            
            if ([self.stopTimeDictionary objectForKey:[st.arrival_time substringToIndex:st.arrival_time.length-3]] == nil)
            {
                [self.stopTimeDictionary setObject:[NSMutableArray array] forKey:[st.arrival_time substringToIndex:st.arrival_time.length-3]];
                [self.stopTimeArray addObject:[st.arrival_time substringToIndex:st.arrival_time.length-3]];
            }
            
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", st.stop.stop_name];
            NSArray *matchingObjs = [self.mapStops filteredArrayUsingPredicate:predicate];
            
            if ([matchingObjs count] == 0)
            {
                
                Stops *currentStop = st.stop;
                JHStopPointAnnotation *annotation = [[JHStopPointAnnotation alloc] init];
                [annotation setCoordinate:CLLocationCoordinate2DMake([currentStop.stop_lat doubleValue], [currentStop.stop_lon doubleValue])];
                
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:currentStop,@"stop",annotation,@"annotation",st.stop.stop_name,@"name",nil];
                [self.mapStops addObject:dict];
                [annotation setTitle:st.stop.stop_name];
                if ([st.trips.direction_id doubleValue] == 0) {
                    [self.northStops addObject:annotation];
                }else
                {
                    [self.southStops addObject:annotation];
                }
            }
        }
    });
                   

    [self createRoute];
    [self getCurrentBusesForRoute];

    // Do any additional setup after loading the view from its nib.
}
-(void)viewDidAppear:(BOOL)animated
{
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)getCurrentBusesForRoute
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://developer.itsmarta.com/BRDRestService/BRDRestService.svc/GetBusByRoute/%@",self.routeInfo.route_short_name]];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
    {

        if (error)
        {
            //NSLog(@"Error,%@", [error localizedDescription]);
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                NSError *e;
                NSMutableArray *buses = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &e];
                int i = 0;
                self.buses = [NSMutableArray array];
                [self.svBuses superview] == nil ? : [self.svBuses removeFromSuperview] ;
                self.svBuses = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 320, 125)];
                [self.detailsView addSubview:self.svBuses];
                for (NSMutableDictionary *dict in buses) {
                    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                    [annotation setCoordinate:CLLocationCoordinate2DMake([dict[@"LATITUDE"] doubleValue], [dict[@"LONGITUDE"] doubleValue])];
                    [self.mapView addAnnotation:annotation];
                    
                    UIView *busView = [[UIView alloc]initWithFrame:CGRectMake(i * 320, 0, 320, 125)];
                    UIImageView *iv = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bus-icon.png"]];
                    [iv setFrame:CGRectMake(0, 0, iv.image.size.width, iv.image.size.height)];
                    [busView addSubview:iv];
                    
                    UITextView *tv = [[UITextView alloc]initWithFrame:CGRectMake(131, 0, 320-131, 125)];
                    int adherence = [dict[@"ADHERENCE"] integerValue];
                    NSString *status = @"ON TIME";
                    if (adherence > 0) {
                        status = [NSString stringWithFormat:@"%d minutes AHEAD OF SCHEDULE",adherence];
                    }else if(adherence < 0)
                    {
                        status = [NSString stringWithFormat:@"%d minutes BEHIND SCHEDULE",abs(adherence)];
                    }
                    [tv setText:[NSString stringWithFormat:@"This is bus number %@ heading %@.  It is currently %@. It was last seen at %@ around %@",
                                 dict[@"VEHICLE"],
                                 dict[@"DIRECTION"],
                                 status,
                                 dict[@"TIMEPOINT"],
                                 dict[@"MSGTIME"]]];
                    [busView addSubview:tv];
                    
                    UIButton *busInfo = [UIButton buttonWithType:UIButtonTypeCustom];
                    [busInfo setTag:i];
                    [busInfo addTarget:self action:@selector(showBus:) forControlEvents:UIControlEventTouchUpInside];
                    [busInfo setFrame:busView.frame];
                    
                    [self.svBuses addSubview:busView];
                    [self.svBuses addSubview:busInfo];
                    
                    i++;
                    [self.buses addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:dict,@"bus",annotation,@"annotation",nil]];
                }
                [self.svBuses setContentSize:CGSizeMake(320 * self.buses.count, 125)];
                [self.svBuses setPagingEnabled:YES];
            });
            //NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
        }
    }];
    
}


//http://developer.itsmarta.com/NextTrainService/RestServiceNextTrain.svc/GetNextTrain/Georgia%20State

-(void)showBus:(UIButton *)sender
{
    MKPointAnnotation *annotation = [[self.buses objectAtIndex:sender.tag] objectForKey:@"annotation"];
    [self.mapView selectAnnotation:annotation animated:YES];
}

//Map Stuff
-(void)createRoute
{
//    trip
    NSArray *array = [[JHBusRouteRepository routeProvider] routeShape:[[self.routeInfo route_id] intValue]];
    self.polylines = [NSMutableArray array];
    MKMapRect r = MKMapRectNull;
    for (NSNumber *shapeId in array)
    {
        NSArray *locations = [[JHBusRouteRepository routeProvider] getFullShapeByID:[shapeId intValue]];
        
        int numPoints = [locations count];
        if (numPoints > 1)
        {
            CLLocationCoordinate2D* coords = malloc(numPoints * sizeof(CLLocationCoordinate2D));
            int i = 0;
            for(Shapes *shape in locations)
            {
                CLLocation* current = [[CLLocation alloc]initWithLatitude:[shape.shape_lat doubleValue] longitude:[shape.shape_long doubleValue]];
                coords[i] = current.coordinate;
                MKMapPoint p = MKMapPointForCoordinate(coords[i]);
                r = MKMapRectUnion(r, MKMapRectMake(p.x, p.y, 0, 0));
                i++;
            }
            MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coords count:i-1];
            free(coords);
            
            [self.polylines addObject:polyline];
            [self.mapView addOverlay:polyline];
        }
        
    }
    

    // 2
    MKCoordinateRegion viewRegion = MKCoordinateRegionForMapRect(r);
    // 3
    [self.mapView setRegion:viewRegion animated:YES];
    return
    
    [self.mapView setNeedsDisplay];
    
}
- (MKOverlayView*)mapView:(MKMapView*)theMapView viewForOverlay:(id <MKOverlay>)overlay
{
    MKPolylineView* lineView = nil;
    for (MKPolyline *poly in self.polylines) {
        if (poly == overlay) {
            lineView = [[MKPolylineView alloc] initWithPolyline:poly];
        }
    }
    
//    lineView.fillColor = [UIColor redColor];
    lineView.strokeColor = [UIColor blackColor];
    lineView.lineWidth = 4;
    return lineView;
}

MKCoordinateRegion coordinateRegionForCoordinates(CLLocationCoordinate2D *coords, NSUInteger coordCount) {
    MKMapRect r = MKMapRectNull;
    for (NSUInteger i=0; i < coordCount; ++i) {
        MKMapPoint p = MKMapPointForCoordinate(coords[i]);
        r = MKMapRectUnion(r, MKMapRectMake(p.x, p.y, 0, 0));
    }
    return MKCoordinateRegionForMapRect(r);
}
-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    for (UIView *subview in view.subviews ){
        [subview removeFromSuperview];
    }
}
- (void)btnCloseStop
{
    MKMapView *map = [[MKMapView alloc]initWithFrame:self.view.bounds];
    [map addAnnotations:self.northStops];
    [map setDelegate:self];
    [map setRegion:self.mapView.region];
    for (MKPolyline *poly in self.polylines) {
        [map addOverlay:poly];
    }
    [map selectAnnotation:self.selectedAnnotation animated:NO];
    self.mapView = map;

    [UIView animateWithDuration:0.25f animations:^{
        [self.mapControlsView setAlpha:1.0f];
        [self.detailsView setAlpha:1.0f];
    }];
    
    [MPFoldTransition transitionFromView:[self.containerView.subviews objectAtIndex:0]
                                  toView:self.mapView
                                duration:[MPFoldTransition defaultDuration]
                                   style:1? MPFoldStyleCubic	: MPFoldStyleFlipFoldBit(MPFoldStyleCubic)
                        transitionAction:MPTransitionActionAddRemove
                              completion:^(BOOL finished) {
                                  [self getCurrentBusesForRoute];
                              }
     ];
}

-(void)viewStopTimes:(UIButton *)sender
{
    
    NSMutableDictionary *dict = [self.mapStops objectAtIndex:sender.tag];
    Stops *selectedStop = [dict objectForKey:@"stop"];
    self.selectedAnnotation = [dict objectForKey:@"annotation"];

    
    self.calloutView = [[JHStopCalloutView alloc]initWithFrame:CGRectMake(0, 0, 320, 504)];
    [self.calloutView setParent:self];
    self.calloutView.lblStopName.text = selectedStop.stop_name;
    
    int xCounter= 0, yCounter = 0;
    //scrollview is 100tall
    for (StopTimes *st in [selectedStop orderedStopTimes]) {
        UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(xCounter, 25 * yCounter, 80, 25)];
        
        NSTimeInterval secondsBetween = [[st arrivalTime] timeIntervalSinceDate:[NSDate date]];
        
        if (secondsBetween < 0) {
            [lbl setBackgroundColor:[UIColor redColor]];
        }else if(secondsBetween <= 1200)
        {
            [lbl setBackgroundColor:[UIColor yellowColor]];
        }else
        {
            [lbl setBackgroundColor:[UIColor greenColor]];
        }
        
        
        [lbl setText:st.arrival_time];
        [self.calloutView.svStopTimes addSubview:lbl];
        yCounter++;
        if (yCounter >=16) {
            yCounter = 0;
            xCounter+= 86;
        }
        
    }
    xCounter+= 86;
    
//    [self.calloutView.svStopTimes setBackgroundColor:[UIColor lightGrayColor]];
    [self.calloutView.svStopTimes setContentSize:CGSizeMake(xCounter, 100)];

    [UIView animateWithDuration:0.25f animations:^{
        [self.mapControlsView setAlpha:0.0f];
        [self.detailsView setAlpha:0.0f];
    }];
    
    [MPFoldTransition transitionFromView:[self.containerView.subviews objectAtIndex:0]
                                  toView:self.calloutView
                                duration:[MPFoldTransition defaultDuration]
                                   style:0? MPFoldStyleCubic	: MPFoldStyleFlipFoldBit(MPFoldStyleCubic)
                        transitionAction:MPTransitionActionAddRemove
                              completion:^(BOOL finished) {
                                  [self.containerView bringSubviewToFront:self.calloutView];
                              }
     ];
}
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if(![view.annotation isKindOfClass:[MKUserLocation class]]) {
        if ([view.annotation isKindOfClass:[JHStopPointAnnotation class]])
        {

        }else
        {
            JHBusCalloutView *calloutView = (JHBusCalloutView *)[[[NSBundle mainBundle] loadNibNamed:@"JHBusCalloutView" owner:self options:nil] objectAtIndex:0];
            
            CGRect calloutViewFrame = calloutView.frame;
            
            for (NSMutableDictionary *dict in self.buses) {
                MKPointAnnotation *obj = [dict objectForKey:@"annotation"];
                if ([obj isEqual:view.annotation]) {
                    NSDictionary *bus = [dict objectForKey:@"bus"];
                    calloutView.lblBusNumber.text = [bus objectForKey:@"VEHICLE"];
                    int adherence = [bus[@"ADHERENCE"] integerValue];
                    NSString *status = @"OT";
                    if (adherence > 0) {
                        status = [NSString stringWithFormat:@"%d",adherence];
                        [calloutView.lblTiming setTextColor:[UIColor greenColor]];
                    }else if(adherence < 0)
                    {
                        status = [NSString stringWithFormat:@"%d",abs(adherence)];
                        [calloutView.lblTiming setTextColor:[UIColor redColor]];
                    }
                    [calloutView.lblTiming setTextAlignment:NSTextAlignmentCenter];
                    calloutView.lblTiming.text = status;
                    break;
                }
            }
            calloutViewFrame.origin = CGPointMake(-calloutViewFrame.size.width/2 + 15, -calloutViewFrame.size.height);
            calloutView.frame = calloutViewFrame;
    //        [calloutView.calloutLabel setText:[(myAnnotation*)[view annotation] title]];
            [view addSubview:calloutView];
        }
    }
    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.005;
    span.longitudeDelta = 0.005;
    CLLocationCoordinate2D location;
    location.latitude = view.annotation.coordinate.latitude;
    location.longitude = view.annotation.coordinate.longitude;
    region.span = span;
    region.center = location;
    [self.mapView setRegion:region animated:YES];
    
}
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    else if ([annotation isKindOfClass:[JHStopPointAnnotation class]]) // use whatever annotation class you used when creating the annotation
    {
        static NSString * const identifier = @"StopPointAnnotation";
        
        MKAnnotationView* annotationView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if (annotationView)
        {
            annotationView.annotation = annotation;
        }
        else
        {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                          reuseIdentifier:identifier];
        }
        
        
        JHStopPointAnnotation *annote = annotation;
        int i = 0;
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        for (NSMutableDictionary *dict in self.mapStops) {
            JHStopPointAnnotation *annotation = [dict objectForKey:@"annotation"];
            if ([annotation isEqual:annote]) {
                [leftButton setTag:i];
                break;
            }
            i++;
        }


        [leftButton addTarget:self action:@selector(viewStopTimes:) forControlEvents:UIControlEventTouchUpInside];
        annotationView.rightCalloutAccessoryView = leftButton;
        annotationView.canShowCallout = YES;
        annotationView.image = [UIImage imageNamed:@"busstop.png"];
        [annotationView setBackgroundColor:[UIColor clearColor]];
        return annotationView;
    }else
    {
        static NSString * const identifier = @"BusAnnotation";
        
        MKAnnotationView* annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if (annotationView)
        {
            annotationView.annotation = annotation;
        }
        else
        {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                          reuseIdentifier:identifier];
        }
        
        annotationView.canShowCallout = NO;
        annotationView.image = [UIImage imageNamed:@"bus.png"];
        [annotationView setBackgroundColor:[UIColor clearColor]];
        return annotationView;
    }
    return nil;
}

- (IBAction)btnCloseAllStopsPress:(id)sender {
    [UIView animateWithDuration:0.75f animations:^{
        CGRect frame = self.routeTimesView.frame;
        frame.origin.y = -180;
        [self.routeTimesView setFrame:frame];
    }];
}

- (IBAction)btnViewAllStopsPress:(id)sender {
    [UIView animateWithDuration:0.75f animations:^{
        CGRect frame = self.routeTimesView.frame;
        frame.origin.y = 195;
        [self.routeTimesView setFrame:frame];
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.stopTimeArray.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    NSInteger index = indexPath.row;
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UICollectionViewCell alloc]init];
    } else
    {
        for (UIView *subview in cell.contentView.subviews) {
            [subview removeFromSuperview];
        }
    }
    
    NSString *string = [self.stopTimeArray objectAtIndex:index];

    UILabel *lbl2 = [[UILabel alloc]initWithFrame:CGRectMake(6, 6, 308, 20)];
    [lbl2 setText:string];
    [cell.contentView addSubview:lbl2];
    
    NSMutableArray *array = [self.stopTimeDictionary objectForKey:string];
    NSString *stopString = @"";
    for (StopTimes *st in array) {
        stopString = [stopString stringByAppendingString:[NSString stringWithFormat:@" %@",st.stop.stop_name]];
    }
    UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(55, 6, 308, 20)];
    [lbl setText:stopString];
    [cell.contentView addSubview:lbl];
    
    [cell setBackgroundColor:[UIColor whiteColor]];
    return cell;
}
- (IBAction)northButtonPress:(id)sender {
    [self.mapView removeAnnotations:self.southStops];
    [self.mapView addAnnotations:self.northStops];
    [self.btnNorth setEnabled:NO];
    [self.btnSouth setEnabled:YES];
}
- (IBAction)southButtonPress:(id)sender {
    [self.mapView removeAnnotations:self.northStops];
    [self.mapView addAnnotations:self.southStops];
    [self.btnNorth setEnabled:YES];
    [self.btnSouth setEnabled:NO];
}
- (IBAction)busInfoButtonPress:(id)sender {
    if (self.detailsView.frame.origin.y == 0) {
        [self.busInfoButton setTitle:@"Show Bus Info" forState:UIControlStateNormal];        
        [UIView animateWithDuration:0.35f animations:^{
            CGRect frame = self.detailsView.frame;
            frame.origin.y = -131;
            self.detailsView.frame = frame;
        }];
    }else
    {
        [self.busInfoButton setTitle:@"Hide Bus Info" forState:UIControlStateNormal];
        [UIView animateWithDuration:0.35f animations:^{
            CGRect frame = self.detailsView.frame;
            frame.origin.y = 0;
            self.detailsView.frame = frame;
        }];
    }
}
- (IBAction)btnHideStopsPress:(id)sender {
    self.btnNorth.enabled ? [self.mapView removeAnnotations:self.southStops] : [self.mapView removeAnnotations:self.northStops];
    
    [self.showBusStopsButton setHidden:NO];
}
- (IBAction)showBusStopsButtonPress:(id)sender {
    [self.mapView addAnnotations:self.northStops];
    [self.btnNorth setEnabled:NO];
    [self.btnSouth setEnabled:YES];
    [self.showBusStopsButton setHidden:YES];
}
@end
