//
//  SWSViewController.m
//  MapKit
//
//  Created by Steven Shatz on 1/20/15.
//  Copyright (c) 2015 Steven Shatz. All rights reserved.
//

#import "SWSViewController.h"
#import "Constants.h"
#import <AddressBook/AddressBook.h>
#import "SWSGeocodedAnnotations.h"
#import "SWSAnnotation.h"


@interface SWSViewController ()

@end

@implementation SWSViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationManager = [[SWSLocationManager alloc] initWithAccuracy:kCLLocationAccuracyBest];    // Create manager and start tracking user's current location
    
    self.map = [[SWSMap alloc] initForViewController:self];
    
    [self.view addSubview:self.map];
    [self.view sendSubviewToBack:self.map];
    
    [self.map setMapDefaults];
    
    self.map.mapType = MKMapTypeStandard;                       // Start in Standard view (as opposed to MKMapTypeSatellite or MKMapTypeHybrid)
    
    [self.map setMapSpanToLatitude:0.04 andLongitude:0.04];     // Zoom in fairly close (only show 0.04 degrees of full map area)
    
    // Turn To Tech Annotation
    
    CLLocationCoordinate2D turnToTechLocation = [self.locationManager setLocationAtLatitude:40.741448 andLongitude:-73.989969];
    
    // For testing, set simulator's current location to: 40.7415, -73.989
    
    CLLocationCoordinate2D cameraLocation = [self.locationManager setLocationAtLatitude:turnToTechLocation.latitude - 0.05
                                                                           andLongitude:turnToTechLocation.longitude - 0.05];   // set for Satellite view
    
    [self.map setCameraToLookAtLocation:turnToTechLocation fromLocation:cameraLocation andAltitudeInMeters:100.0];

    [self.map setMapRegionToSpanLocation:turnToTechLocation];   // Center map around Turn To Tech
    
    self.turnToTechAnnotation = [[MKPointAnnotation alloc] init];
    self.turnToTechAnnotation.coordinate = turnToTechLocation;
    self.turnToTechAnnotation.title = @"Turn To Tech";
    self.turnToTechAnnotation.subtitle = @"184 Fifth Avenue, 4th Floor";
    
    [self.map addAnnotation:self.turnToTechAnnotation];
    
    // Draggable Annotation
    
    CLLocationCoordinate2D draggableLocation = [self.locationManager setLocationAtLatitude:40.742000 andLongitude:-73.99000];
    
    self.draggableAnnotation = [[MKPointAnnotation alloc] init];
    self.draggableAnnotation.coordinate = draggableLocation;
    self.draggableAnnotation.title = @"Draggable Pin";
    self.draggableAnnotation.subtitle = @"";
    
    [self.map addAnnotation:self.draggableAnnotation];
    
    // Placemarks - use geocoding to convert full or partial addresses into latitudes/longitudes
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSData *encodedObject = [defaults objectForKey:@"SWS-GeocodedAnnotations"];
    
    SWSGeocodedAnnotations *annotationsObject = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    
    if (!annotationsObject || [annotationsObject.geocodedAnnotationsArray count] < 1) {
        
        NSMutableArray *newAnnotationsArray = [[NSMutableArray alloc] init];
    
        self.restaurants = @{
                             @"ABC Kitchen":@"35 E 18th St, Flatiron, New York, NY 10003",
                             @"Bite":@"211 E 14th St, Gramercy, New York, NY 10003",
                             @"Cambodian Cuisine Torsu" : @"Flatiron, New York, NY",
                             @"Gramercy Tavern" : @"42 E 20th St, Flatiron, New York, NY 10003",
                             @"Nowhere Restaurant":@"FOFOFO, NY 10003",
                             @"Great Burrito" : @"100 W 23rd St, Chelsea, New York, NY 10011",
                             @"Johny's Luncheonette" : @"124 W 25th St, Chelsea, New York, NY 10001",
                             @"Ootoya" : @"8 W 18th St, Flatiron, New York, NY 10011",
                             @"Pippali" : @"129 E 27th St, Flatiron, New York, NY 10016",
                             @"Taim" : @"222 Waverly Pl, West Village, New York, NY 10014",
                             @"Woorijip Authentic Korean Food" : @"12 W 32nd St, Midtown West, New York, NY 10001"
                             };

        for (id restaurantName in self.restaurants) {
            
            NSLog(@"Geocode request invoked for %@", restaurantName);
            
            NSString *restaurantAddress = [self.restaurants objectForKey:restaurantName];
            
            // Defines a geocoder object - this converts addresses to latitude/longitude and vice-versa
            
            CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            
            [geocoder geocodeAddressString:restaurantAddress completionHandler:^(NSArray* placemarks, NSError* error) {
                
                if (placemarks && placemarks.count > 0) {
                    
                    CLPlacemark *topPlacemark = [placemarks objectAtIndex:0];
                    
                    SWSAnnotation *newAnnotation = [[SWSAnnotation alloc] initWithCoordinate:topPlacemark.location.coordinate
                                                                                       title:restaurantName
                                                                                    subtitle:restaurantAddress];
                    [_map addAnnotation:newAnnotation];
                    
                    [newAnnotationsArray addObject:newAnnotation];
                    
                    // After geocoding, update NSUserDefaults
                    
                    SWSGeocodedAnnotations *newAnnotationsObject = [[SWSGeocodedAnnotations alloc] init];
                    newAnnotationsObject.geocodedAnnotationsArray = [[NSMutableArray alloc] initWithArray:newAnnotationsArray];
                    
                    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:newAnnotationsObject];
                    [defaults setObject:encodedObject forKey:@"SWS-GeocodedAnnotations"];
                    [defaults synchronize];
                    
                    NSLog(@"Saving newly geocoded locations in user defaults");
                }
            }];
        }
    } else {
        
        NSLog(@"Using previously saved user defaults for geocoded annotations");
        
        for (id annotation in annotationsObject.geocodedAnnotationsArray) {
            [_map addAnnotation:annotation];
        }
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)setMapType:(id)sender {
    switch (((UISegmentedControl *)sender).selectedSegmentIndex) {
        case 0:
            [self.map setMapType:MKMapTypeStandard];
            break;
        case 1:
            [self.map setMapType:MKMapTypeSatellite];
            break;
        case 2:
            [self.map setMapType:MKMapTypeHybrid];
            break;
        default:
            break;
    }
}

@end
