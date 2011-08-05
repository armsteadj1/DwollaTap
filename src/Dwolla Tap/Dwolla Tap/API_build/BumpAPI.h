//
//  BumpAPI.h
//  BumpAPI
//
//  Copyrights / Disclaimer
//  Copyright 2010, Bump Technologies, Inc. All rights reserved.
//  Use of the software programs described herein is subject to applicable
//  license agreements and nondisclosure agreements. Unless specifically
//  otherwise agreed in writing, all rights, title, and interest to this
//  software and documentation remain with Bump Technologies, Inc. Unless
//  expressly agreed in a signed license agreement, Bump Technologies makes
//  no representations about the suitability of this software for any purpose
//  and it is provided "as is" without express or implied warranty.
//
//  Copyright (c) 2010 Bump Technologies Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Bumper.h"

typedef enum BumpSessionEndReason {
	END_USER_QUIT, //The local user quit cleanly
	END_LOST_NET,  //The connection to the server was lost
	END_OTHER_USER_QUIT, //the remote user quit cleanly
	END_OTHER_USER_LOST  //the connection to the remote user was lost
} BumpSessionEndReason;

typedef enum BumpSessionStartFailedReason {
	FAIL_NONE,
	FAIL_USER_CANCELED, //The local user canceled before connecting
	FAIL_NETWORK_UNAVAILABLE, //The network was unavailable, and the local user canceled.
	FAIL_INVALID_AUTHORIZATION, //The APIKey was invalid
} BumpSessionStartFailedReason;

/**
 Callbacks that let your app know the what's happening during a Bump session
 */
@protocol BumpAPIDelegate

/**
 Successfully started a Bump session with another device.
 @param		otherBumper		Let's you know how the other device identifies itself
							Can also be accessed later via the otherBumper method on the API
 */
- (void) bumpSessionStartedWith:(Bumper *)otherBumper;

/**
 There was an error while trying to start the session these reasons are helpful and let you know
 what's going on
 @param		reason			Why the session failed to start
 */
- (void) bumpSessionFailedToStart:(BumpSessionStartFailedReason)reason;

/**
 The bump session was ended, reason tells you wheter it was expected or not
 @param		reason			Why the session ended. Could be either expected or unexpected.
 */
- (void) bumpSessionEnded:(BumpSessionEndReason)reason;

/**
 The symmetrical call to sendData on the API. When the other device conneced via Bump calls sendData
 this device get's this call back
 @param		reason			Data sent by the other device.
 */
- (void) bumpDataReceived:(NSData *)chunk;

@end


@interface BumpAPI  : NSObject {
}

/**
 * There can be only one! The API strictly enforces the existance of a single instance. Don't call
 * alloc init on this class, bad things will happen.
 */
+(BumpAPI*)sharedInstance;

#pragma mark Cofiguration Functions - Do these before Session Functions below

/**
 <b>Required</b>. Set up the delegate so that you can recieve notifications about the Bump Session. 
 The delegate is not retained (behaves the same as a nonatomic,assign property).
 */
-(void)configDelegate:(id<BumpAPIDelegate, NSObject>) delegate;//required

/**
 <b>Important: This method should be called first before any of the other methods. Required</b>. 
 */
-(void)configAPIKey:(NSString*)key;//required

/**
 <b>Required, if using defualt UI</b>. This is the View to which the Popup will be added. This 
 should most likely be the main view of the view controller the api is started from. The parent 
 view is not retained by the API.
 */
-(void)configParentView:(UIView*)parentView;//required

/**
 How to identify the current user to the other phone. If not provided, the API will by default
 use the device name. This can be retrieved later by accessing the name method of the -(Bumper*)me 
 property of the API. This will show up as the name property in the -(Bumper *)otherBumper on the 
 other device.
 */
-(void)configUserName:(NSString*)name;//optional


/**
 Shows up when in the Bump pop up saying what the result of the bump will be. 
 Example: “Bump with another Texas Hold’em player to start game.”
 */
-(void)configActionMessage:(NSString*)message;//recommended


#pragma mark Session Functions

/**
 <b>Required</b>. Call this when you want to connect with another device.  This launches the UI to 
 start a bump. This method cannot be called to request a another session while you are currently in 
 session. You must call endSession before calling requestSession to open a session with another 
 user.
 */
-(void)requestSession;//required

/**
 <b>Required</b>. Call this when you want to close a currently established session with another 
 device. This must be called before trying to call requestSession again.
 */
-(void)endSession;//required

/**
 This sends the bytes you provide it to the other device that the current session is established 
 with. The other side is not guaranteed to receive consequitive chunks in the same order you
 send through this method. If order matters to you then you should number your data chunks. This
 is not really a problem for a game like BumpFour because a device can only send a move after it
 receives a move from the other device.
 
 <b>Warning</b>: The maximum size you may send in a single chunk is 256k. If you try to send more 
 the API will throw an exception. If you need to send a larger single piece of data, send your data
 in chunks and rebuild it on the the other side.
 
 @throws BumpAPI Data chunk too large
 */
-(void)sendData:(NSData*)chunk;

#pragma mark Meta Data

/**
 What Bump is using as the current user's meta data for bumping
 */
-(Bumper*)me;

/**
 How the other device describes itself
 */
-(Bumper*)otherBumper;

@end