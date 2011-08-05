//
//  BumpAPICustomUI.h
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

#import "Bumper.h"

/**
 * Defines the reasons for a bump was cancelled
 */
typedef enum {
	NoMatch_ReasonNoConfirm = 0,
	NoMatch_ReasonAlone = 1,
	NoMatch_ReasonTooMany = 2,
} BumpMatchFailedReason;

/**
 * This protocol should be implemented by the object that manages the UI for Bump trying to 
 * establish a session with another user. To use this properly, create the object that implements
 * this protocol and then call configUIDelegate on the BumpAPI (declared below). If you don't call
 * configUIDelegate bump will use it's own internal UI.
 *
 * Once configUIDelegate has been called, only after that should you call requestSession on BumpAPI.
 * At that time your delegate will recieve the bumpRequestSessionCalled message (described below). 
 * Soon after that the implementor should be called with a bumpConnectedToBumpNetwork message.
 * This method lets you know that the internal system can now accept physical bumps.
 *
 *
 * Responsibilities:  The implementor needs to call setBumpable at the beginning. It needs 
 * to let the BumpAPI know that the user has confirmed or denied the bump.
 */
@protocol BumpAPICustomUI

/**
 * Result of requestSession on BumpAPI (user wants to connect to another device via Bump). UI should
 * now first appear saying something like "Warming up".
 */
-(void)bumpRequestSessionCalled;

/**
 * We were unable to establish a connection to the Bump network. Either show an error message or
 * hide the popup. The BumpAPIDelegate is about to be called with bumpSessionFailedToStart.
 */
-(void)bumpFailedToConnectToBumpNetwork;

/**
 * We were able to establish a connection to the Bump network and you are now ready to bump. 
 * The UI should say something like "Ready to Bump".
 */
-(void)bumpConnectedToBumpNetwork;

/**
 * Result of endSession call on BumpAPI. Will soon be followed by the call to bumpSessionEnded: on
 * API delegate. Highly unlikely to happen while the custom UI is up, but provided as a convenience
 * just in case.
 */
-(void)bumpEndSessionCalled;

/**
 * Once the intial connection to the bump network has been made, there is a chance the connection
 * to the Bump Network is severed. In this case the bump network might come back, so it's
 * best to put the user back in the warming up state. If this happens too often then you can 
 * provide extra messaging and/or explicitly call endSession on the BumpAPI.
 */
-(void)bumpNetworkLost;

/**
 * Physical bump occurced. Update UI to tell user that a bump has occured and the Bump System is
 * trying to figure out who it matched with.
 */
-(void)bumpOccurred;

/**
 * Let's you know that a match could not be made via a bump. It's best to prompt users to try again.
 * @param		reason			Why the match failed
 */
-(void)bumpMatchFailedReason:(BumpMatchFailedReason)reason;

/**
 * The user should be presented with some data about who they matched, and whether they want to
 * accept this connection. (Pressing Yes/No should call confirmMatch:(BOOL) on the BumpAPI).
 * param		bumper			Information about the device the bump system mached with
 */
-(void)bumpMatched:(Bumper*)bumper;

/**
 * Called after both parties have pressed yes, and bumpSessionStartedWith:(Bumper) is about to be 
 * called on the API Delegate. You should now close the matching UI.
 */
-(void)bumpSessionStarted;

@end


@interface BumpAPI (CustomUI)

/**
 * <b>BumpAPI (CustomUI)</b> Must be called before requestSession on the API or else default UI will
 * pop up instead. The delegate is not retained.
 */
-(void)configUIDelegate:(id<BumpAPICustomUI, NSObject>)uiDelegate;

/**
 * <b>BumpAPI (CustomUI)</b> Action message as set by the configActionMessage: on the BumpAPI
 */
-(NSString*)actionMessage;

/**
 * <b>BumpAPI (CustomUI)</b> There may be a peroid in the presentation of the matching process where
 * you don't want to let the internal system register physical bumps and attempt to match with 
 * another device. Use this method to turn this registration of bumps on or off (default is on when
 * connected to be bump network). 
 *
 * Note: When you are in session, i.e. able to send data back and forth to another device, calling
 * setBumpable: will only save off your your preferences for when you reconnect to the Bump
 * Network after a subsequent requestSession call. The Bump system strictly disallows bumping
 * when you are in session with another user.
 * 
 * Bumpable means weather the Bump will try to detect the accelormeter shake to and try to match.
 */
-(void)setBumpable:(BOOL)canBump;

/**
 * <b>BumpAPI (CustomUI)</b> Tells the API that the other device the bump system mached this device
 * with is really the person that the Bump session should be started with.
 *
 * If NO is sent, the recommended behaviour take the user back to the "Ready to Bump" screen to let
 * the user bump again.
 */
-(void)confirmMatch:(BOOL)confirm;

/**
 * <b>BumpAPI (CustomUI)</b> If the you want to let the users cancel out of the match UI by pressing
 * an X or it's equivalent, let BumpAPI know that you not longer wish to continue the matching 
 * process. The recommended behaviour is to autoclose the bumping UI. To allow the user to have 
 * another try at bumping call requestSession on the API again.
 *
 * This will result in the bumpSessionFailedToStart:FAIL_USER_CANCELED on the BumpAPIDelegate.
 */
-(void)cancelMatching;

/**
 * <b>BumpAPI (CustomUI) - Debugging only</b> Use this to simulate a bump when you are debugging in 
 * the simulator. On the device this will become a no-op.
 */
-(void)simulateBump;

@end