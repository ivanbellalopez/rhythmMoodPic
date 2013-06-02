//
//  RMPAnalyzerViewController.m
//  RhythmMoodPic
//
//  Created by eyeem on 6/1/13.
//  Copyright (c) 2013 eyeem. All rights reserved.
//

#import "RMPAnalyzerViewController.h"
#import "AFImageRequestOperation.h"
#import "RMPAppController.h"

@interface RMPAnalyzerViewController ()

@property int currentSec;
@property int photoIdx;
@property int normDataIdx;
@property int isGettingHigh;

@property (nonatomic, strong) NSNumber *normalizeValue;
@property (nonatomic, strong) NSNumber *currentNormData;

@end

@implementation RMPAnalyzerViewController

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

	[self.playButton addTarget:self action:@selector(_startAudio) forControlEvents:UIControlEventTouchUpInside];
	
	[self _downloadImages];
	// Do any additional setup after loading the view.
}


- (void)viewWillAppear:(BOOL)animated
{
	self.currentSec = 0;
	self.photoIdx = 0;
	self.normDataIdx = 0;
	self.currentNormData = 0;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Analyzer

- (void)_analyzeSong
{
	NSURL *songURL = nil;
	
	
	NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentPath = [searchPaths objectAtIndex:0];
	
	NSString *filePath = [documentPath stringByAppendingPathComponent:@"audio.caf"];
	
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
	self.playButton.hidden = YES;
	AVPlayer *player = [[AVPlayer alloc] initWithURL:self.wsp.audioURL];

	AVPlayer __weak *weakPlayer = player;
	
	if(self.wsp.status == LOADED) {
//		self.player = [[AVPlayer alloc] initWithURL:self.wsp.audioURL];
		CMTime tm = CMTimeMakeWithSeconds(0.0011, NSEC_PER_SEC);
		[weakPlayer addPeriodicTimeObserverForInterval:tm queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
			Float64 duration = CMTimeGetSeconds(weakPlayer.currentItem.duration);
			Float64 currentTime = CMTimeGetSeconds(weakPlayer.currentTime);
			int dmin = duration / 60;
			int dsec = duration - (dmin * 60);
			int cmin = currentTime / 60;
			int csec = currentTime - (cmin * 60);
			if(currentTime > 0.0) {
//				NSLog(@"%02d:%02d/%02d:%02d",dmin,dsec,cmin,csec);
				[self _updateSlideShow:csec];
				//				[weakSelf setTimeString:[NSString stringWithFormat:@"%02d:%02d/%02d:%02d",dmin,dsec,cmin,csec]];
			}
			//			playProgress = currentTime/duration;
			//			[weakSelf setNeedsDisplay];
		}];
		
		
		[weakPlayer play];
	}
}

#pragma mark - WaveSampleProvider delegate


- (void) sampleProcessed:(WaveSampleProvider *)provider
{
	if (provider.status == 1) {
//		NSLog(@"finish analyzing");
//		NSLog(@"data count: %i", [self.wsp.normalizedData count]);
		self.imgView.image = [[RMPAppController sharedClient].photosImagesArray objectAtIndex:0];
		self.playButton.hidden = NO;
	}
}


- (void) statusUpdated:(WaveSampleProvider *)provider
{
	
	
}

- (void)_downloadImages
{
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,
											 (unsigned long)NULL), ^(void) {
		for (int c=0; c < [[RMPAppController sharedClient].photosArray count]; c++) {
			NSString *photoUrl = [NSString stringWithFormat:@"http://www.eyeem.com/thumb/320/460/%@",[[RMPAppController sharedClient].photosArray objectAtIndex:c]];
			
			NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:photoUrl]];
			
			
			AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request success:^(UIImage *image) {
				[[RMPAppController sharedClient].photosImagesArray addObject:image];
				NSLog(@"saved images: %i", [[RMPAppController sharedClient].photosImagesArray count]);

				if ([[RMPAppController sharedClient].photosImagesArray count] == [[RMPAppController sharedClient].photosArray count]) {
					[self _analyzeSong];
				}
			}];
	
			[operation start];
			

			
		}
	});

}

- (void)_updateSlideShow:(int)currentSec
{
	
	self.normalizeValue = [[RMPAppController sharedClient].normalizedData objectAtIndex:self.normDataIdx];
//	NSLog(@"normData: %f", [self.normalizeValue floatValue]);
	
	if ([self _isGoingUp]) {
		self.imgView.image= [[RMPAppController sharedClient].photosImagesArray objectAtIndex:self.photoIdx];
		 self.photoIdx++;
		if (self.photoIdx == [[RMPAppController sharedClient].photosImagesArray count] -1) {
			self.photoIdx = 0;
		}
		NSLog(@"diff: %f", fabsf([self.currentNormData floatValue] - [self.normalizeValue floatValue]));
		
		NSLog(@"image: %@", [self.imgView.image description]);

	}

	 
	self.normDataIdx++;
	self.currentNormData = self.normalizeValue;
	self.currentSec = currentSec;
}

- (BOOL)_isGoingUp
{
	if (fabsf([self.currentNormData floatValue] - [self.normalizeValue floatValue]) > 0.03) {
		self.isGettingHigh ++;
		if (self.isGettingHigh > 10) {
			return YES;
			self.isGettingHigh = 0;
		}
	}
	

	return NO;
}

@end
