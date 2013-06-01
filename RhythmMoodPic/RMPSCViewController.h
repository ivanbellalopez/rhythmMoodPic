//
//  RMPViewController.h
//  RhythmMoodPic
//
//  Created by eyeem on 6/1/13.
//  Copyright (c) 2013 eyeem. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <AVFoundation/AVFoundation.h>
#import "WaveSampleProvider.h"

@interface RMPSCViewController : UIViewController <WaveSampleProviderDelegate>

@property (nonatomic, strong) WaveSampleProvider *wsp;
@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, strong) UITableView *tracksTableView;

@end
