//
//  RMPAppController.h
//  RhythmMoodPic
//
//  Created by eyeem on 6/1/13.
//  Copyright (c) 2013 eyeem. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RMPAppController : NSObject

+ (RMPAppController*)sharedClient;

@property (nonatomic, strong) NSArray *likedAlbums;
@property (nonatomic, strong) NSArray *tracks;
@property (nonatomic, strong) NSMutableArray *photosArray;

@end
