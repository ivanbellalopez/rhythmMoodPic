//
//  RMPMenuViewController.m
//  RhythmMoodPic
//
//  Created by eyeem on 6/1/13.
//  Copyright (c) 2013 eyeem. All rights reserved.
//

#import "RMPMenuViewController.h"
#import "SCAccount.h"
#import "SCRequest.h"
#import "SCSoundCloud.h"
#import "RMPAppController.h"
#import "AFJSONRequestOperation.h"
#include <QuartzCore/QuartzCore.h>
#import "RMPAnalyzerViewController.h"

@interface RMPMenuViewController ()

@property (nonatomic, assign) BOOL savedSong;
@end

@implementation RMPMenuViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
	
//	self.eyeemTV = [[UITableView alloc] initWithFrame:CGRectMake(20.0, 80.0, 280.0, 100.0) style:UITableViewStylePlain];
//	self.scTV = [[UITableView alloc] initWithFrame:CGRectMake(20.0, 240.0, 280.0, 100.0) style:UITableViewStylePlain];
	
	self.eyeemTV.delegate = self;
	self.eyeemTV.dataSource = self;
	
	self.scTV.delegate = self;
	self.scTV.dataSource = self;
	
	self.eyeemTV.layer.cornerRadius = 5.0;
	self.scTV.layer.cornerRadius = 5.0;
	
	self.scTV.rowHeight = 40;
	self.eyeemTV.rowHeight = 40;
	
	
	
//	self.continueButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//	self.continueButton.frame = CGRectMake(0, 0, 180.0, 30.0);
//	[self.continueButton setTitle:@"Continue" forState:UIControlStateNormal];
	[self.continueButton addTarget:self action:@selector(_goToAnalyze:) forControlEvents:UIControlEventTouchUpInside];
	
//	[self.view addSubview:self.continueButton];
//	[self.view addSubview:self.eyeemTV];
//	[self.view addSubview:self.scTV];
	

	// Do any additional setup after loading the view.
}


- (void)viewWillAppear:(BOOL)animated
{
	self.spinner.hidden = YES;

	[[RMPAppController sharedClient].photosArray removeAllObjects];
	[self _getSCTracks];
	[self _getFavAlbums];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
	if (tableView == self.scTV) {
		return [[RMPAppController sharedClient].tracks count];
	} else
		return [[RMPAppController sharedClient].likedAlbums count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView
							 dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
				initWithStyle:UITableViewCellStyleDefault
				reuseIdentifier:CellIdentifier];
    }
	
	
	cell.textLabel.font = [UIFont systemFontOfSize:14.0];
	if (tableView == self.scTV) {
		NSDictionary *track = [[RMPAppController sharedClient].tracks objectAtIndex:indexPath.row];
		cell.textLabel.text = [track objectForKey:@"title"];
	} else {
		NSDictionary *track = [[RMPAppController sharedClient].likedAlbums objectAtIndex:indexPath.row];
		cell.textLabel.text = [track objectForKey:@"name"];
		
	}
 
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (tableView == self.scTV) {
		self.spinner.hidden = NO;
		[self.spinner startAnimating];
		self.statusLabelTrack.text = @"Saving song...";
		NSDictionary *track = [[RMPAppController sharedClient].tracks objectAtIndex:indexPath.row];
		NSString *streamURL = [track objectForKey:@"stream_url"];
		
		SCAccount *account = [SCSoundCloud account];
		
		[SCRequest performMethod:SCRequestMethodGET
					  onResource:[NSURL URLWithString:streamURL]
				 usingParameters:nil
					 withAccount:account
		  sendingProgressHandler:nil
				 responseHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
					 NSError *playerError;
					 self.player = [[AVAudioPlayer alloc] initWithData:data error:&playerError];
					 [self _saveSong:data];
					 //				 [self.player prepareToPlay];
					 //                 [self.player play];
				 }];
	} else {
		self.spinner.hidden = NO;
		[self.spinner startAnimating];
		self.statusLabelPhotos.text = @"Fetching URLs";
		NSDictionary *track = [[RMPAppController sharedClient].likedAlbums objectAtIndex:indexPath.row];
		NSString *albumId = [track objectForKey:@"id"];
		NSString *totalPhotos = [track objectForKey:@"totalPhotos"];
		
		NSString *urlString = [NSString stringWithFormat:@"http://www.eyeem.com/api/v2/albums/%@?includePhotos=1&numPhotos=%@&access_token=%@",albumId, totalPhotos,[RMPAppController sharedClient].accessToken];
		
		NSURL *url = [NSURL URLWithString:urlString];
		NSURLRequest *request = [NSURLRequest requestWithURL:url];
		
		AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
			NSArray *photosArray = [JSON valueForKeyPath:@"album.photos.items"];
			
			
			for (NSDictionary *photoDic in photosArray) {
				NSString *photoUrl = [photoDic objectForKey:@"photoUrl"];
				[[photoUrl componentsSeparatedByString:@"/"] lastObject];
				
				[[RMPAppController sharedClient].photosArray addObject:[[photoUrl componentsSeparatedByString:@"/"] lastObject]];
			}
			
			NSLog(@"photothumbs: %i", [[RMPAppController sharedClient].photosArray count]);
			self.spinner.hidden = YES;
			[self.spinner stopAnimating];
			self.statusLabelPhotos.text = @"";
			if (self.savedSong == YES) {
				self.continueButton.enabled = YES;
			}

		} failure:nil];
		
		[operation start];
	}

}


-(void)_saveSong:(NSData *)data{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"audio.caf"];
	NSError *writeError = nil;
	[data writeToFile:filePath options:NSDataWritingAtomic error:&writeError];
	
	if (writeError) {
		NSLog(@"Error writing file: %@", writeError);
		self.savedSong = NO;
	} else {
		NSLog(@"saved song succesfully");
		self.savedSong = YES;
		self.spinner.hidden = YES;
		[self.spinner stopAnimating];
		self.statusLabelTrack.text = @"";
		if ([[RMPAppController sharedClient].photosArray count] > 0) {
			self.continueButton.enabled = YES;
		}
	}
	
}


- (void)_goToAnalyze:(id)sender
{
	if ([[RMPAppController sharedClient].photosArray count] > 0 && self.savedSong) {
		RMPAnalyzerViewController *rmpAnalyzerVC = [[RMPAnalyzerViewController alloc] init];
		[self.navigationController pushViewController:rmpAnalyzerVC animated:YES];
	}
}

- (void)_getSCTracks
{
    SCAccount *account = [SCSoundCloud account];
    if (account == nil) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Not Logged In"
							  message:@"You must login first"
							  delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil];
        [alert show];
        return;
    }
	
    SCRequestResponseHandler handler;
    handler = ^(NSURLResponse *response, NSData *data, NSError *error) {
        NSError *jsonError = nil;
        NSJSONSerialization *jsonResponse = [NSJSONSerialization
                                             JSONObjectWithData:data
											 options:0
											 error:&jsonError];
        if (!jsonError && [jsonResponse isKindOfClass:[NSArray class]]) {
			[RMPAppController sharedClient].tracks = (NSArray *)jsonResponse;
			[self.scTV reloadData];
        } else {
			[RMPAppController sharedClient].tracks = (NSArray *)jsonResponse;
			[self.scTV reloadData];
		}
    };
	
    NSString *resourceURL = @"https://api.soundcloud.com/me/favorites.json";
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:resourceURL]
             usingParameters:nil
                 withAccount:account
      sendingProgressHandler:nil
             responseHandler:handler];
}


- (void)_getFavAlbums
{
	
	
	NSString *url = [NSString stringWithFormat:@"http://www.eyeem.com/api/v2/users/me/favoritedAlbums?includePhotos=1&numPhotos=200&access_token=%@", [RMPAppController sharedClient].accessToken];
	
	NSURL *aUrl = [NSURL URLWithString:url];
	NSURLRequest *aRequest = [NSURLRequest requestWithURL:aUrl];
	
	
	AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:aRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
		NSLog(@"liked: %@", [JSON valueForKeyPath:@"likedAlbums"]);
		[RMPAppController sharedClient].likedAlbums = [[JSON valueForKeyPath:@"likedAlbums"] objectForKey:@"items"];
		
		[self.eyeemTV reloadData];
	} failure:nil];
	
	
	[operation start];
}


@end
