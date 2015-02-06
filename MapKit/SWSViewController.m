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
#import "SWSAnnotationWithImage.h"
#import "NSObject+BVJSONStringCategory.h"
#import "SWSPlace.h"
#import "MyUtil.h"


#define kGooglePlacesAPIKey @"AIzaSyB2FW3RI3z8JGuH1xLnJDO07CVnXGpm1mg"


// To Do:
// - Move text field to be above keyboard
// - Add method to dismiss keyboard
// - Show alert if no hits
// - Cache results of Icon and URL lookups - to prevent unneeded asynch searches


@interface SWSViewController ()

@end

@implementation SWSViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // There is no button that hides the keyboard, so instead we allow the user
    // to tap anywhere else in the view to hide the keyboard.
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:gestureRecognizer];
    
    // Hide Status Bar
    
    self.shouldHideStatusBar = YES;
    [self prefersStatusBarHidden];
    [self setNeedsStatusBarAppearanceUpdate];
    
    // Add Search Bar
    
    CGFloat viewWidth = self.navigationController.toolbar.frame.size.width;
    CGFloat viewHeight = self.navigationController.toolbar.frame.size.height;
    CGFloat barWidth = viewWidth;
    CGFloat barHeight = viewHeight;
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, barWidth, barHeight)];
    self.searchBar.delegate = self;
    [self.navigationController.view addSubview:self.searchBar];
    
    // Create location manager and start tracking user's current location

    self.swsLocationManager = [[SWSLocationManager alloc] initWithAccuracy:kCLLocationAccuracyBest];
    
    self.map = [[SWSMap alloc] initForViewController:self];
    
    [self.view addSubview:self.map];
    [self.view sendSubviewToBack:self.map];
    
    [self.map setMapDefaults];
    
    self.map.mapType = MKMapTypeStandard;                       // Start in Standard view (as opposed to MKMapTypeSatellite or MKMapTypeHybrid)
    
    [self.map setMapSpanToLatitude:0.04 andLongitude:0.04];     // Zoom in fairly close (only show 0.04 degrees of full map area)
    
    // Turn To Tech Annotation
    
    CLLocationCoordinate2D turnToTechLocation = [self.swsLocationManager setLocationAtLatitude:40.741448
                                                                               andLongitude:-73.989969];
    
    // For testing, set simulator's current location to: 40.7415, -73.989
    
    CLLocationCoordinate2D cameraLocation = [self.swsLocationManager setLocationAtLatitude:turnToTechLocation.latitude - 0.05
                                                                              andLongitude:turnToTechLocation.longitude - 0.05];   // set for Satellite view
    
    [self.map setCameraToLookAtLocation:turnToTechLocation fromLocation:cameraLocation andAltitudeInMeters:100.0];

    [self.map setMapRegionToSpanLocation:turnToTechLocation];   // Center map around Turn To Tech
    
    self.turnToTechAnnotation = [[MKPointAnnotation alloc] init];
    self.turnToTechAnnotation.coordinate = turnToTechLocation;
    self.turnToTechAnnotation.title = @"Turn To Tech";
    self.turnToTechAnnotation.subtitle = @"184 Fifth Avenue, 4th Floor";
    
    [self.map addAnnotation:self.turnToTechAnnotation];
    
    // Draggable Annotation
    
    CLLocationCoordinate2D draggableLocation = [self.swsLocationManager setLocationAtLatitude:40.742000
                                                                                 andLongitude:-73.99000];
    
    self.draggableAnnotation = [[MKPointAnnotation alloc] init];
    self.draggableAnnotation.coordinate = draggableLocation;
    self.draggableAnnotation.title = @"Draggable Pin";
    self.draggableAnnotation.subtitle = @"";
    
    [self.map addAnnotation:self.draggableAnnotation];
    
    self.map.droppedAt = self.draggableAnnotation.coordinate;
    
    // Placemarks
    
    //[self dropSamplePlacemarks];
}

- (void)viewWillAppear:(BOOL)animated {
    self.searchBar.hidden = NO;
}

- (void)hideKeyboard:(UIGestureRecognizer *)gestureRecognizer {
    [self.searchBar resignFirstResponder];
}

- (void)dropSamplePlacemarks {
    
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


#pragma mark - Google Place Search


// Google Places Search - find up to 20 nearby places (based on current user location)

- (void)googlePlaceSearch {
    
    // Remove all preveious Google Places annotations (if any)
    
    for (MKPointAnnotation *annotation in self.map.annotations) {
        if ([annotation isKindOfClass:[SWSAnnotationWithImage class]]) {
            [self.map removeAnnotation:annotation];
        }
    }
    
    // Clear places array - build it if neccessary
    
    if (!self.placesArray) {
        self.placesArray = [[NSMutableArray alloc] init];
    }
    
    [self.placesArray removeAllObjects];
    
    // Get user-entered search string
    
    NSString *searchString = [[self.searchBar text] lowercaseString];
    NSString *trimmedSearchString = [searchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // Set up the Google Places search
    
    CLLocationCoordinate2D currentUserLocation = [self.swsLocationManager getUsersCurrentLocation];
    
    NSLog(@"Current User Loc - lat: %f, long: %f", currentUserLocation.latitude, currentUserLocation.longitude);
    
    // Ex: .../nearbysearch/json?location=-33.8670522,151.1957362&radius=500&types=food&name=cruise&key=AddYourOwnKeyHere
    
    NSString *googlePlacesURL = @"https://maps.googleapis.com/maps/api/place/";
    NSString *searchType = @"nearbysearch/";
    NSString *outputType = @"json?";
    NSString *searchRange = [NSString stringWithFormat:@"location=%f,%f&radius=500",  // &types=food
                           currentUserLocation.latitude,
                           currentUserLocation.longitude];
    NSString *searchFor = [NSString stringWithFormat:@"&name=%@",trimmedSearchString];
    
    NSString *query = [[NSString alloc] initWithFormat:@"%@%@%@%@%@&key=%@", googlePlacesURL, searchType, outputType, searchRange, searchFor, kGooglePlacesAPIKey];
    
    NSLog(@"query:%@", query);
    
    NSURL *url = [NSURL URLWithString:query];
    
    if (url) {
        NSLog(@"Places URL: %@\n", [url description]);
        
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        // timeout after 1 minute
        
        NSLog(@"Request: %@\n", [request description]);
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   if (error) {
                                       NSLog(@"Google Places Query Error: %@", [error localizedDescription]);
                                   } else {
                                       [self processGooglePlaceSearchResults:data];
                                   }
                               }];
    }
}

- (void)processGooglePlaceSearchResults:(NSData *)jsonData {
    NSLog(@"In processGooglePlaceSearchResults");
    
//    if (MYDEBUG) {
//        NSString *dataAsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//        NSLog(@"\n%@\n", dataAsString);
//    }

    NSDictionary *dict = [self jsonToDictionary:jsonData];

    if (!dict) {
        NSLog(@"\n*** Could not convert JSON data to Dictionary ***");
        return;
    }
    
    if (![NSJSONSerialization isValidJSONObject:dict]) {
        NSLog(@"*** Cannot interpret result - Not a valid JSON Object ***");
        return;
    }
    
    id resultObject1 = nil;  // This is effectively just a pointer
    
    // Top JSON level
    
    resultObject1 = [dict valueForKey:@"status"];
    
    if (![resultObject1 isKindOfClass:[NSString class]]) {
        NSLog(@"*** ValueForKey:@\"status\" is not a string - give up ***");  // This will happen if resultObject1 is nil or an unexpected type
        return;
    }
    if (![resultObject1 isEqualToString:@"OK"]) {
        NSLog(@"*** Status of Google Places Search is: %@ - give up ***", (NSString *)resultObject1);
        return;
    }
    
    // Status is OK - continue at Top JSON level
    
    resultObject1 = [dict valueForKey:@"results"];  // we get a "results" array from a Places search
    if (resultObject1) {
        if (![resultObject1 isKindOfClass:[NSArray class]]) {
            NSLog(@"*** ValueForKey:@\"results\" is not an array - give up ***");
            return;
        }
        if ([resultObject1 count] < 1) {
            NSLog(@"*** There were no results ***");
            return;
        }
        
        [self buildPlacesArrayFromResults:resultObject1];
    }
}

- (void)buildPlacesArrayFromResults:(NSArray *)results {    // Array is cleared when Google Places search starts (see above)
    
    NSLog(@"GooglePlacesQuery buildArrayFromResults");
    
    /* ***********************************************************************************************************************************************************
       Output format - each array entry:
         {"latitude":double, "longitude":double, "name":NSString, "address":NSString, "pinIcon":NSURL, "placeID":NSString}
       ***********************************************************************************************************************************************************
       Sample Input:
        {
        "html_attributions" : [],
        "results" : [
                     {
                         "geometry" : {
                             "location" : {
                                 "lat" : -33.870775,
                                 "lng" : 151.199025
                             }
                         },
                         "icon" : "http://maps.gstatic.com/mapfiles/place_api/icons/travel_agent-71.png",
                         "id" : "21a0b251c9b8392186142c798263e289fe45b4aa",
                         "name" : "Rhythmboat Cruises",
                         "opening_hours" : {
                             "open_now" : true
                         },
                         "photos" : [
                                     {
                                         "height" : 270,
                                         "html_attributions" : [],
                                         "photo_reference" : "CnRnAAAAF-LjFR1ZV93eawe1cU_3QNMCNmaGkowY7CnOf-kcNmPhNnPEG9W979jOuJJ1sGr75rhD5hqKzjD8vbMbSsRnq_Ni3ZIGfY6hKWmsOf3qHKJInkm4h55lzvLAXJVc-Rr4kI9O1tmIblblUpg2oqoq8RIQRMQJhFsTr5s9haxQ07EQHxoUO0ICubVFGYfJiMUPor1GnIWb5i8",
                                         "width" : 519
                                     }
                                     ],
                         "place_id" : "ChIJyWEHuEmuEmsRm9hTkapTCrk",
                         "scope" : "GOOGLE",
                         "alt_ids" : [
                                      {
                                          "place_id" : "D9iJyWEHuEmuEmsRm9hTkapTCrk",
                                          "scope" : "APP"
                                      }
                                      ],
                         "reference" : "CoQBdQAAAFSiijw5-cAV68xdf2O18pKIZ0seJh03u9h9wk_lEdG-cP1dWvp_QGS4SNCBMk_fB06YRsfMrNkINtPez22p5lRIlj5ty_HmcNwcl6GZXbD2RdXsVfLYlQwnZQcnu7ihkjZp_2gk1-fWXql3GQ8-1BEGwgCxG-eaSnIJIBPuIpihEhAY1WYdxPvOWsPnb2-nGb6QGhTipN0lgaLpQTnkcMeAIEvCsSa0Ww",
                         "types" : [ "travel_agency", "restaurant", "food", "establishment" ],
                         "vicinity" : "Pyrmont Bay Wharf Darling Dr, Sydney"
                     },
                     {
                         "geometry" : {
                             "location" : {
                                 "lat" : -33.866891,
                                 "lng" : 151.200814
                             }
                         },
                         "icon" : "http://maps.gstatic.com/mapfiles/place_api/icons/restaurant-71.png",
                         "id" : "45a27fd8d56c56dc62afc9b49e1d850440d5c403",
                         "name" : "Private Charter Sydney Habour Cruise",
                         "photos" : [
                                     {
                                         "height" : 426,
                                         "html_attributions" : [],
                                         "photo_reference" : "CnRnAAAAL3n0Zu3U6fseyPl8URGKD49aGB2Wka7CKDZfamoGX2ZTLMBYgTUshjr-MXc0_O2BbvlUAZWtQTBHUVZ-5Sxb1-P-VX2Fx0sZF87q-9vUt19VDwQQmAX_mjQe7UWmU5lJGCOXSgxp2fu1b5VR_PF31RIQTKZLfqm8TA1eynnN4M1XShoU8adzJCcOWK0er14h8SqOIDZctvU",
                                         "width" : 640
                                     }
                                     ],
                         "place_id" : "ChIJqwS6fjiuEmsRJAMiOY9MSms",
                         "scope" : "GOOGLE",
                         "reference" : "CpQBhgAAAFN27qR_t5oSDKPUzjQIeQa3lrRpFTm5alW3ZYbMFm8k10ETbISfK9S1nwcJVfrP-bjra7NSPuhaRulxoonSPQklDyB-xGvcJncq6qDXIUQ3hlI-bx4AxYckAOX74LkupHq7bcaREgrSBE-U6GbA1C3U7I-HnweO4IPtztSEcgW09y03v1hgHzL8xSDElmkQtRIQzLbyBfj3e0FhJzABXjM2QBoUE2EnL-DzWrzpgmMEulUBLGrtu2Y",
                         "types" : [ "restaurant", "food", "establishment" ],
                         "vicinity" : "Australia"
                     },
                    ],
        "status" : "OK"
    }
       ***********************************************************************************************************************************************************
       find key:"status" in jsonDict dictionary - if not OK - display alert with error message (and NSLog it); then return - done before we came here
       find key:"results" in jsonDict dictionary - returns an array of matching places (if there were 0 hits, status would be "ZERO_RESULTS") - done before we came here
       for each item in our results array:
          find key:"geometry"
                within the geometry dictionary, find key:"location"
                    within the location dictionary, find keys: "lat" and "lng" - save these as latitude and longitude (both floats)
                    These 2 keys are essential - without either, we could not place a pin on the map
          find key:"name" - save as name (optional)
          find key:vicinity" - save as address (optional)
          find key:icon" - save as pinIcon URL (optional)
       ***********************************************************************************************************************************************************
     */
    
    int itemCount = 0;
    
    for (id item in results) {
        
        ++itemCount;
//        NSLog(@"Item %d = %@", itemCount, item);
        
        id resultObject2 = nil;
        id resultObject3 = nil;
        id resultObject4A = nil;
        id resultObject4B = nil;
        
        CLLocationCoordinate2D placeCoord = {0.0,0.0};
        NSString *placeName = nil;
        NSString *placeAddr = nil;
        NSString *placeIconPath = nil;
        NSString *placeID = nil;
        
        BOOL doneWithThisItem = NO;
        
        // 2nd JSON level
        resultObject2 = [item valueForKey:@"geometry"];
        if (![resultObject2 isKindOfClass:[NSDictionary class]]) {
            NSLog(@"*** ValueForKey:@\"results:geometry\" is not a Dictionary - ignore this item ***");
            doneWithThisItem = YES;
        }
        if (!doneWithThisItem) {
            // 3rd JSON level
            resultObject3 = [resultObject2 valueForKey:@"location"];
            if (![resultObject3 isKindOfClass:[NSDictionary class]]) {
                NSLog(@"*** ValueForKey:@\"results:geometry:location\" is not a Dictionary - ignore this item ***");
                doneWithThisItem = YES;
            }
            if (!doneWithThisItem) {
                // 4th JSON level
                resultObject4A = [resultObject3 valueForKey:@"lat"];
                resultObject4B = [resultObject3 valueForKey:@"lng"];
                if (![resultObject4A isKindOfClass:[NSNumber class]]) {
                    NSLog(@"*** ValueForKey:@\"results:geometry:location:lat\" is not a Number - ignore this item ***");
                    resultObject4A = nil;
                }
                if (![resultObject4B isKindOfClass:[NSNumber class]]) {
                    NSLog(@"*** ValueForKey:@\"results:geometry:location:lng\" is not a Number - ignore this item ***");
                    resultObject4B = nil;
                }
                if (resultObject4A && resultObject4B) {
                    placeCoord = CLLocationCoordinate2DMake([resultObject4A doubleValue], [resultObject4B doubleValue]);
                } else {
                    doneWithThisItem = YES;
                }
            } // exit 4th JSON level
        } // exit 3rd JSON level
        // Back at 2nd JSON level
        
        if (!doneWithThisItem) {                                    // continue only if a location was found
            resultObject2 = [item valueForKey:@"name"];
            if (![resultObject2 isKindOfClass:[NSString class]]) {
                NSLog(@"*** ValueForKey:@\"results:name\" is not a String - unknown name ***");
                placeName = @"Unknown Name";
            } else {
                placeName = [NSString stringWithString:resultObject2];
            }
            resultObject2 = [item valueForKey:@"vicinity"];
            if (![resultObject2 isKindOfClass:[NSString class]]) {
                NSLog(@"*** ValueForKey:@\"results:vicinity\" is not a String - unknown address ***");
                placeAddr = @"Unknown Address";
            } else {
                placeAddr = [NSString stringWithString:resultObject2];
            }
            resultObject2 = [item valueForKey:@"icon"];
            if (![resultObject2 isKindOfClass:[NSString class]]) {
                NSLog(@"*** ValueForKey:@\"results:icon\" is not a String - no icon ***");
                placeIconPath = nil;
            } else {
                //NSURL *placeIconURL = [NSURL URLWithString:resultObject2];
                //placeIcon = [UIImage imageWithData:[NSData dataWithContentsOfURL:placeIconURL]];  // make asynch
                placeIconPath = [NSString stringWithString:resultObject2];
            }
            resultObject2 = [item valueForKey:@"place_id"];
            if (![resultObject2 isKindOfClass:[NSString class]]) {
                NSLog(@"*** ValueForKey:@\"results:place_id\" is not a String - no placeID, so no details ***");
                placeID = nil;
            } else {
                placeID = [NSString stringWithString:resultObject2];
            }
            
            NSURL *placeUrl = nil;
            UIImage *placeIcon = nil;
            
            // Add this place to the places array
            
            SWSPlace *place = [[SWSPlace alloc] init];
            place.placeID = placeID;
            place.coord = placeCoord;
            place.name = placeName;
            place.addr = placeAddr;
            place.icon = placeIcon;
            place.url = placeUrl;
            
            [self.placesArray addObject:place];
            
            // Launch an asynchronous Icon search
            
            if (placeID && placeIconPath) {
                [self getIconFromPath:placeIconPath forPlaceID:placeID];
            }
            
            // Launch an asynchronous Place Detail search
            
            if (placeID) {
                [self googlePlaceDetailsSearch:placeID];
            }
            
            // Create annotation for this place and add it to the map
            
            SWSAnnotationWithImage *placeAnnotation = [[SWSAnnotationWithImage alloc] init];
            placeAnnotation.placeID = placeID;
            placeAnnotation.coordinate = placeCoord;
            placeAnnotation.title = placeName;
            placeAnnotation.subtitle = placeAddr;
            placeAnnotation.placeIcon = placeIcon;
            placeAnnotation.placeUrl = placeUrl;
            
            [self.map addAnnotation:placeAnnotation];
            
            NSLog(@" *** Annotation added to map at %f, %f ***",
                  placeAnnotation.coordinate.latitude,
                  placeAnnotation.coordinate.longitude);
        }
    } // end of For Loop
}

#pragma mark - Place Icon Lookup

- (void)getIconFromPath:(NSString *)iconPath forPlaceID:(NSString *)placeID {
    if (MYDEBUG) { NSLog(@"\nIn getIconFromPath:forPlaceID:\n"); }
    NSURL *url = [NSURL URLWithString:iconPath];
    if (url) {
        NSLog(@"Place Icon URL: %@\n", [url description]);
        
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10000.0];
        // timeout after 15 seconds
        
        NSLog(@"Icon Request: %@\n", [request description]);
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   if (error) {
                                       NSLog(@"Place Icon Fetch Error: %@", [error localizedDescription]);
                                   } else {
                                       UIImage *image = [UIImage imageWithData:data];   // will be nil, if not an image
                                       if (image) {
                                           [self updatePlaceIcon:image forID:placeID];
                                       } else {
                                           NSLog(@"Not an Image At Path Error: %@", iconPath);
                                       }
                                   }
                               }];
    }
}

- (void)updatePlaceIcon:(UIImage *)placeIcon forID:(NSString *)placeID {
    if (MYDEBUG) { NSLog(@"In updatePlacesArrayIcon:forID:%@",placeID); }
    int count = (int)[self.placesArray count];
    for (int i=0; i < count; i++) {
        SWSPlace *place = self.placesArray[i];
        if ([place.placeID isEqualToString:placeID]) {
            if (placeIcon) {
                place.icon = placeIcon;
                [self.placesArray replaceObjectAtIndex:i withObject:place];
                NSLog(@"self.placesArray.place.icon[%d] = %@", i, [place.icon description]);
                [self updateAnnotationForPlaceAtIndex:i];
            }
            break;
        }
    }
}

- (void)updateAnnotationForPlaceAtIndex:(int)index {
    NSLog(@"In updateAnnotationForPlaceAtIndex:%d",index);
   
    SWSAnnotationWithImage *swsAnnotationWithImage = nil;

    SWSPlace *place = self.placesArray[index];
    
    NSLog(@"place.placeID=%@",place.placeID);

    int count = (int)[[self.map annotations] count];
    for (int i=0; i<count; ++i) {
        NSLog(@"index:%d of %d",i, count);
        id annotation = self.map.annotations[i];
        if ([annotation isKindOfClass:[SWSAnnotationWithImage class]]) {
            
            swsAnnotationWithImage = (SWSAnnotationWithImage *)annotation;
            
            MKPinAnnotationView *pinAnnotationView = (MKPinAnnotationView *)[self.map viewForAnnotation:annotation];
            
            if ([place.placeID isEqualToString:swsAnnotationWithImage.placeID]) {
                NSLog(@"placeID match");
                if (place.icon) {
                    UIImage *icon = place.icon;
                    UIImage *resizedIcon = [MyUtil imageWithImage:icon scaledToSize:CGSizeMake((icon.size.width/2.0),(icon.size.height/2.0))];
                    UIImageView *iconView = [[UIImageView alloc] initWithImage:resizedIcon];
                
                    pinAnnotationView.leftCalloutAccessoryView = iconView;
                    pinAnnotationView.leftCalloutAccessoryView.tag = 4;
                } else {
                    NSLog(@"No place.icon");
                }
                
                if (place.url) {
                    UIButton *disclosureButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
                    pinAnnotationView.rightCalloutAccessoryView = disclosureButton;
                    pinAnnotationView.rightCalloutAccessoryView.tag = 5;
                } else {
                    NSLog(@"No place.url");
                }
                
                if (place.icon || place.url) {
                    NSLog(@" *** Annotation replaced at %f, %f ***",
                          pinAnnotationView.annotation.coordinate.latitude,
                          pinAnnotationView.annotation.coordinate.longitude);
                }
                break;
            } else {
                NSLog(@"PlaceID does not match - check next annotation");
            }
        } else {
            NSLog(@"annotation is class:%@",[[annotation class] description]);
        }
    }
}


#pragma mark - Google Place Detail Search

- (void)googlePlaceDetailsSearch:(NSString *)placeID {
    NSLog(@"In googlePlaceDetailsSearch:");
    
    NSString *googlePlacesURL = @"https://maps.googleapis.com/maps/api/place/";
    NSString *searchType = @"details/";
    NSString *outputType = @"json?";
    NSString *searchFor = [NSString stringWithFormat:@"placeid=%@", placeID];
    
    NSString *query = [[NSString alloc] initWithFormat:@"%@%@%@%@&key=%@", googlePlacesURL, searchType, outputType, searchFor, kGooglePlacesAPIKey];
    
    NSURL *url = [NSURL URLWithString:query];
    
    if (url) {
        NSLog(@"Place Detail URL: %@\n", [url description]);
        
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        // timeout after 1 minute
        
        NSLog(@"URL Request: %@\n", [request description]);
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   if (error) {
                                       NSLog(@"Google Place Detail Query Error: %@", [error localizedDescription]);
                                   } else {
                                       [self processGooglePlaceDetailSearchResults:data forID:placeID];  // update array even if placeUrl is nil
                                   }
                               }];
    }
}

- (void)processGooglePlaceDetailSearchResults:(NSData *)jsonData forID:(NSString *)placeID {
    NSLog(@"In processGooglePlaceDetailSearchResults:forID:");
    
//    if (MYDEBUG) {
//        NSString *dataAsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//        NSLog(@"\n%@\n", dataAsString);
//    }
    
    NSDictionary *dict = [self jsonToDictionary:jsonData];
    if (!dict) {
        NSLog(@"\n*** Could not convert JSON data to Dictionary ***");
        return;
    }
    if (![NSJSONSerialization isValidJSONObject:dict]) {
        NSLog(@"*** Cannot interpret result - Not a valid JSON Object ***");
        return;
    }
    
    id result = nil;
    
    result = [dict valueForKey:@"status"];
    if (![result isKindOfClass:[NSString class]]) {
        NSLog(@"*** ValueForKey:@\"status\" is not a string - give up ***");
        return;
    }
    if (![result isEqualToString:@"OK"]) {
        NSLog(@"*** Status of Google Place Detail Search is: %@ - give up ***", (NSString *)result);
        return;
    }
    
    // Status is OK - continue at Top JSON level
    
    result = [dict valueForKey:@"result"];    // we get a "result" dictionary from a Place Detail search
    if (![result isKindOfClass:[NSDictionary class]]) {
        NSLog(@"*** ValueForKey:@\"result\" is not a dictionary - give up ***");
        return;
    }
    
    id placeUrl = nil;
    
    placeUrl = [result valueForKey:@"website"];   // official website
    if (![placeUrl isKindOfClass:[NSString class]]) {
        NSLog(@"*** ValueForKey:@\"result:website\" is not a String - website is unknown - check for url ***");
        placeUrl = nil;
    } else {
        NSLog(@"website: %@", placeUrl);
    }
    
    if (!placeUrl) {
        placeUrl = [dict valueForKey:@"url"];       // Google's main url for this place
        if (![placeUrl isKindOfClass:[NSString class]]) {
            NSLog(@"*** ValueForKey:@\"result:url\" is not a String - url is unknown ***");
        } else {
            NSLog(@"url: %@", placeUrl);
        }
    }
    
    NSLog(@"placeUrl: %@", placeUrl);
    
    [self updatePlaceURL:placeUrl forID:placeID];  // update array even if placeUrl is nil
}

- (void)updatePlaceURL:(NSString *)placeURL forID:(NSString *)placeID {
    if (MYDEBUG) { NSLog(@"\nIn updatePlacesArrayURL:forID:\n"); }
    int count = (int)[self.placesArray count];
    for (int i=0; i < count; i++) {
        SWSPlace *place = self.placesArray[i];
        if ([place.placeID isEqualToString:placeID]) {
            if (placeURL) {
                place.url = [NSURL URLWithString:placeURL];
                [self.placesArray replaceObjectAtIndex:i withObject:place];
                [self updateAnnotationForPlaceAtIndex:i];
            }
            break;
        }
    }
}


- (void)didReceiveMemoryWarning {
    NSLog(@"\nIn didReceiveMemoryWarning\n");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - IBAction methods

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

- (IBAction)setTransportationType:(id)sender {
    switch (((UISegmentedControl *)sender).selectedSegmentIndex) {
        case 0:
            self.map.transportType = MKDirectionsTransportTypeAutomobile;
            break;
        case 1:
            self.map.transportType = MKDirectionsTransportTypeWalking;
            break;
        default:
            break;
    }
    [self.map showRouteTo:self.map.draggablePinMapItem];
}

- (IBAction)searchButtonClicked {
    if (MYDEBUG) { NSLog(@"\nIn searchButtonClicked"); }
    
    // Before doing Google Search, clear any route that may be showing
    
    for (id<MKOverlay> overlayToRemove in self.map.overlays) {
        if ([overlayToRemove isKindOfClass:[MKPolyline class]]) {
            [self.map removeOverlay:overlayToRemove];
        }
    }
    
    // Dismiss keyboard
    
    [self.searchBar resignFirstResponder];
    
    // Google Places Search - find up to 20 nearby Starbucks (based on current user location)
    
    [self googlePlaceSearch];
}


#pragma mark - NSURLConnection Delegate methods

// ******************************************************
// * NSURLConnectionDelegate Methods - all are optional *
// ******************************************************

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse object.
    
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    
    if (MYDEBUG) { NSLog(@"\nGooglePlacesQuery connection:didReceiveResponse:\n%@", response); }
    
    [self.dataReceived setLength:0];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    NSLog(@"\n***GooglePlacesQuery connection:didFailWithError: ***");
    
    self.dataReceived = nil;
    
    NSLog(@"\nConnection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    if (MYDEBUG) {
        //NSString *aString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"\nGooglePlacesQuery connection:didReceiveData: ... \n");
    }
    
    if (self.dataReceived) {
        [self.dataReceived appendData:data];
    } else {
        NSMutableData *newData = [[NSMutableData alloc] initWithData:data];
        self.dataReceived = newData;
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"\nGooglePlacesQuery ConnectionDidFinishLoading:");
    
    //    if (MYDEBUG) {
    //        NSString *dataAsString = [[NSString alloc] initWithData:self.dataReceived encoding:NSUTF8StringEncoding];
    //        NSLog(@"\n%@\n", dataAsString);
    //    }
    
    NSLog(@"Succeeded! Received %ld bytes of data",(unsigned long)[self.dataReceived length]);
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {                    // called when keyboard search button pressed
    [self searchButtonClicked];
}

# pragma mark - Status Bar method

- (BOOL)prefersStatusBarHidden {
    return self.shouldHideStatusBar;
}

@end
