//
//  SWSWebViewController.m
//  MapKit
//
//  Created by Steven Shatz on 1/22/15.
//  Copyright (c) 2015 Steven Shatz. All rights reserved.
//

#import "SWSWebViewController.h"
#import "Constants.h"
#import <QuartzCore/QuartzCore.h>
#import "UIWebView+SWSUIWebView.h"
#import "WKWebView+SWSWKWebView.h"


@implementation SWSWebViewController

- (void)viewDidLoad {
    //NSLog(@"%s", __FUNCTION__);

    [super viewDidLoad];
    
    if (NSClassFromString(@"WKWebView")) {
        _webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
        NSLog(@"Using WKWebView");
    } else {
        _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        NSLog(@"Using UIWebView");
    }
                    
    [_webView setDelegateViews:self];
    
//    _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
//    _webView.delegate = self;
//    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview: _webView];
    
    if (CACHE_Fix) { self.lastUrl = nil; }
    
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
    
    self.toolBarArray = [[NSArray alloc] initWithObjects:backButton, fixedSpace,
                         forwardButton, fixedSpace, cancelButton, reloadButton, nil];
    
    self.navigationItem.leftBarButtonItems=self.toolBarArray;
    self.navigationItem.rightBarButtonItems=[[NSArray alloc] initWithObjects:exitButton, nil];
    
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 5.0, 200, 42)];
    self.label.backgroundColor = [UIColor lightGrayColor];
    self.label.text = @"";
    
    self.navigationItem.title=self.label.text;

    /*
    // Since `shouldStartLoadWithRequest` only validates when a user clicks on a link, we'll bypass that
    // here and go right to the `NSURLConnection`, which will validate the request, and if good, it will
    // load the web view for us.
    
    self.originalUrl = self.url;
    NSURLRequest *request = [NSURLRequest requestWithURL:self.originalUrl];
    [NSURLConnection connectionWithRequest:request delegate:self];
     */
    
}

- (void)viewWillAppear:(BOOL)animated {
    //NSLog(@"%s", __FUNCTION__);
    [super viewWillAppear:animated];
    [self loadRequestFromURL:self.url];
}

- (void)viewDidDisappear:(BOOL)animated{
    //NSLog(@"%s", __FUNCTION__);
    [_webView stopLoading];
    NSURL *url = [NSURL URLWithString:@"about:blank"];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
    [_webView setDelegateViews:nil];

}

- (void)loadRequestFromURL:(NSURL*)url {
    NSLog(@"%s url=%@", __FUNCTION__, [url absoluteString]);
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
    NSLog(@"Cancel Button Was Tapped");
    [self.webView stopLoading];
}

-(IBAction)reloadButtonTapped:(id)sender {
    NSLog(@"Reload Button Was Tapped");
    [self.webView stopLoading];
    [self.webView reload];
}

#pragma mark - Shared Web View Delegate Methods (for UIWebView and WKWebView)

- (BOOL)shouldStartDecidePolicy:(NSURLRequest *)request {
    return YES;
}

- (void)didStartNavigation {
    [self.webView scrollView].scrollEnabled = TRUE;

    // Show spinning activity indicator while webpage is loading
    if (self.loadingView) {
        [self.loadingView setHidden:NO];
    } else {
        self.loadingView = [[UIView alloc]initWithFrame:CGRectMake((self.webView.bounds.size.width-80.0)/2.0,
                                                                   (self.webView.bounds.size.height-80.0)/2.0,
                                                                   80.0, 80.0)];
        self.loadingView.backgroundColor = [UIColor colorWithWhite:0. alpha:0.6];
        self.loadingView.layer.cornerRadius = 5;
        
        UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityView.center = CGPointMake(self.loadingView.frame.size.width / 2.0, 35);
        [activityView startAnimating];
        activityView.tag = 100;
        [self.loadingView addSubview:activityView];
        
        UILabel* lblLoading = [[UILabel alloc]initWithFrame:CGRectMake(0, 48, 80, 30)];
        lblLoading.text = @"Loading...";
        lblLoading.textColor = [UIColor whiteColor];
        lblLoading.font = [UIFont fontWithName:lblLoading.font.fontName size:15];
        lblLoading.textAlignment = NSTextAlignmentCenter;
        [self.loadingView addSubview:lblLoading];
        
        [self.view addSubview:self.loadingView];
    }
    if (CACHE_Fix) { self.lastUrl = [[self.webView request] URL]; }
}

- (void)failLoadOrNavigation:(NSURLRequest *)request withError:(NSError *)error {
    NSLog(@"%s error=%@", __FUNCTION__, [error description]);
    [self.loadingView setHidden:YES];
}

- (void)finishLoadOrNavigation:(NSURLRequest *)request {
    NSLog(@"%s",__FUNCTION__);
    [self.loadingView setHidden:YES];
    
//    // Debugging: go to website and capture entire contents of page as an ASCII string
//    if (MYDEBUG_CaptureWebPage) {
//        NSLog(@"\n*****************************************************************************************************************");
//        NSURL *requestURL = [[self.webView request] URL];
//        NSError *error;
//        NSString *page = [NSString stringWithContentsOfURL:requestURL
//                                                  encoding:NSASCIIStringEncoding
//                                                     error:&error];
//        NSLog(@"URL: %@ returned:\n\n%@", [requestURL absoluteString], page);
//        NSLog(@"\nURLError: %@", [error description]);
//        NSLog(@"*****************************************************************************************************************\n");
//    }
    
    self.label.text = [[[self.webView request] URL] absoluteString];
    self.navigationItem.title=self.label.text;
    
    [self.webView setNeedsDisplay];
}

#pragma mark - UIWebView Delegate methods

// This is where you could, intercept HTML requests and route them through NSURLConnection, to see if the server responds successfully
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (MYDEBUG_UIWebViewDelegate) { NSLog(@"%s", __FUNCTION__); }
    
    if (webView.loading) {  // Don't interrupt webpage if it is in the midst of loading
        NSLog(@"Not going to load!!!");
        return NO;
    }
    
    return [self shouldStartDecidePolicy:request];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if (MYDEBUG_UIWebViewDelegate) { NSLog(@"%s", __FUNCTION__); }
    
    webView.scalesPageToFit = YES;
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.querySelector('meta[name=viewport]').setAttribute('content', 'width=%d;', false); ", (int)webView.frame.size.width]]; // Use javascript to force display to full webpage width
    
    [self didStartNavigation];
}

// This will be called for 404 errors
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (MYDEBUG_UIWebViewDelegate) { NSLog(@"%s", __FUNCTION__); }
    
// The following code reloads a webpage bypassing the cache (in case cached results are no longer valid):
    if (CACHE_Fix) {
        if ([webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"].length < 1) {
            NSLog(@"Reconstructing request...");
            NSString *uniqueURL = [NSString stringWithFormat:@"%@?t=%@", self.lastUrl, [[NSProcessInfo processInfo] globallyUniqueString]];
            [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:uniqueURL] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:5.0]];
        }
    }
    
    [self finishLoadOrNavigation: [webView request]];
}

// You will not see this called for 404 errors
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    /*
     NSURLErrorUnknown = -1
     NSURLErrorCancelled = -999 --- another url request was made before the current one finished; perhaps a redirect? or a frame in the current page?
     NSURLErrorBadURL = -1000
     NSURLErrorTimedOut = -1001
     */
    
    [self failLoadOrNavigation: [webView request] withError: error];
}

#pragma mark - WKWebView Delegate Methods

- (void) webView: (WKWebView *) webView decidePolicyForNavigationAction: (WKNavigationAction *) navigationAction decisionHandler: (void (^)(WKNavigationActionPolicy)) decisionHandler {
    decisionHandler([self shouldStartDecidePolicy: [navigationAction request]]);
}

- (void) webView: (WKWebView *) webView didStartProvisionalNavigation: (WKNavigation *) navigation {
    [self didStartNavigation];
}

- (void) webView:(WKWebView *) webView didFailProvisionalNavigation: (WKNavigation *) navigation withError: (NSError *) error {
    [self failLoadOrNavigation: [webView request] withError: error];
}

- (void) webView: (WKWebView *) webView didFailNavigation: (WKNavigation *) navigation withError: (NSError *) error {
    [self failLoadOrNavigation: [webView request] withError: error];
}

- (void) webView: (WKWebView *) webView didFinishNavigation: (WKNavigation *) navigation {
    [self finishLoadOrNavigation: [webView request]];
}

/*
#pragma mark - NSURLConnectionData Delegate method

// This code inspired by http://www.ardalahmet.com/2011/08/18/how-to-detect-and-handle-http-status-codes-in-uiwebviews/
// Given that some ISPs do redirects that one might otherwise prefer to see handled as errors, I'm also checking
// to see if the original URL's host matches the response's URL. This logic may be too restrictive (some valid redirects
// will be rejected, such as www.adobephotoshop.com which redirects you to www.adobe.com), but does capture the ISP
// redirect problem I am concerned about.

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"%s", __FUNCTION__);
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    
    NSString *originalUrlHostName = self.originalUrl.host;
    NSString *responseUrlHostName = response.URL.host;
    
    NSRange originalInResponse = [responseUrlHostName rangeOfString:originalUrlHostName]; // handle where we went to "apple.com" and got redirected to "www.apple.com"
    NSRange responseInOriginal = [originalUrlHostName rangeOfString:responseUrlHostName]; // handle where we went to "www.stackoverflow.com" and got redirected to "stackoverflow.com"
    
    if (originalInResponse.location == NSNotFound && responseInOriginal.location == NSNotFound) {
        NSLog(@"%s you were redirected from %@ to %@", __FUNCTION__, self.originalUrl.absoluteString, response.URL.absoluteString);
    } else if (httpResponse.statusCode < 200 || httpResponse.statusCode >= 300) {
        NSLog(@"%s request to %@ failed with statusCode=%ld", __FUNCTION__, response.URL.absoluteString, (long)httpResponse.statusCode);
    } else {
        [connection cancel];
        
        self.validatedRequest = YES;
        
        [self.webView loadRequest:connection.originalRequest];
        
        return;
    }
    
    [connection cancel];
}
 */


# pragma mark - Status Bar method

- (BOOL)prefersStatusBarHidden {
    return self.shouldHideStatusBar;
}

@end
