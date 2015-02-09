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
#import <AddressBook/AddressBook.h>
#import "SWSAnnotationWithImage.h"
#import "SWSViewController.h"
#import "SWSPlace.h"


@implementation SWSMap

- (id)initForViewController:(SWSViewController *)myViewController {
    self = [super init];
    if (self) {
        self = [[SWSMap alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _viewController = myViewController;
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
    if (MYDEBUG_MKMapViewDelegate) { NSLog(@"%s", __FUNCTION__); }

    NSLog(@"Mapview Updated User Location: %f, %f",
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
    if (MYDEBUG_MKMapViewDelegate) { NSLog(@"%s", __FUNCTION__); }
}

- (void)mapViewWillStopLocatingUser:(MKMapView *)mapView {
    if (MYDEBUG_MKMapViewDelegate) { NSLog(@"%s", __FUNCTION__); }
}

- (void)mapViewDidStopLocatingUser:(MKMapView *)mapView {
    if (MYDEBUG_MKMapViewDelegate) { NSLog(@"%s", __FUNCTION__); }
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    if (MYDEBUG_MKMapViewDelegate) { NSLog(@"%s", __FUNCTION__); }
}

- (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated {
    if (MYDEBUG_MKMapViewDelegate) { NSLog(@"%s", __FUNCTION__); }
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    if (MYDEBUG_MKMapViewDelegate) { NSLog(@"%s", __FUNCTION__); }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if (MYDEBUG_MKMapViewDelegate) { NSLog(@"%s", __FUNCTION__); }
}

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView {
    if (MYDEBUG_MKMapViewDelegate) { NSLog(@"%s", __FUNCTION__); }
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
    if (MYDEBUG_MKMapViewDelegate) { NSLog(@"%s", __FUNCTION__); }
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error {
    if (MYDEBUG_MKMapViewDelegate) { NSLog(@"%s", __FUNCTION__); }
}

- (void)mapViewWillStartRenderingMap:(MKMapView *)mapView {
    if (MYDEBUG_MKMapViewDelegate) { NSLog(@"%s", __FUNCTION__); }
}

- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered {
    if (MYDEBUG_MKMapViewDelegate) { NSLog(@"%s", __FUNCTION__); }
}


#pragma mark MKAnnotation Protocol Methods:

// mapView:viewForAnnotation: provides the view for each annotation.
// This method may be called for all or some of the added annotations.
// For MapKit provided annotations (eg. MKUserLocation) return nil to use the MapKit provided annotation view.
// Provides a custom image instead of the standard red pins

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    if (MYDEBUG) { NSLog(@"\n%s", __FUNCTION__); }
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {    // return nil so map view draws glowing "blue dot" for user's current location
        //NSLog(@"MKUserLocation");
        return nil;
    }
    
    NSString *reuseID = annotation.title;

    if ([annotation isKindOfClass:[SWSAnnotationWithImage class]]) {
        reuseID = @"Google Places Pin";
    }
    
    MKPinAnnotationView *pinAnnotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseID];
    
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
            UIButton *imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
            imageButton.frame = [iconView frame];
            [imageButton setImage:resizedIcon forState:UIControlStateNormal];
            pinAnnotationView.leftCalloutAccessoryView = imageButton;
            pinAnnotationView.leftCalloutAccessoryView.tag = 1;
            
            // Add disclosure button to the right callout.
            UIButton *disclosureButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            pinAnnotationView.rightCalloutAccessoryView = disclosureButton;
            pinAnnotationView.rightCalloutAccessoryView.tag = 2;
            
        } else {
            pinAnnotationView.annotation = annotation;
        }
        return pinAnnotationView;
        
    } else if ([reuseID isEqualToString:@"Draggable Pin"]) {
        if(!pinAnnotationView){
            pinAnnotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseID];
            pinAnnotationView.pinColor = MKPinAnnotationColorPurple;
            pinAnnotationView.animatesDrop = NO;
            pinAnnotationView.draggable = YES;
            pinAnnotationView.enabled = YES;
            pinAnnotationView.canShowCallout = YES;
            
            // Add disclosure button to the right callout.
            UIButton *disclosureButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            pinAnnotationView.rightCalloutAccessoryView = disclosureButton;
            pinAnnotationView.rightCalloutAccessoryView.tag = 3;
            
        } else {
            pinAnnotationView.annotation = annotation;
        }
        return pinAnnotationView;
        
    } else if ([reuseID isEqualToString:@"Google Places Pin"]) {
        if(!pinAnnotationView){
            pinAnnotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseID];
            pinAnnotationView.pinColor = MKPinAnnotationColorRed;
            pinAnnotationView.animatesDrop = YES;
            pinAnnotationView.draggable = NO;
            pinAnnotationView.enabled = YES;
            pinAnnotationView.canShowCallout = YES;
            
            // If annotation has image, add it as left callout.
            
            SWSAnnotationWithImage *annotationWithImage = annotation;   // MKPointAnnotation -> SWSAnnotationWithImage
            
            for (SWSPlace *place in self.viewController.placesArray) {
                //NSLog(@"SWSMAP place:%@, %@", place.name, place.addr);
                if ([place.placeID isEqualToString:annotationWithImage.placeID]) {
                    NSLog(@"SWSMAP place:%@, %@", place.name, place.addr);
                    if (place.icon) {
                        UIImage *icon = place.icon;
                        UIImageView *iconView = [[UIImageView alloc] initWithImage:icon];
                        UIButton *imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
                        imageButton.frame = [iconView frame];
                        [imageButton setImage:icon forState:UIControlStateNormal];
                        pinAnnotationView.leftCalloutAccessoryView = imageButton;
                        pinAnnotationView.leftCalloutAccessoryView.tag = 4;
                    }
                    break;
                }
            }
            
            // If annotation has url, add disclosure button as right callout. (Clicking it will open website)
            
            for (SWSPlace *place in self.viewController.placesArray) {
                if ([place.placeID isEqualToString:annotationWithImage.placeID]) {
                    NSLog(@"placeID:%@, url:%@", place.placeID, [place.url absoluteString]);
                    if (place.url) {
                        UIButton *disclosureButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
                        pinAnnotationView.rightCalloutAccessoryView = disclosureButton;
                        pinAnnotationView.rightCalloutAccessoryView.tag = 5;
                    }
                    break;
                }
            }
            
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
    if (MYDEBUG) { NSLog(@"\n%s", __FUNCTION__); }
}

// mapView:annotationView:calloutAccessoryControlTapped: is called when the user taps on left & right callout accessory UIControls.

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    //if (MYDEBUG) { NSLog(@"%s", __FUNCTION__); }
    
    if ([control tag] == 1) {
        NSLog(@"Left icon of TTT annotation tapped");
        
        BOOL wordFound = [UIReferenceLibraryViewController dictionaryHasDefinitionForTerm:@"tech"];
        wordFound = YES;
        if (wordFound) {
            UIReferenceLibraryViewController *referenceLibraryViewController = [[UIReferenceLibraryViewController alloc] initWithTerm:@"tech"];
            
            UIPopoverController *popOverController = [[UIPopoverController alloc] initWithContentViewController:referenceLibraryViewController];
            popOverController.delegate = self;
            double offset = 15.0;
            CGRect popOverRect = CGRectMake(self.frame.origin.x + offset,
                                            self.frame.origin.y + offset,
                                            self.frame.size.width - (2*offset),
                                            self.frame.size.height - (2*offset));
            [popOverController presentPopoverFromRect:popOverRect inView:self permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            
            //    [popOverController setPopoverContentSize:CGSizeMake(600.0, 1200.0)];    // max width = 600.0
            
        } else {
            NSLog(@"No defintion for \"tech\" (or no dictionary on this device)");
        }
        
    } else if ([control tag] == 2) {
        NSLog(@"Right button of TTT annotation tapped");
        
        NSURL *url = [NSURL URLWithString:@"http://turntotech.io"];
        [self launchWebView:url];
        
    } else if ([control tag] == 3 || [control tag] == 4) {
        if ([control tag] == 3) { NSLog(@"Right button of Draggable Pin annotation tapped"); }
        if ([control tag] == 4) { NSLog(@"Left icon of Google Places annotation tapped"); }
        
        id <MKAnnotation> annotation = view.annotation;
        
        NSDictionary *addressDict = @{(NSString*)kABPersonAddressStreetKey : annotation.subtitle};
        
        MKPlacemark *destinationPlacemark = [[MKPlacemark alloc]
                                            initWithCoordinate:annotation.coordinate
                                            addressDictionary:addressDict];
        
        self.destinationPin = [[MKMapItem alloc] initWithPlacemark:destinationPlacemark];
        self.destinationPin.name = annotation.title;
        
        // The next statements launch Apple's maps app to show directions between the Draggable Pin and the user's Current Location.
        // Unfortunately, there is no way for the user to navigate back to this app
        //
        // NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
        // [self.destinationPin openInMapsWithLaunchOptions:launchOptions];
        
        
        // Create a Direction Request - from current user location to destination pin location

        [self showRouteTo:self.destinationPin];
        
    } else if ([control tag] == 5) {
        NSLog(@"Right button of Google Places annotation tapped");
        
        SWSAnnotationWithImage *sws = view.annotation;          // MKPointAnnotation -> SWSAnnotationWithImage
        
        for (SWSPlace *place in self.viewController.placesArray) {
            if ([place.placeID isEqualToString:sws.placeID]) {
                NSLog(@"placeID:%@, addr:%@, url:%@", place.placeID, place.addr, place.url);
                if (place.url) {
                    [self launchWebView:place.url];
                }
                break;
            }
        }
    }
}

- (void)launchWebView:(NSURL *)url {
    // Hide View Controller's SearchBar before switching to web view
    self.viewController.searchBar.hidden = YES;
    
    SWSWebViewController *webViewController = [[SWSWebViewController alloc] init];
    webViewController.url = url;

    [[self.viewController navigationController] pushViewController:webViewController animated:YES];
}

- (void)showRouteTo:(MKMapItem *)destItem {
    if (MYDEBUG) { NSLog(@"%s Name=%@, Lat=%f, Long=%f", __FUNCTION__, destItem.name, destItem.placemark.coordinate.latitude, destItem.placemark.coordinate.longitude); }
    
    // Create a Direction Request - from current user location to current location of draggable pin
    // Before doing so, remove any polyline overlay that may have previously been shown
    
    for (id<MKOverlay> overlayToRemove in self.overlays) {
        if ([overlayToRemove isKindOfClass:[MKPolyline class]]) {
            [self removeOverlay:overlayToRemove];
        }
    }
    
    if (!self.transportType) {
        self.transportType = MKDirectionsTransportTypeAutomobile;
    }
    
    MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] init];
    [directionsRequest setSource:[MKMapItem mapItemForCurrentLocation]];
    [directionsRequest setDestination:destItem];
    [directionsRequest setTransportType:self.transportType];
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
    MKMapView *myMapView = self;    // Not wise to reference self inside a block
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (!error) {
            for (MKRoute *route in [response routes]) {
                [myMapView addOverlay:[route polyline] level:MKOverlayLevelAboveRoads]; // Draws the route above roads, but below labels.
                                                                                        // The |polyline| method returns the geometric route
            }
        }
    }];
}

// This next method is necessary for an overlay to be displayed

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if (MYDEBUG) { NSLog(@"%s", __FUNCTION__); }
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        [renderer setStrokeColor:[UIColor blueColor]];
        [renderer setLineWidth:5.0];
        return renderer;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if (MYDEBUG) { NSLog(@"\n%s", __FUNCTION__); }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    if (MYDEBUG) { NSLog(@"%s", __FUNCTION__); }
}

// This gets called as Draggable Pin gets dragged

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    if (MYDEBUG) { NSLog(@"%s", __FUNCTION__); }
    if (newState == MKAnnotationViewDragStateEnding) {
        self.droppedAt = view.annotation.coordinate;
        NSLog(@"Pin dropped at %f,%f", self.droppedAt.latitude, self.droppedAt.longitude);
        
        NSDictionary *addressDict = @{(NSString*)kABPersonAddressStreetKey : @""};
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:self.droppedAt addressDictionary:addressDict];
        self.destinationPin = [[MKMapItem alloc] initWithPlacemark:placemark];
        self.destinationPin.name = @"Draggable Pin";
        
        [self showRouteTo:self.destinationPin];
    }
    
// The following code degrades the ability to drag the pin:
//    if (newState == MKAnnotationViewDragStateStarting) {
//        view.dragState = MKAnnotationViewDragStateDragging;
//    } else if (newState == MKAnnotationViewDragStateEnding || newState == MKAnnotationViewDragStateCanceling) {
//        view.dragState = MKAnnotationViewDragStateNone;
//    }
    
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

- (CLLocationCoordinate2D)currentUserLocation {
    return self.userLocation.coordinate;
}


@end
