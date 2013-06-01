//
//  RMPSCTracksViewController.m
//  RhythmMoodPic
//
//  Created by eyeem on 6/1/13.
//  Copyright (c) 2013 eyeem. All rights reserved.
//

#import "RMPSCTracksViewController.h"
#import "SCAccount.h"
#import "SCRequest.h"
#import "SCSoundCloud.h"

@interface RMPSCTracksViewController ()

@end

@implementation RMPSCTracksViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if ([self.tracks count] == 0) {
		self.tracks = [[NSUserDefaults standardUserDefaults] objectForKey:@"SCTracks"];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [self.tracks count];
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
	
    NSDictionary *track = [self.tracks objectAtIndex:indexPath.row];
    cell.textLabel.text = [track objectForKey:@"title"];
	
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *track = [self.tracks objectAtIndex:indexPath.row];
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
				 [self.player prepareToPlay];
                 [self.player play];
             }];
}


-(void)_saveSong:(NSData *)data{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"audio.caf"];
	NSError *writeError = nil;
	[data writeToFile:filePath options:NSDataWritingAtomic error:&writeError];
	
	if (writeError) {
		NSLog(@"Error writing file: %@", writeError);
	}
	
}
@end
