//
//  RMPAppController.m
//  RhythmMoodPic
//
//  Created by eyeem on 6/1/13.
//  Copyright (c) 2013 eyeem. All rights reserved.
//

#import "RMPAppController.h"

@implementation RMPAppController

+ (RMPAppController *)sharedClient {
	static RMPAppController *sharedClient = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedClient = [[self alloc] init];
	});
	return sharedClient;
}

- (id)init
{
	if (self = [super init]) {
		self.photosArray = [[NSMutableArray alloc] initWithCapacity:0];
	}
	return  self;
}

@end
