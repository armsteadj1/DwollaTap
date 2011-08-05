//
//  Dwolla_TapViewController.h
//  Dwolla Tap
//
//  Created by James Armstead on 4/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TapViewController.h"

@interface Dwolla_TapViewController : UIViewController<TapViewControllerDelegate, UINavigationControllerDelegate> {
    IBOutlet UIActivityIndicatorView *_spinner;
    
    IBOutlet UILabel *_error;
    IBOutlet UIButton *_signInButton;
    IBOutlet UITextField *_usernameText;
    IBOutlet UITextField *_passwordText;
}

- (IBAction)signInButtonPressed:(id)sender;
@end