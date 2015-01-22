//
//  SWSLocationManager.h
//  MapKit
//
//  Created by Steven Shatz on 1/21/15.
//  Copyright (c) 2015 Steven Shatz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface SWSLocationManager : NSObject <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager* locationManager;

- (id)initWithAccuracy:(CLLocationAccuracy)accuracy;

- (CLLocationCoordinate2D)setLocationAtLatitude:(CLLocationDegrees)latitude andLongitude:(CLLocationDegrees)longitude;

@end
