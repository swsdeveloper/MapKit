//
//  SWSWebViewController.m
//  MapKit
//
//  Created by Steven Shatz on 1/22/15.
//  Copyright (c) 2015 Steven Shatz. All rights reserved.
//

#import "SWSWebViewController.h"
#import "Constants.h"

@implementation SWSWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    _webView.delegate = self;
    _webView.scalesPageToFit = YES;
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview: _webView];
    NSLog(@"_webView did load");
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"in web viewWillAppear");
    [super viewWillAppear:animated];
    [self loadRequestFromURL:self.url];
    NSLog(@"_webView will appear");
}

- (void)viewDidDisappear:(BOOL)animated{
    NSLog(@"in web viewDidDisappear");
    [_webView stopLoading];
    NSURL *url = [NSURL URLWithString:@"about:blank"];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)loadRequestFromURL:(NSURL*)url {
    NSLog(@"in web loadRequestFromURL: %@", url);
    self.urlRequest = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:self.urlRequest];
}


#pragma mark - UIWebView Delegate methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"in web shouldStartLoadWithRequest");
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"in web webViewDidStartLoad");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"in web webViewDidFinishLoad");
    [webView stopLoading];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"in web didFailLoadWithError: %@", [error description]);
    [webView stopLoading];
}

@end
