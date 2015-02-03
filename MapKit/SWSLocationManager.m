//
//  SWSLocationManager.m
//  MapKit
//
//  Created by Steven Shatz on 1/21/15.
//  Copyright (c) 2015 Steven Shatz. All rights reserved.
//

#import "SWSLocationManager.h"
#import "Constants.h"


@implementation SWSLocationManager

// Create a Location Manager

- (id)initWithAccuracy:(CLLocationAccuracy)accuracy {
    self = [super init];
    if (self) {
        _locationManager = [[CLLocationManager alloc] init];
        
        [_locationManager setDelegate:self];
        
        [_locationManager setDesiredAccuracy:accuracy]; // eg: kCLLocationAccuracyBest
        
        [_locationManager requestAlwaysAuthorization];  // info.plist must include "NSLocationAlwaysUsageDescription"
        
        [_locationManager startUpdatingLocation];
    }
    return self;
}

// Set a location using the SWS Location Manager

- (CLLocationCoordinate2D)setLocationAtLatitude:(CLLocationDegrees)latitude andLongitude:(CLLocationDegrees)longitude {
    
    return CLLocationCoordinate2DMake(latitude, longitude);
}

// Return user's current location

- (CLLocationCoordinate2D)getUsersCurrentLocation {
    return [self setLocationAtLatitude:self.locationManager.location.coordinate.latitude
                          andLongitude:self.locationManager.location.coordinate.longitude];
}

#pragma mark CoreLocationDelegate Protocol Methods:

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    NSMutableArray *myLocs = [[NSMutableArray alloc] initWithArray:locations];
    
    CLLocation *myLoc = myLocs[0];
    
    NSLog(@"New Location: Latitude: %f, Longitude: %f", myLoc.coordinate.latitude, myLoc.coordinate.longitude);
    
    [self.locationManager stopUpdatingLocation];
    [self.locationManager startMonitoringSignificantLocationChanges];
    
    NSLog(@"Switching from Constant Loc Updates to only Significant Loc Changes");
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog (@"Error: %@", error.localizedDescription);
}

@end
