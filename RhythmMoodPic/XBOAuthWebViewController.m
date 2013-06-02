
//
//  XBOAuthWebViewController.m
//  xbariPhone
//
//  Created by Ivan Bella López on 2/21/13.
//  Copyright (c) 2013 Ivan Bella Lopez. All rights reserved.
//

#import "XBOAuthWebViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AFJSONRequestOperation.h"
#import "RMPMenuViewController.h"
#import "RMPAppController.h"

#define _kXBButtonMargin    13.0

@interface XBOAuthWebViewController ()
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIView    *headerView;
@property (nonatomic, strong) UIImageView    *headerImageView;
@property (nonatomic, strong) UIButton  *cancelButton;
@property (nonatomic, strong) UIButton  *refreshButton;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@end

@implementation XBOAuthWebViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    [self _setUpHeaderView];
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, self.headerView.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - self.headerView.frame.size.height)];
    self.webView.delegate = self;
	self.navigationController.navigationBarHidden = NO;
    
	[self _init];

    
    [self.view addSubview:self.webView];
    [self _setUpSpinner];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)_setUpHeaderView
{
    UIImage *headerImage = [UIImage imageNamed:@"header_webview.png"];
//    self.headerView = [[UIView alloc] initWithFrame:(CGRect){{0, 0}, headerImage.size}];
	self.headerView = [[UIView alloc] initWithFrame:(CGRect){{0, 0}, {320.0,60.0}}];
    self.headerImageView = [[UIImageView alloc] initWithFrame:(CGRect){{0, 0}, headerImage.size}];
	self.headerImageView.image = headerImage;
    
    
    UIImage *cancelImage = [UIImage imageNamed:@"btton_webview.png"];
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cancelButton setBackgroundImage:cancelImage forState:UIControlStateNormal];
    
    self.cancelButton.frame = (CGRect){{_kXBButtonMargin, _kXBButtonMargin}, cancelImage.size};
    [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.cancelButton.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
    [self.cancelButton addTarget:self action:@selector(_dismissView) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:self.cancelButton];
    
    
//    UIImage *refreshImage = [UIImage imageNamed:@"webview_refresh.png"];
//    self.refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.refreshButton setBackgroundImage:refreshImage forState:UIControlStateNormal];
//    
//    self.refreshButton.frame = (CGRect){{self.headerView.frame.size.width - refreshImage.size.width - _kXBButtonMargin, 0.0}, refreshImage.size};
////    [self.refreshButton xbCenterVerticallyInView:self.headerView];
//    [self.refreshButton addTarget:self action:@selector(_reloadPage) forControlEvents:UIControlEventTouchUpInside];
//    [self.headerView addSubview:self.refreshButton];
    
    [self.view addSubview:self.headerView];
}


- (void)_setUpSpinner
{
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.spinner.frame = CGRectMake(120.0, 150.0, 70.0, 70.0);
    self.spinner.layer.backgroundColor = [UIColor darkGrayColor].CGColor;
    self.spinner.layer.cornerRadius = 5.0;
    [self.view addSubview:self.spinner];
}

#pragma mark - Actions

- (void)_dismissView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)_reloadPage
{
    if (![self.spinner isAnimating]) {
        [self.spinner startAnimating];
    }
    
    [self.webView stopLoading];
    [self.webView reload];
}


- (void)_init
{
    NSString *authenticateURLString = [NSString stringWithFormat:@"http://www.eyeem.com/oauth/authorize?response_type=code&client_id=Jh130fmdwfg07OftEf0j0BdKdxrQ12hy&redirect_uri=http://www.3lokoj.com"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:authenticateURLString]];
    [self.webView loadRequest:request];
}


#pragma mark - Web view delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    [self.spinner startAnimating];
    
    return YES;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.spinner stopAnimating];
    
	
	__weak id weakSelf = self;
	NSString *code = @"";
	
	NSString *URLString = [[self.webView.request URL] absoluteString];
	NSLog(@"--> %@", URLString);
	code = [[URLString componentsSeparatedByString:@"="] lastObject];
	
	if ([code length] > 0 && [[[self.webView.request URL] host] isEqualToString:@"www.3lokoj.com"]) {
		NSString *url = [NSString stringWithFormat:@"http://www.eyeem.com/api/v2/oauth/token?grant_type=authorization_code&client_id=Jh130fmdwfg07OftEf0j0BdKdxrQ12hy&client_secret=1ugKn4ehItE3BjG2od8HgPhr4jeiiiqz&redirect_uri=http://www.3lokoj.com&code=%@", code];
		NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
		
		[self _dismissView];

		AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
			NSLog(@"response: %@",[JSON objectForKey:@"access_token"]);
			[RMPAppController sharedClient].accessToken = [JSON objectForKey:@"access_token"];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"accestoken_finished" object:nil];
		} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
			NSLog(@"error: %@", error);
		}];
		
		[operation start];
	}
	
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.spinner stopAnimating];
    UIAlertView *aV = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [aV show];
}

@end
