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
    
    // Hide Status Bar
    
    self.shouldHideStatusBar = YES;
    [self prefersStatusBarHidden];
    [self setNeedsStatusBarAppearanceUpdate];
    
    // Add Exit, Back, Forward, Cancel, and Reload Buttons
    
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpace.width = 20;
    
    self.exitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.exitButton setImage:[UIImage imageNamed:@"exit.png"] forState:UIControlStateNormal];
    self.exitButton.frame = CGRectMake(0, 0, 42, 42);
    self.exitButton.showsTouchWhenHighlighted=YES;
    [self.exitButton addTarget:self action:@selector(exitButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *exitButton = [[UIBarButtonItem alloc] initWithCustomView:self.exitButton];
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backButton setImage:[UIImage imageNamed:@"goBack.png"] forState:UIControlStateNormal];
    self.backButton.frame = CGRectMake(0, 0, 42, 42);
    self.backButton.showsTouchWhenHighlighted=YES;
    [self.backButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:self.backButton];

    self.forwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.forwardButton setImage:[UIImage imageNamed:@"forward.png"] forState:UIControlStateNormal];
    self.forwardButton.frame = CGRectMake(0, 0, 42, 42);
    self.forwardButton.showsTouchWhenHighlighted=YES;
    [self.forwardButton addTarget:self action:@selector(forwardButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *forwardButton = [[UIBarButtonItem alloc] initWithCustomView:self.forwardButton];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonTapped:)];
    UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadButtonTapped:)];

    self.toolBarArray = [[NSArray alloc] initWithObjects: exitButton, fixedSpace, backButton, fixedSpace,
                         forwardButton, fixedSpace, cancelButton, fixedSpace, reloadButton, nil];
    
    self.navigationItem.leftBarButtonItems=self.toolBarArray;
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

#pragma mark - Action Methods

-(IBAction)exitButtonTapped:(id)sender {
    NSLog(@"Exit Button Was Tapped");
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)backButtonTapped:(id)sender {
    NSLog(@"Back Button Was Tapped");
    [self.webView goBack];
}

-(IBAction)forwardButtonTapped:(id)sender {
    NSLog(@"Forward Button Was Tapped");
    [self.webView goForward];
}

-(IBAction)cancelButtonTapped:(id)sender {
    NSLog(@"Reload Button Was Tapped");
    [self.webView stopLoading];
}

-(IBAction)reloadButtonTapped:(id)sender {
    NSLog(@"Reload Button Was Tapped");
    [self.webView reload];
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

# pragma mark - Status Bar method

- (BOOL)prefersStatusBarHidden {
    return self.shouldHideStatusBar;
}

@end
