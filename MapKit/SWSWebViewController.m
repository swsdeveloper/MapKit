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
    //NSLog(@"%s", __FUNCTION__);
    
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
    _webView.delegate = nil;
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
    [self.webView reload];
}

#pragma mark - UIWebView Delegate methods

// This is where you could, intercept HTML requests and route them through NSURLConnection, to see if the server responds successfully
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (MYDEBUG_UIWebViewDelegate) { NSLog(@"%s", __FUNCTION__); }
    

    /*
     // We're only validating links we click on; if we validated that successfully, though, let's just go open it
    // nb: we're only validating links we click on because some sites initiate additional html requests of
    // their own, and don't want to get involved in mediating each and every server request; we're only
    // going to concern ourselves with those links the user clicks on.
    
    if (self.validatedRequest || navigationType != UIWebViewNavigationTypeLinkClicked)
        return YES;
    
    // if user clicked on a link and we haven't validated it yet, let's do so
    
    self.originalUrl = request.URL;
    [NSURLConnection connectionWithRequest:request delegate:self];
    
    // and if we're validating, don't bother to have the web view load it yet ...
    // the `didReceiveResponse` will do that for us once the connection has been validated
    
    return NO;
    */
    
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if (MYDEBUG_UIWebViewDelegate) { NSLog(@"%s", __FUNCTION__); }
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.querySelector('meta[name=viewport]').setAttribute('content', 'width=%d;', false); ", (int)webView.frame.size.width]]; // Use javascript to force display to full webpage width
    webView.scalesPageToFit = YES;
}

// This will be called for 404 errors
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (MYDEBUG_UIWebViewDelegate) { NSLog(@"%s", __FUNCTION__); }
    [webView stopLoading];
    
//    self.validatedRequest = NO; // reset this for the next link the user clicks on
    
    // Debugging: go to website and return entire contents of page as an ASCII string -- odd: always shows previous page we left, not page we're going to - why?
    NSLog(@"\n*****************************************************************************************************************");
    NSURL *requestURL = [[webView request] URL];
    NSError *error;
    NSString *page = [NSString stringWithContentsOfURL:requestURL
                                              encoding:NSASCIIStringEncoding
                                                 error:&error];
    NSLog(@"URL: %@ returned:\n\n%@", [requestURL absoluteString], page);
    NSLog(@"\nURLError: %@", [error description]);
    NSLog(@"*****************************************************************************************************************\n");
    
    [webView setNeedsDisplay];
}

// You will not see this called for 404 errors
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (MYDEBUG_UIWebViewDelegate) { NSLog(@"%s error=%@", __FUNCTION__, [error description]); }
    [webView stopLoading];
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
