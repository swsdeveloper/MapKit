//
//  SWSAnnotation.m
//  MapKit
//
//  Created by Steven Shatz on 1/25/15.
//  Copyright (c) 2015 Steven Shatz. All rights reserved.
//

#import "SWSAnnotation.h"
#import "Constants.h"

@implementation SWSAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title subtitle:(NSString *)subtitle {
    self = [super init];
    if (self) {
        _coordinate = coordinate;
        _title = title;
        _subtitle =subtitle;
    }
    return self;
}

// ****************************************************
// * The next 2 methods are for use by NSUserDefaults *
// ****************************************************

- (void)encodeWithCoder:(NSCoder *)encoder {
    NSLog(@"%s", __FUNCTION__);
    [encoder encodeDouble:self.coordinate.latitude forKey:@"swsAnnotationLatitude"];
    [encoder encodeDouble:self.coordinate.longitude forKey:@"swsAnnotationLongitude"];
    [encoder encodeObject:self.title forKey:@"swsAnnotationTitle"];
    [encoder encodeObject:self.subtitle forKey:@"swsAnnotationSubtitle"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    NSLog(@"%s", __FUNCTION__);
    self = [super init];
    if(self) {
        _coordinate.latitude = [decoder decodeDoubleForKey:@"swsAnnotationLatitude"];
        _coordinate.longitude = [decoder decodeDoubleForKey:@"swsAnnotationLongitude"];
        _title = [decoder decodeObjectForKey:@"swsAnnotationTitle"];
        _subtitle = [decoder decodeObjectForKey:@"swsAnnotationSubtitle"];
    }
    return self;
}

// This method is required for the MKAnnotation Protocol

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    self.coordinate = newCoordinate;    // new center point for an annotation
}

@end
