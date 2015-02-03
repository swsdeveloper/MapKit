//
//  SWSPlace.h
//  MapKit
//
//  Created by Steven Shatz on 2/2/15.
//  Copyright (c) 2015 Steven Shatz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface SWSPlace : NSObject

@property (copy, nonatomic) NSString *placeID;

@property (assign, nonatomic) CLLocationCoordinate2D coord;

@property (copy, nonatomic) NSString *name;

@property (copy, nonatomic) NSString *addr;

@property (strong, nonatomic) UIImage *icon;

@property (copy, nonatomic) NSURL *url;

@end
