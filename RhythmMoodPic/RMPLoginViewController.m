//
//  RMPLoginViewController.m
//  RhythmMoodPic
//
//  Created by eyeem on 6/1/13.
//  Copyright (c) 2013 eyeem. All rights reserved.
//

#import "RMPLoginViewController.h"
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"

#define RMP_EYE_Token @"c0f4c01b2e0f2fc1b8aff1725cef3dd399257e3d"

@interface RMPLoginViewController ()

@end

@implementation RMPLoginViewController

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
	
	
    // Do any additional setup after loading the view from its nib.
}


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)_loginAction:(id)sender
{
	self.username = self.loginField.text;
	self.password = self.pwdField.text;
	
	
//	NSURL *url = [NSURL URLWithString:@"http://www.eyeem.com"];
//	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
//	
//		NSString *urlString = [NSString stringWithFormat:@"/api/v2/users/me/favoritedAlbums?access_token=c0f4c01b2e0f2fc1b8aff1725cef3dd399257e3d"];
//	
//	NSDictionary *params = @{@"client_id" : @"Jh130fmdwfg07OftEf0j0BdKdxrQ12hy",
//						  @"clien_secret" : @"1ugKn4ehItE3BjG2od8HgPhr4jeiiiqz",
//						  @"email" : self.username,
//						  @"password" : self.password,
//						  @"grant_type" : @"password"
//						  };
	
	
//	[httpClient h
//	[httpClient getPath:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//		NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//		NSLog(@"Request Successful, response '%@'", responseStr);
//	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//		NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
//	}];

	
	NSURL *url = [NSURL URLWithString:@"http://www.eyeem.com/api/v2/users/me/favoritedAlbums?access_token=c0f4c01b2e0f2fc1b8aff1725cef3dd399257e3d"];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	
	AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
		NSLog(@"liked: %@", [JSON valueForKeyPath:@"likedAlbums"]);
		self.likedAlbums = [JSON valueForKeyPath:@"likedAlbums"];
	} failure:nil];
	
	[operation start];

}

@end
