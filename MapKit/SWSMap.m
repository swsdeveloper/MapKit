//
//  SWSMap.m
//  MapKit
//
//  Created by Steven Shatz on 1/21/15.
//  Copyright (c) 2015 Steven Shatz. All rights reserved.
//

#import "SWSMap.h"
#import "Constants.h"
#import "SWSLocationManager.h"
#import "MyUtil.h"
#import "SWSWebViewController.h"


@implementation SWSMap

- (id)initForViewController:(UIViewController *)viewController {
    self = [super init];
    if (self) {
        _viewController = viewController;
        self = [[SWSMap alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        }
    return self;
}

- (void)setMapDefaults {
    self.delegate = self;
    
    self.showsUserLocation = YES;       // defaults to YES - shows flashing blue circle
    self.showsPointsOfInterest = YES;
    self.showsBuildings = YES;
    self.rotateEnabled = NO;            // Set to NO when testing on simulator; otherwise set to YES
    self.zoomEnabled = YES;
    self.scrollEnabled = YES;
    self.pitchEnabled = YES;
}

// Indicate how much of map should be visible (in initial view)
// Span is set to latitude degrees and longitude degrees
//
// 1 degree of latitude = approx. 69 miles = 111 kilometers
// 1 degree of longitude is relative -- approx 69 miles at the equator, but 0 miles at the poles
//
// The smaller the number, the more zoomed in the image
// If this is set to 180.0, 360.0, entire world is shown, but scrolling is still neccessary to see it all

- (void)setMapSpanToLatitude:(CLLocationDegrees)latitudeDegrees andLongitude:(CLLocationDegrees)longitudeDegrees {
    if (!latitudeDegrees || latitudeDegrees > 180.0 || latitudeDegrees < 0.0) {
        latitudeDegrees = 180.0;
    }
    if (!longitudeDegrees || longitudeDegrees > 360.0 || longitudeDegrees < 0.0) {
        longitudeDegrees = 360.0;
    }
    self.span = MKCoordinateSpanMake(latitudeDegrees, longitudeDegrees);
}

// 3D Map:
// Create a coordinate structure for the point on the ground from which to view the location.
// Ask Map Kit for a camera that looks at the location from an altitude of n meters above that point.

- (void)setCameraToLookAtLocation:(CLLocationCoordinate2D)atLocation fromLocation:(CLLocationCoordinate2D)fromLocation andAltitudeInMeters:(CLLocationDistance)altitude {

    self.camera = [MKMapCamera cameraLookingAtCenterCoordinate:atLocation
                                                       fromEyeCoordinate:fromLocation
                                                             eyeAltitude:altitude];
}

// Region defines which part of world map we should show
// Map is centered around "location" and includes only "span" degrees of detail

- (void)setMapRegionToSpanLocation:(CLLocationCoordinate2D)location {

    MKCoordinateRegion region = MKCoordinateRegionMake(location, self.span);
    
    [self setRegion:region animated: YES];      // Applies the region to the map view (nothing is displayed yet?)
}


#pragma mark MKMapViewDelegate Protocol Methods:

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    NSLog(@"Location: %f, %f",
          userLocation.location.coordinate.latitude,
          userLocation.location.coordinate.longitude);
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 250, 250);
    
    // MKCoordinateRegionMakeWithDistance -> Center CLLocation coordinate, Latitude meters, Longitude meters
    
    // MKCoordinateRegion -> Struct with 2 parts: CLLocation coordinate and MKCoordinateSpan
    
    // MKCoordinateSpan -> Struct with 2 parts: Latitude in degrees (Latitude Delta) and Longitude in degrees (Longitude Delta)
    
    // Latitude Delta: The amount of north-to-south distance (measured in degrees) to display on the map. Unlike longitudinal distances, which vary based on the latitude, one degree of latitude is always approximately 111 kilometers (69 miles).
    
    // Longitude Delta: The amount of east-to-west distance (measured in degrees) to display for the map region. The number of kilometers spanned by a longitude range varies based on the current latitude. For example, one degree of longitude spans a distance of approximately 111 kilometers (69 miles) at the equator but shrinks to 0 kilometers at the poles.
    
    [self setRegion:region animated:YES];   // Changes currently visible region of map
}

- (void)mapViewWillStartLocatingUser:(MKMapView *)mapView {
    if (MYDEBUG) { NSLog(@"Now in: mapViewWillStartLocatingUser"); }
}

- (void)mapViewWillStopLocatingUser:(MKMapView *)mapView {
    if (MYDEBUG) { NSLog(@"Now in: mapViewWillStopLocatingUser"); }
}

- (void)mapViewDidStopLocatingUser:(MKMapView *)mapView {
    if (MYDEBUG) { NSLog(@"Now in: mapViewDidStopLocatingUser"); }
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    if (MYDEBUG) { NSLog(@"Now in: mapView:didFailToLocateUserWithError"); }
}

- (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated {
    if (MYDEBUG) { NSLog(@"Now in: mapView:didChangeUserTrackingMode") }
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    if (MYDEBUG) { NSLog(@"Now in: mapView:regionWillChangeAnimated"); }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if (MYDEBUG) { NSLog(@"Now in: mapView:regionDidChangeAnimated"); }
}

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView {
    if (MYDEBUG) { NSLog(@"Now in: mapViewWillStartLoadingMap"); }
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
    if (MYDEBUG) { NSLog(@"Now in: mapViewDidFinishLoadingMap"); }
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error {
    if (MYDEBUG) { NSLog(@"Now in: mapViewDidFailLoadingMap"); }
}

- (void)mapViewWillStartRenderingMap:(MKMapView *)mapView {
    if (MYDEBUG) { NSLog(@"Now in: mapViewWillStartRenderingMap"); }
}

- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered {
    if (MYDEBUG) { NSLog(@"Now in: mapViewDidFinishRenderingMap"); }
}


#pragma mark MKAnnotation Protocol Methods:

// mapView:viewForAnnotation: provides the view for each annotation.
// This method may be called for all or some of the added annotations.
// For MapKit provided annotations (eg. MKUserLocation) return nil to use the MapKit provided annotation view.
// Provides a custom image instead of the standard red pins

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    if (MYDEBUG) { NSLog(@"Now in: mapViewViewForAnnotation"); }
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {    // return nil so map view draws glowing "blue dot" for user's current location
        NSLog(@"MKUserLocation");
        return nil;
    }
    
    NSString *reuseID = annotation.title;
    
    MKPinAnnotationView *pinAnnotationView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseID];
    
    if ([reuseID isEqualToString:@"Turn To Tech"]) {
        if(!pinAnnotationView){
            pinAnnotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseID];
            pinAnnotationView.image = [UIImage imageNamed:@"TTTLogo.png"];    // replaces pin image with TTT logo image
            pinAnnotationView.pinColor = MKPinAnnotationColorGreen;
            pinAnnotationView.animatesDrop = YES;
            pinAnnotationView.draggable = NO;
            pinAnnotationView.enabled = YES;
            pinAnnotationView.canShowCallout = YES;
            
            // Add image to the left callout.
            UIImage *icon = [UIImage imageNamed:@"TTTLogo.png"];
            UIImage *resizedIcon = [MyUtil imageWithImage:icon scaledToSize:CGSizeMake((icon.size.width/2.0),(icon.size.height/2.0))];
            UIImageView *iconView = [[UIImageView alloc] initWithImage:resizedIcon];
            pinAnnotationView.leftCalloutAccessoryView = iconView;
            
            // Add disclosure button to the right callout.
            UIButton *disclosureButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            pinAnnotationView.rightCalloutAccessoryView = disclosureButton;
            
        } else {
            pinAnnotationView.annotation = annotation;
        }
        return pinAnnotationView;
        
    } else if ([reuseID isEqualToString:@"Draggable Pin"]) {
            if(!pinAnnotationView){
                pinAnnotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseID];
                pinAnnotationView.pinColor = MKPinAnnotationColorRed;
                pinAnnotationView.animatesDrop = NO;
                pinAnnotationView.draggable = YES;
                pinAnnotationView.enabled = YES;
                pinAnnotationView.canShowCallout = YES;
            } else {
                pinAnnotationView.annotation = annotation;
            }
            return pinAnnotationView;

    }
    return nil;
}

// mapView:didAddAnnotationViews: is called after the annotation views have been added and positioned in the map.
// The delegate can implement this method to animate the adding of the annotation views.
// Use the current positions of the annotation views as the destinations of the animation.

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    if (MYDEBUG) { NSLog(@"Now in: mapView:didAddAnnotationViews"); }
}

// mapView:annotationView:calloutAccessoryControlTapped: is called when the user taps on left & right callout accessory UIControls.

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    if (MYDEBUG) { NSLog(@"Now in: mapView:annotationView:calloutAccessoryControlTapped"); }
    
    SWSWebViewController *webViewController = [[SWSWebViewController alloc] init];
    webViewController.url = [NSURL URLWithString:@"http://turntotech.io"];
        
    UIPopoverController *popOverController = [[UIPopoverController alloc] initWithContentViewController:webViewController];
    popOverController.delegate = self;
    double offset = 15.0;
    CGRect popOverRect = CGRectMake(self.frame.origin.x + offset,
                                    self.frame.origin.y + offset,
                                    self.frame.size.width - (2*offset),
                                    self.frame.size.height - (2*offset));
    [popOverController presentPopoverFromRect:popOverRect inView:self permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
//    [popOverController setPopoverContentSize:CGSizeMake(600.0, 1200.0)];    // max width = 600.0
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if (MYDEBUG) { NSLog(@"Now in: mapView:didSelectAnnotationView"); }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    if (MYDEBUG) { NSLog(@"Now in: mapView:didDeselectAnnotationView"); }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    if (MYDEBUG) { NSLog(@"Now in: mapView:annotationView:didChangeDragState:fromOldState"); }
}

// This method is required for the MKAnnotation Protocol

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    self.coordinate = newCoordinate;    // new center point for an annotation
}

#pragma mark UIPopOverController Delegate methods

// Called on delegate when popover controller will dismiss the popover. Return NO to prevent the dismissal of the view.
- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
    return YES;
}
     
- (void)setPopoverContentSize:(CGSize)popoverContentSize {
    self.popoverContentSize = popoverContentSize;
}

@end
