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

#import "RMPAnalyzerViewController.h"

@interface RMPMenuViewController ()

@property (nonatomic, assign) BOOL savedSong;
@end

@implementation RMPMenuViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.eyeemTV = [[UITableView alloc] initWithFrame:CGRectMake(20.0, 80.0, 280.0, 100.0) style:UITableViewStylePlain];
	self.scTV = [[UITableView alloc] initWithFrame:CGRectMake(20.0, 240.0, 280.0, 100.0) style:UITableViewStylePlain];
	
	self.eyeemTV.delegate = self;
	self.eyeemTV.dataSource = self;
	
	self.scTV.delegate = self;
	self.scTV.dataSource = self;
	
	self.continueButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	self.continueButton.frame = CGRectMake(0, 0, 180.0, 30.0);
	[self.continueButton setTitle:@"Continue" forState:UIControlStateNormal];
	[self.continueButton addTarget:self action:@selector(_goToAnalyze:) forControlEvents:UIControlEventTouchUpInside];
	
	[self.view addSubview:self.continueButton];
	[self.view addSubview:self.eyeemTV];
	[self.view addSubview:self.scTV];
	

	// Do any additional setup after loading the view.
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
//		
		NSDictionary *track = [[RMPAppController sharedClient].likedAlbums objectAtIndex:indexPath.row];
		NSString *albumId = [track objectForKey:@"id"];
		NSString *totalPhotos = [track objectForKey:@"totalPhotos"];
		
		NSString *urlString = [NSString stringWithFormat:@"http://www.eyeem.com/api/v2/albums/%@?includePhotos=1&numPhotos=%@&access_token=c0f4c01b2e0f2fc1b8aff1725cef3dd399257e3d",albumId, totalPhotos];
		
		NSURL *url = [NSURL URLWithString:urlString];
		NSURLRequest *request = [NSURLRequest requestWithURL:url];
		
		AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
			NSArray *photosArray = [JSON valueForKeyPath:@"album.photos.items"];
			
			for (NSDictionary *photoDic in photosArray) {
				[[RMPAppController sharedClient].photosArray addObject:[photoDic objectForKey:@"photoUrl"]];
			}
			
			NSLog(@"photothumbs: %i", [[RMPAppController sharedClient].photosArray count]);
			

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
	}
	
}


- (void)_goToAnalyze:(id)sender
{
	if ([[RMPAppController sharedClient].photosArray count] > 0 && self.savedSong) {
		RMPAnalyzerViewController *rmpAnalyzerVC = [[RMPAnalyzerViewController alloc] init];
		[self.navigationController pushViewController:rmpAnalyzerVC animated:YES];
	}
}

@end
