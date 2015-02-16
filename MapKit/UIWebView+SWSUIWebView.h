//
//  UIWebView+SWSUIWebView.h
//  MapKit
//
//  Created by Steven Shatz on 2/16/15.
//  Copyright (c) 2015 Steven Shatz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWSWebViewProvider.h"

@interface UIWebView (SWSUIWebView) <SWSWebViewProvider>

- (void)setDelegateViews:(id <UIWebViewDelegate>)delegateView;

@end
