//
//  JHHeaderView.h
//  sMARTA
//
//  Created by James Hall on 3/4/14.
//  Copyright (c) 2014 James Hall. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JHHeaderView : UICollectionReusableView

@property (strong,nonatomic) NSString *headerText;

+ (NSString *)kind;

@end
