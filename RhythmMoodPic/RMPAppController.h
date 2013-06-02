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

@property (nonatomic, strong) NSArray *normalizedData;
@property (nonatomic, strong) NSArray *likedAlbums;
@property (nonatomic, strong) NSArray *tracks;
@property (nonatomic, strong) NSMutableArray *photosArray;
@property (nonatomic, strong) NSMutableArray *photosImagesArray;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *userName;



@end
