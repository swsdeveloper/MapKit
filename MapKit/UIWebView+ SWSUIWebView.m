//
//  UIWebView+SWSUIWebView.m
//  MapKit
//
//  Created by Steven Shatz on 2/16/15.
//  Copyright (c) 2015 Steven Shatz. All rights reserved.
//

#import "UIWebView+SWSUIWebView.h"

@implementation UIWebView (SWSWebView)

- (void)setDelegateViews: (id <UIWebViewDelegate>) delegateView {
    NSLog(@"%s",__FUNCTION__);
    [self setDelegate:delegateView];
}

- (NSURL *)URL {
    NSLog(@"%s",__FUNCTION__);
    return [[self request] URL];
}

//- (BOOL)loading {
//    NSLog(@"%s",__FUNCTION__);
//    return [self loading];
//}
//
//- (UIScrollView *)scrollView {
//    NSLog(@"%s",__FUNCTION__);
//    return [self scrollView];
//}

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler {
    NSLog(@"%s",__FUNCTION__);
    
    NSString *string = [self stringByEvaluatingJavaScriptFromString: javaScriptString];
    
    if (completionHandler) {
        completionHandler(string, nil);
    }
}

@end

