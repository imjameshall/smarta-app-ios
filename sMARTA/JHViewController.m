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
#import "JHRouteDetailViewController.h"
#import "MMBaseFlowLayout.h"

@interface JHViewController ()
@property (strong, nonatomic) IBOutlet UICollectionView *cvCollection;
@property (strong, nonatomic) NSMutableArray *routes;
@end

@implementation JHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Routes";
    self.routes = [[JHBusRouteRepository routeProvider] busRoutes];
    [self.cvCollection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
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
    return [self.routes count];
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
    
    Routes *obj = [self.routes objectAtIndex:index];
    UILabel *lbl2 = [[UILabel alloc]initWithFrame:CGRectMake(6, 6, 308, 20)];
    [lbl2 setText:obj.route_short_name];
    [cell.contentView addSubview:lbl2];
    

    UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(42, 6, 308, 20)];
    [lbl setText:obj.route_long_name];
    [cell.contentView addSubview:lbl];
    
    [cell setBackgroundColor:[UIColor whiteColor]];
//    [cell setBackgroundColor:[[JHBusRouteRepository routeProvider] colorFromHexString:[NSString stringWithFormat:@"#%@",obj.route_color]]];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    JHRouteDetailViewController *routeDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"RouteDetailViewController"];
    [routeDetail setRouteInfo:self.routes[[indexPath row]]];
    [self.navigationController pushViewController:routeDetail animated:YES];
}
@end
