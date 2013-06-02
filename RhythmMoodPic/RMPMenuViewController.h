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

@property (nonatomic, strong) IBOutlet UITableView *eyeemTV;
@property (nonatomic, strong) IBOutlet UITableView *scTV;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, strong) IBOutlet UILabel *statusLabelPhotos;
@property (nonatomic, strong) IBOutlet UILabel *statusLabelTrack;

@property (nonatomic, strong) AVAudioPlayer *player;

@property (nonatomic, strong) IBOutlet UIButton *continueButton;

@end
