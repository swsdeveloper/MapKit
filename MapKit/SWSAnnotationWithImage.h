//
//  SWSAnnotationWithImage.h
//  MapKit
//
//  Created by Steven Shatz on 1/30/15.
//  Copyright (c) 2015 Steven Shatz. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>


@interface SWSAnnotationWithImage : MKPointAnnotation

@property (copy, nonatomic) NSString *placeID;

@property (strong, nonatomic) UIImage *placeIcon;

@property (copy, nonatomic) NSURL *placeUrl;

@end
