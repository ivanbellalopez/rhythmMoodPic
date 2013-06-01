//
//  RMPViewController.m
//  RhythmMoodPic
//
//  Created by eyeem on 6/1/13.
//  Copyright (c) 2013 eyeem. All rights reserved.
//

#import "RMPViewController.h"
#import "WaveSampleProvider.h"

@interface RMPViewController ()

@end

@implementation RMPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	NSURL *songURL = nil;
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"sample" ofType:@"mp3"];
	if([[NSFileManager defaultManager] fileExistsAtPath:path]) {
		songURL = [NSURL fileURLWithPath:path];

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
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
			[weakSelf setNeedsDisplay];
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
	}
}


- (void) statusUpdated:(WaveSampleProvider *)provider
{
	
	
}

@end
