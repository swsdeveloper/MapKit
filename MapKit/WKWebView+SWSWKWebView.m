//
//  WKWebView+SWSWKWebView.m
//  MapKit
//
//  Created by Steven Shatz on 2/16/15.
//  Copyright (c) 2015 Steven Shatz. All rights reserved.
//

#import "WKWebView+SWSWKWebView.h"
#import "Constants.h"
#import <objc/runtime.h>


@implementation WKWebView (SWSWebView)

- (void)setDelegateViews:(id <WKNavigationDelegate, WKUIDelegate>)delegateView {
    NSLog(@"%s",__FUNCTION__);
    [self setNavigationDelegate: delegateView];
    [self setUIDelegate: delegateView];
}

/*
We’re using the dreaded associated objects! NSHipster has a great discussion of these here: http://nshipster.com/associated-objects/
Essentially this is the only way to add custom properties in a category.
This allows us to treat the request property the same between UIWebView and WKWebView, even though the former has it and the latter does not.
However, the request property won’t be set for us when we call loadRequest.
In order for that to happen, we’ve got to swizzle (see NSHipster: http://nshipster.com/method-swizzling/)
Swizzling allows us to swap out a built-in function with our own.
We want to swap out the built-in WKWebView loadRequest with our own loadRequest method that will simply update the request property.
We want this done once, so we do it in the Load method (see: https://developer.apple.com/library/mac/documentation/Cocoa/Reference/ObjCRuntimeRef/index.html)
 
The end result of all of this is that WKWebView will now have a request property identical to the UIWebView request property.
*/

- (NSURLRequest *)request {
    NSLog(@"%s",__FUNCTION__);
    return objc_getAssociatedObject(self, @selector(request));
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

- (void)setRequest:(NSURLRequest *)request {
    NSLog(@"%s",__FUNCTION__);
    objc_setAssociatedObject(self, @selector(request), request, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// We create a token to ensure that this is only done once, then do the bulk of the work inside a block.
// After getting a reference to the current class, we create references to the selectors for the original method (loadRequest)
//  and our new method (altLoadRequest), and then get references to the methods themselves.
// We then attempt to add our new method in place of the original. Since class_addMethod returns a boolean value indicating success,
//  then we can store this result and, if successful, put the original method in place of our alternative. If we weren’t successful,
//  we use an alternative process to swap the two methods.
// This is some dangerous stuff we’re messing with, so take a look at the runtime reference if you want more information.

+ (void)load {
    NSLog(@"%s",__FUNCTION__);
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(loadRequest:);
        SEL swizzledSelector = @selector(altLoadRequest:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

// Sets the request property, and then calls altLoadRequest, which at runtime is actually the original loadRequest.
- (void)altLoadRequest:(NSURLRequest *)request {
    NSLog(@"%s",__FUNCTION__);
    
    [self setRequest: request];
    [self altLoadRequest: request];
}

@end
