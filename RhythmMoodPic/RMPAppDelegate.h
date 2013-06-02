//
//  RMPAppDelegate.h
//  RhythmMoodPic
//
//  Created by eyeem on 6/1/13.
//  Copyright (c) 2013 eyeem. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RMPEYELoginViewController;

@interface RMPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) RMPEYELoginViewController *viewController;

@end
