//
//  RMPViewController.m
//  RhythmMoodPic
//
//  Created by eyeem on 6/1/13.
//  Copyright (c) 2013 eyeem. All rights reserved.
//

#import "RMPSCViewController.h"
#import "SCUI.h"
#import "RMPEYELoginViewController.h"
#import "RMPAppController.h"
#import "RMPMenuViewController.h"
#import "AFJSONRequestOperation.h"

#define RMP_SC_ClientId @"7dd1653e7cafef2a2a888cf703dabf18"
#define RMP_SC_ClientSecret @"5419bf2380c9ecc75a58a9475ac6dbde"

#define RMP_EYE_ClientId @"Jh130fmdwfg07OftEf0j0BdKdxrQ12hy"
#define RMP_EYE_ClientSecret @"1ugKn4ehItE3BjG2od8HgPhr4jeiiiqz"

@interface RMPSCViewController ()

@end

@implementation RMPSCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.scButton addTarget:self action:@selector(_initSC) forControlEvents:UIControlEventTouchUpInside];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self _getUserInfo];
}


- (void)_initSC
{
	[SCSoundCloud setClientID:RMP_SC_ClientId
					   secret:RMP_SC_ClientSecret
				  redirectURL:[NSURL URLWithString:@"http://www.3lokoj.com"]];
	
	[self _loginSC];
}


- (void)_loginSC
{
	SCLoginViewControllerCompletionHandler handler = ^(NSError *error) {
        if (SC_CANCELED(error)) {
            NSLog(@"Canceled!");
        } else if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        } else {
            NSLog(@"Done!");
			RMPMenuViewController *menuVC = [[RMPMenuViewController alloc] init];
			[self.navigationController pushViewController:menuVC animated:YES];
        }
    };
	
    [SCSoundCloud requestAccessWithPreparedAuthorizationURLHandler:^(NSURL *preparedURL) {
        SCLoginViewController *loginViewController;
		
        loginViewController = [SCLoginViewController
                               loginViewControllerWithPreparedURL:preparedURL
							   completionHandler:handler];
		
        [self presentViewController:loginViewController animated:YES completion:nil];
    }];
}


- (void)_getUserInfo
{
	
	
	NSString *url = [NSString stringWithFormat:@"http://www.eyeem.com/api/v2/users/me&access_token=%@", [RMPAppController sharedClient].accessToken];
	
	NSURL *aUrl = [NSURL URLWithString:url];
	NSURLRequest *aRequest = [NSURLRequest requestWithURL:aUrl];
	
	
	AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:aRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
		NSLog(@"liked: %@", [JSON valueForKeyPath:@"likedAlbums"]);
		NSString *userName = [[[JSON valueForKeyPath:@"user"] valueForKey:@"nickname"] capitalizedString];
		self.name.text = [NSString stringWithFormat:@"HELLO %@", userName];
		
	} failure:nil];
	
	
	[operation start];
}


@end
