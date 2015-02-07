//
//  SWSWebViewController.h
//  MapKit
//
//  Created by Steven Shatz on 1/22/15.
//  Copyright (c) 2015 Steven Shatz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWSWebViewController : UIViewController <UIWebViewDelegate>

@property (assign, nonatomic) BOOL shouldHideStatusBar;

@property (strong, nonatomic) NSArray *toolBarArray;

@property (strong, nonatomic) UIButton *exitButton;

@property (strong, nonatomic) UIButton *backButton;

@property (strong, nonatomic) UIButton *forwardButton;

@property (strong, nonatomic) UIButton *reloadButton;

@property (retain, nonatomic) UIWebView *webView;

@property (retain, nonatomic) NSURL *url;

@property (retain, nonatomic) NSURLRequest *urlRequest;

@end
