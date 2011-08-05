//
//  TapViewController.h
//  Dwolla Tap
//
//  Created by James Armstead on 4/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BumpAPI.h"
#import "BumpAPICustomUI.h"
#import "BumpConnector.h"

@class TabViewController;

@protocol TapViewControllerDelegate
- (void)tapDidFinish:(TabViewController*)tapView;
@end


@interface TapViewController : UIViewController<UINavigationControllerDelegate, BumpAPICustomUI, BumpAPIDelegate> {    
    IBOutlet UIActivityIndicatorView *_spinner;
    
    IBOutlet UILabel *_bumpLabel;
    IBOutlet UILabel *_nameLabel;
    IBOutlet UILabel *_requestNameLabel;
    IBOutlet UILabel *_amountLabel;
    IBOutlet UILabel *_amountYouWantLabel;
    IBOutlet UILabel *_smallTextLabel;
    IBOutlet UILabel *_isRequestingLabel;
    IBOutlet UILabel *_errorLabel;
    IBOutlet UILabel *_successLabel;
    
    IBOutlet UIButton *_approveButton;
    IBOutlet UIButton *_cancelButton;
    
    IBOutlet UITextField *_amountText;
    id<TapViewControllerDelegate> delegate;
    IBOutlet UITextField *_pin;
    
    IBOutlet UIView *_send;
    IBOutlet UIView *_request;
    IBOutlet UIView *_requestWaiting;
    
    NSString *email;
    NSString *dwollaId;
    NSString *name;
    NSString *requesterName;
    NSString *requesterDwollaId;
    NSDecimalNumber *requestedAmount;
    bool sentSuccessful;
    
    BumpConnector *bumpObject;
}
- (IBAction)approveButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)cancelRequestPressed:(id)sender;
- (IBAction)simulateBumpButtonPressed:(id)sender;
- (IBAction)lostFocusAmountText:(id)sender;
- (IBAction)amountTextChanged:(id)sender;
- (IBAction)logoutButtonPressed:(id)sender;

@property (retain) id<TapViewControllerDelegate> delegate;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *dwollaId;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *requesterName;
@property (nonatomic, retain) NSString *requesterDwollaId;
@property (nonatomic, retain) NSDecimalNumber *requestedAmount;
@property (nonatomic) bool sentSuccessful;

@end
