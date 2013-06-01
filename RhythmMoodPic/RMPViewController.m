//
//  RMPViewController.m
//  RhythmMoodPic
//
//  Created by eyeem on 6/1/13.
//  Copyright (c) 2013 eyeem. All rights reserved.
//

#import "RMPViewController.h"
#import "WaveSampleProvider.h"
#import "SCUI.h"
#import "RMPSCTracksViewController.h"

#define RMP_SC_ClientId @"7dd1653e7cafef2a2a888cf703dabf18"
#define RMP_SC_ClientSecret @"5419bf2380c9ecc75a58a9475ac6dbde"

@interface RMPViewController ()

@end

@implementation RMPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
//	[self _initSC];
//	
//	[self _loginSC];
	
	[self _analyzeSong];
	
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)_initSC
{
	[SCSoundCloud setClientID:RMP_SC_ClientId
					   secret:RMP_SC_ClientSecret
				  redirectURL:[NSURL URLWithString:@"http://www.3lokoj.com"]];
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
			[self performSelector:@selector(_getSCTracks) withObject:nil afterDelay:1.0];
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
            RMPSCTracksViewController *trackListVC;
            trackListVC = [[RMPSCTracksViewController alloc] initWithNibName:@"RMPSCTracksViewController" bundle:nil];
			[[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithArray:(NSArray *)jsonResponse] forKey:@"SCTracks"];
            trackListVC.tracks = (NSArray *)jsonResponse;
            [self.navigationController presentViewController:trackListVC animated:YES completion:nil];
        } else {
			RMPSCTracksViewController *trackListVC;
            trackListVC = [[RMPSCTracksViewController alloc] initWithNibName:@"RMPSCTracksViewController" bundle:nil];
            trackListVC.tracks = [[NSUserDefaults standardUserDefaults] objectForKey:@"SCTracks"];
			[self.navigationController presentViewController:trackListVC animated:YES completion:nil];
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


- (void)_analyzeSong
{
	NSURL *songURL = nil;
	
	
	NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentPath = [searchPaths objectAtIndex:0];
	
	NSString *filePath = [documentPath stringByAppendingPathComponent:@"audio.caf"];

	NSString *path = [[NSBundle mainBundle] pathForResource:@"audio" ofType:@"caf"];
	if([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		songURL = [NSURL fileURLWithPath:filePath];
		
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"No Audio !"
														message: @"You should add a sample.mp3 file to the project before test it."
													   delegate: self
											  cancelButtonTitle: @"OK"
											  otherButtonTitles: nil];
		[alert show];
	}
	
	self.wsp = [[WaveSampleProvider alloc]initWithURL:songURL];
	self.wsp.delegate = self;
	[self.wsp createSampleData];
}


- (void)_startAudio
{
	id __weak weakSelf = self;
	AVPlayer __weak *weakPlayer = self.player;
	
	if(self.wsp.status == LOADED) {
		self.player = [[AVPlayer alloc] initWithURL:self.wsp.audioURL];
		CMTime tm = CMTimeMakeWithSeconds(0.1, NSEC_PER_SEC);
		[self.player addPeriodicTimeObserverForInterval:tm queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
			Float64 duration = CMTimeGetSeconds(weakPlayer.currentItem.duration);
			Float64 currentTime = CMTimeGetSeconds(weakPlayer.currentTime);
			int dmin = duration / 60;
			int dsec = duration - (dmin * 60);
			int cmin = currentTime / 60;
			int csec = currentTime - (cmin * 60);
			if(currentTime > 0.0) {
//				[weakSelf setTimeString:[NSString stringWithFormat:@"%02d:%02d/%02d:%02d",dmin,dsec,cmin,csec]];
			}
//			playProgress = currentTime/duration;
//			[weakSelf setNeedsDisplay];
		}];
		[self.player play];
	}
}

#pragma mark - WaveSampleProvider delegate


- (void) sampleProcessed:(WaveSampleProvider *)provider
{
	if (provider.status == 1) {
		NSLog(@"finish analyzing");
		NSLog(@"data count: %i", [self.wsp.normalizedData count]);
		[self _startAudio];
	}
}


- (void) statusUpdated:(WaveSampleProvider *)provider
{
	
	
}

@end
