//
//  SWSPointAnnotation.m
//  MapKit
//
//  Created by Steven Shatz on 1/25/15.
//  Copyright (c) 2015 Steven Shatz. All rights reserved.
//

#import "SWSGeocodedAnnotations.h"
#import "Constants.h"


@implementation SWSGeocodedAnnotations

- (id)init {
    self = [super init];
    if (self) {
        _geocodedAnnotationsArray = [[NSMutableArray alloc] init];
    }
    return self;
}

// ****************************************************
// * The next 2 methods are for use by NSUserDefaults *
// ****************************************************

- (void)encodeWithCoder:(NSCoder *)encoder {
    NSLog(@"%s", __FUNCTION__);
    [encoder encodeObject:[self geocodedAnnotationsArray] forKey:@"geocodedAnnotations"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    NSLog(@"%s", __FUNCTION__);
    self = [super init];
    if(self) {
        _geocodedAnnotationsArray = [decoder decodeObjectForKey:@"geocodedAnnotations"];
    }
    return self;
}

@end
