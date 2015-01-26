//
//  SWSViewController.h
//  MapKit
//
//  Created by Steven Shatz on 1/20/15.
//  Copyright (c) 2015 Steven Shatz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "SWSLocationManager.h"
#import "SWSMap.h"


@interface SWSViewController : UIViewController

@property (strong, nonatomic) SWSMap *map;

@property (strong, nonatomic) SWSLocationManager *locationManager;

@property (strong, nonatomic) MKPointAnnotation *turnToTechAnnotation;

@property (strong, nonatomic) MKPointAnnotation *draggableAnnotation;

@property (strong, nonatomic) MKPinAnnotationView *annotationView;

@property (strong, nonatomic) NSDictionary *restaurants;

//@property (readonly, nonatomic) CLLocationCoordinate2D coordinate;

@end

