//
//  SWSWebViewProvider.h
//  MapKit
//
//  Created by Steven Shatz on 2/16/15.
//  Copyright (c) 2015 Steven Shatz. All rights reserved.
//

// Based on: http://floatlearning.com/2014/12/one-webview-to-rule-them-all/



#import <Foundation/Foundation.h>


@protocol SWSWebViewProvider <NSObject>

@property (nonatomic, strong) NSURLRequest *request;

@property (nonatomic, strong) NSURL *URL;

@property (nonatomic, readonly, getter=isLoading) BOOL loading;

@property (nonatomic, readonly) UIScrollView *scrollView;

- (void)loadRequest:(NSURLRequest *)request;

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler;

- (void)setDelegateViews:(id)delegateView;

- (void)stopLoading;
- (void)reload;
- (void)goBack;
- (void)goForward;

@end