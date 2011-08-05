//
//  GameBumpConnector.m
//  BumpFour
//
//  Created by Jake on 10/14/09.
//
//  Copyright 2010, Bump Technologies, Inc. All rights reserved.  Use of the 
//  software programs described herein is subject to applicable license agreements 
//  and nondisclosure agreements. Unless specifically otherwise agreed in
//  writing, all rights, title, and interest to this software and
//  documentation remain with Bump Technologies, Inc. Unless expressly
//  agreed in a signed license agreement, Bump Technologies makes no
//  representations about the suitability of this software for any purpose
//  and it is provided "as is" without express or implied warranty.
//  

//This is a simple example of how to use the Bump API.
// All methods found under the tag: #pragma mark BumpDelegate methods


#import "BumpConnector.h"
#import "TapViewController.h"

static BumpConnector *sharedSingleton;

@implementation BumpConnector

@synthesize tapView,sessionStarted;

+ (void)initialize
{
    @synchronized(self) {
        static BOOL initialized = NO;
        if(!initialized)
        {
            initialized = YES;
            sharedSingleton = [[BumpConnector alloc] init];
            sharedSingleton.sessionStarted = false;
        }
    }
}

+ (BumpConnector *) instance {
    [self initialize];
    return sharedSingleton;
}

- (BumpAPI *) getBump {
    return bumpObject;
}

-(void) cleanup{
    [self stopBump];
    tapView = nil;
}

-(void) configBump{
    if (bumpObject == nil) {
        bumpObject = [BumpAPI sharedInstance];        
    }
	[bumpObject configAPIKey:@"c2286aa7158e4af893cd857195fa9dfc"];
	[bumpObject configDelegate: tapView];
	[bumpObject configUIDelegate: tapView];
}

- (void) startBump{
    if (sessionStarted == false && tapView != nil) {
     	[self configBump];
        [bumpObject requestSession];   
    }
}

- (void) stopBump{
	[bumpObject endSession];
    sessionStarted = false;
}

#pragma mark -
-(void) dealloc{
	[super dealloc];
}

@end
