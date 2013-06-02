//
//  RMPLoginViewController.m
//  RhythmMoodPic
//
//  Created by eyeem on 6/1/13.
//  Copyright (c) 2013 eyeem. All rights reserved.
//

#import "RMPEYELoginViewController.h"
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "RMPAppController.h"
#import "RMPMenuViewController.h"
#import "XBOAuthWebViewController.h"
#import "RMPSCViewController.h"

#define RMP_EYE_Token @"c0f4c01b2e0f2fc1b8aff1725cef3dd399257e3d"

@interface RMPEYELoginViewController ()

@end

@implementation RMPEYELoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.loginButton addTarget:self action:@selector(_loginAction:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationController.navigationBar.hidden = YES;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_goToSC:) name:@"accestoken_finished" object:nil];
    // Do any additional setup after loading the view from its nib.
}


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if ([RMPAppController sharedClient].accessToken) {
		RMPEYELoginViewController *menuVC = [[RMPEYELoginViewController alloc] init];
		[self.navigationController pushViewController:menuVC animated:YES];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)_loginAction:(id)sender
{

	XBOAuthWebViewController *webView = [[XBOAuthWebViewController alloc] init];
	[self.navigationController presentViewController:webView animated:YES completion:nil];

}


- (void)_goToSC:(NSNotification*)notification
{
	RMPSCViewController *vc = [[RMPSCViewController alloc] initWithNibName:@"RMPSCViewController" bundle:nil];
	[self.navigationController pushViewController:vc animated:YES];
}

@end
