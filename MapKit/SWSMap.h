//
//  SWSMap.h
//  MapKit
//
//  Created by Steven Shatz on 1/21/15.
//  Copyright (c) 2015 Steven Shatz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@class SWSViewController;


@interface SWSMap : MKMapView <MKAnnotation, MKMapViewDelegate, UIPopoverControllerDelegate> {
    
    int _currentRouteNumber;
}

@property (strong, nonatomic) SWSViewController *viewController;

@property (assign, nonatomic) MKCoordinateSpan span;        // struct consisting of 2 CLLocationDegrees (latitudeDelta and longitudeDelta)

@property (assign, nonatomic) MKCoordinateRegion region;    // struct consisting of CLLocationCoordinate2D (center) and MKCoordinateSpan (span)

@property (copy, nonatomic) MKMapCamera *camera;

@property (readonly, nonatomic) CLLocationCoordinate2D coordinate;

@property (nonatomic) CGSize popoverContentSize;

@property (assign, nonatomic) MKDirectionsTransportType transportType;

@property (strong, nonatomic) MKMapItem *destinationPin;

@property (assign, nonatomic) CLLocationCoordinate2D droppedAt;

- (id)initForViewController:(SWSViewController *)viewController;

- (void)setMapDefaults;

- (void)setMapSpanToLatitude:(CLLocationDegrees)latitudeDegrees andLongitude:(CLLocationDegrees)longitudeDegrees; // for Standard map type (and Hybrid)

- (void)setCameraToLookAtLocation:(CLLocationCoordinate2D)atLocation fromLocation:(CLLocationCoordinate2D)fromLocation andAltitudeInMeters:(CLLocationDistance)altitude;
                                                                                                                  // for Satellite map type (and Hybrid)
- (void)setMapRegionToSpanLocation:(CLLocationCoordinate2D)location;

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

- (void)showAllRoutesTo:(MKMapItem *)destItem;

- (CLLocationCoordinate2D)currentUserLocation;

- (void)fitAnnotationsKeepingCenter;

@end
