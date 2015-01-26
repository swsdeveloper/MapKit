//
//  SWSPointAnnotation.h
//  MapKit
//
//  Created by Steven Shatz on 1/25/15.
//  Copyright (c) 2015 Steven Shatz. All rights reserved.
//

#import <MapKit/MapKit.h>


@interface SWSAnnotation : NSObject <MKAnnotation>

@property (assign, nonatomic) CLLocationCoordinate2D coordinate;

@property (copy, nonatomic) NSString *title;

@property (copy, nonatomic) NSString *subtitle;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title subtitle:(NSString *)subtitle;

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

@end
