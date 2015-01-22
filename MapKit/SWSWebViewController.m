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
    [self.view addSubview: _webView];
    
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"in web viewWillAppear");
    [super viewWillAppear:animated];
    [self loadRequestFromURL:self.url];
}

//- (void)viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:animated];
//}

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

//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}


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
