//
//  SWSViewController.m
//  MapKit
//
//  Created by Steven Shatz on 1/20/15.
//  Copyright (c) 2015 Steven Shatz. All rights reserved.
//

#import "SWSViewController.h"
#import "Constants.h"


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
