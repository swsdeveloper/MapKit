//
//  WKWebView+SWSWKWebView.h
//  MapKit
//
//  Created by Steven Shatz on 2/16/15.
//  Copyright (c) 2015 Steven Shatz. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "SWSWebViewProvider.h"

@interface WKWebView (SWSWKWebView) <SWSWebViewProvider>

- (void) setDelegateViews: (id <WKNavigationDelegate, WKUIDelegate>) delegateView;

@end
