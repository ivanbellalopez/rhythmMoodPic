//
//  RMPLoginViewController.h
//  RhythmMoodPic
//
//  Created by eyeem on 6/1/13.
//  Copyright (c) 2013 eyeem. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RMPLoginViewController : UIViewController

@property (nonatomic, strong) IBOutlet UITextField *loginField;
@property (nonatomic, strong) IBOutlet UITextField *pwdField;

@property (nonatomic, strong) IBOutlet UIButton *loginButton;

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;

@property (nonatomic, strong) NSArray *likedAlbums;

@end
