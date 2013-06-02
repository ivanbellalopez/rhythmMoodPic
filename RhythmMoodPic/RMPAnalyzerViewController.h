//
//  RMPAnalyzerViewController.h
//  RhythmMoodPic
//
//  Created by eyeem on 6/1/13.
//  Copyright (c) 2013 eyeem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WaveSampleProvider.h"
#include <AVFoundation/AVFoundation.h>



@interface RMPAnalyzerViewController : UIViewController <WaveSampleProviderDelegate>

@property (nonatomic, strong) WaveSampleProvider *wsp;

@property (nonatomic, strong) IBOutlet UIView *slideShowView;

@property (nonatomic, strong) IBOutlet UIButton *playButton;

@property (nonatomic, strong) IBOutlet UIImageView *imgView;

@property (nonatomic, strong) IBOutlet UIImageView *loadingView;

@end
