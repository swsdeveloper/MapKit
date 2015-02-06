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


@interface SWSViewController : UIViewController <NSURLConnectionDataDelegate, UISearchBarDelegate>

@property (assign, nonatomic) BOOL shouldHideStatusBar;

@property (strong, nonatomic) SWSMap *map;

@property (strong, nonatomic) SWSLocationManager *swsLocationManager;

@property (strong, nonatomic) MKPointAnnotation *turnToTechAnnotation;

@property (strong, nonatomic) MKPointAnnotation *draggableAnnotation;

@property (strong, nonatomic) MKPointAnnotation *placeAnnotation;

@property (strong, nonatomic) MKPinAnnotationView *annotationView;

@property (strong, nonatomic) NSDictionary *restaurants;

// For Google Places Queries:

@property (strong, nonatomic) UISearchBar *searchBar;

//@property (weak, nonatomic) IBOutlet UITextField *searchTextField;

@property (strong, nonatomic) NSMutableData *dataReceived;  // for NSURLConnectionDataDelegate methods - not currently used

@property (strong, nonatomic) NSMutableArray *placesArray;  // array of SWSPlace objects

- (void)googlePlaceDetailsSearch:(NSString *)placeID;   // sets self.placeIDUrl

@end

