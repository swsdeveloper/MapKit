//
//  SWSWebViewController.h
//  MapKit
//
//  Created by Steven Shatz on 1/22/15.
//  Copyright (c) 2015 Steven Shatz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWSWebViewController : UIViewController <UIWebViewDelegate>  //, NSURLConnectionDataDelegate>

@property (assign, nonatomic) BOOL shouldHideStatusBar;

@property (strong, nonatomic) NSArray *toolBarArray;

// Custom Buttons

@property (strong, nonatomic) UIButton *exitButton;

@property (strong, nonatomic) UIButton *backButton;

@property (strong, nonatomic) UIButton *forwardButton;


@property (strong, nonatomic) IBOutlet UIWebView *webView;

@property (retain, nonatomic) NSURL *url;

@property (retain, nonatomic) NSURLRequest *urlRequest;


//@property (nonatomic) BOOL validatedRequest;
//
//@property (nonatomic, strong) NSURL *originalUrl;


@end
