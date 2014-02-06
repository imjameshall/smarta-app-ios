//
//  MMStopDetailLayout.m
//  sMARTA
//
//  Created by James Hall on 12/26/13.
//  Copyright (c) 2013 James Hall. All rights reserved.
//

#import "MMStopDetailLayout.h"

@implementation MMStopDetailLayout


-(id)init {
    if (!(self = [super init]))
        return nil;
    
    self.minimumInteritemSpacing = 10;
    self.minimumLineSpacing = 10;
    self.itemSize = CGSizeMake(320, 75);
    self.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    
    return self;
}

@end
