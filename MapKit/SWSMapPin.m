//
//  SWSMapPin.m
//  MapKit
//
//  Created by Steven Shatz on 1/21/15.
//  Copyright (c) 2015 Steven Shatz. All rights reserved.
//

#import "SWSMapPin.h"

// There are 3 types of Map Annotations:

// MKUserLocation = an annotation that defines the user's current location (represented by a glowing blue circle on the map)

// MKPointAnnotation = a simple pin with a Title and Subtitle



// MKAnnotationView = controls the display of annotations, adding extra abilities like pin color, image, and callouts

// MKPinAnnotationView = a subclass of MKAnnotationView that displays the annotation as a Pin

// A custom annotation view class = a subclass of MKPointAnnotation which confroms to MKAnnotation Protocol



@implementation SWSMapPin

- (id)initMapPinForAnnotationView {
    self = [super init];
    if (self) {
        _annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier];
    }
    return self;
}

- (id)initMapPinForLocation:(CLLocationCoordinate2D)location withTitle:(NSString *)title subtitle:(NSString *)subtitle andPinColor:(MKPinAnnotationColor)color {
    self = [super init];
    if (self) {
        _pointAnnotation = [[MKPointAnnotation alloc] init];    // Point Annotation = a standard red pin
        
        // MKPointAnnotation is an extension of MKShape; it also adheres to MKAnnotation protocol
        // MKShape has title and subtitle properties (both Strings)
        // The underlying protocol has a setCoordinate method - adds the location to the specified annotation object
        
        _pointAnnotation.coordinate = location;
        _pointAnnotation.title = title;
        _pointAnnotation.subtitle = subtitle;
        
        _title = title;
        _subtitle = subtitle;
        _color = color;

        _pinAnnotation = [[MKPinAnnotationView alloc] init];    // Pin Annotation = a more versatile pin
        
        _pinAnnotation.pinColor = color;
        _pinAnnotation.animatesDrop = YES;
        
    }
    return self;
}

@end
