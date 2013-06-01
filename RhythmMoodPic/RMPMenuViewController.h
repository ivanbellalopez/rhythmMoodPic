//
//  RMPMenuViewController.h
//  RhythmMoodPic
//
//  Created by eyeem on 6/1/13.
//  Copyright (c) 2013 eyeem. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <AVFoundation/AVFoundation.h>

@interface RMPMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *eyeemTV;
@property (nonatomic, strong) UITableView *scTV;

@property (nonatomic, strong) AVAudioPlayer *player;

@property (nonatomic, strong) UIButton *continueButton;

@end
