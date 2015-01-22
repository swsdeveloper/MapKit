//
//  SWSMapPin.h
//  MapKit
//
//  Created by Steven Shatz on 1/21/15.
//  Copyright (c) 2015 Steven Shatz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "SWSLocationManager.h"


@interface SWSMapPin : NSObject

@property (strong, nonatomic) MKAnnotationView *annotationView;

@property (strong, nonatomic) MKPinAnnotationView *pinAnnotationView;

@property (strong, nonatomic) MKPointAnnotation *pointAnnotation;

@property (strong, nonatomic) NSString *title;

@property (strong, nonatomic) NSString *subtitle;

@property (assign, nonatomic) MKPinAnnotationColor color;

@property (strong, nonatomic) UIImage *image;

- (id)initMapPinForAnnotationView;

- (id)initMapPinForPinAnnotationView;

ForLocation:(CLLocationCoordinate2D)location withTitle:(NSString *)title subtitle:(NSString *)subtitle andPinColor:(MKPinAnnotationColor)color;

@end
