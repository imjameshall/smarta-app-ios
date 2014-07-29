//
//  JHViewController.m
//  sMARTA
//
//  Created by James Hall on 9/17/13.
//  Copyright (c) 2013 James Hall. All rights reserved.
//


#import "Routes.h"
#import "JHViewController.h"
#import "JHBusRouteRepository.h"
#import "JHHeaderView.h"
#import "JHRouteDetailViewController.h"
#import "MMBaseFlowLayout.h"

@interface JHViewController ()
@property (strong, nonatomic) IBOutlet UICollectionView *cvCollection;
@property (strong, nonatomic) NSMutableArray *busRoutes;
@property (strong, nonatomic) NSMutableArray *trainRoutes;
@end

@implementation JHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Routes";
    self.busRoutes = [[JHBusRouteRepository routeProvider] busRoutes];
    self.trainRoutes = [[JHBusRouteRepository routeProvider] trainRoutes];
    [self.cvCollection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.cvCollection registerClass:[JHHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"JHHeaderView"];
    [self.cvCollection setCollectionViewLayout:[[MMBaseFlowLayout alloc]init]];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0) {
         return [self.trainRoutes count];
    }else
    {
        return [self.busRoutes count];
    }
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;

    if (kind == UICollectionElementKindSectionHeader) {
        JHHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"JHHeaderView" forIndexPath:indexPath];

        indexPath.section == 0 ? [headerView setHeaderText:@"Trains"]:[headerView setHeaderText:@"Buses"];
        

        return headerView;


    }
    return reusableview;
}



-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
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
    

    Routes *obj = nil;
    
    if(indexPath.section == 0)
        obj = [self.trainRoutes objectAtIndex:index];
    else
        obj = [self.busRoutes objectAtIndex:index];
    
    
    UILabel *lbl2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 60, 50)];
    [lbl2 setText:obj.route_short_name];
    [lbl2 setTextAlignment:NSTextAlignmentCenter];
    if (indexPath.section == 0)
        [lbl2 setFont:[UIFont fontWithName:@"GillSans" size:18.0f]];
    else
        [lbl2 setFont:[UIFont fontWithName:@"GillSans" size:28.0f]];
    
    
    [cell.contentView addSubview:lbl2];
    

    UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(70, 0, 224, 50)];
    [lbl setNumberOfLines:0];
    [lbl setFont:[UIFont fontWithName:@"GillSans" size:18.0f]];
    if (indexPath.section == 0) {
        NSArray *array = [obj.route_long_name componentsSeparatedByString:@"-"];
        [lbl setText:[array objectAtIndex:1]];
    }else
        [lbl setText:obj.route_long_name];
    
    
    [cell.contentView addSubview:lbl];
    
    [cell setBackgroundColor:[UIColor whiteColor]];
//    [cell setBackgroundColor:[[JHBusRouteRepository routeProvider] colorFromHexString:[NSString stringWithFormat:@"#%@",obj.route_color]]];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    JHRouteDetailViewController *routeDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"RouteDetailViewController"];
    
    if(indexPath.section == 0)
        [routeDetail setRouteInfo:self.trainRoutes[[indexPath row]]];
    else
        [routeDetail setRouteInfo:self.busRoutes[[indexPath row]]];
    

    [self.navigationController pushViewController:routeDetail animated:YES];
}
@end
