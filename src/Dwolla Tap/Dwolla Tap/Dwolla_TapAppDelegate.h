//
//  Dwolla_TapAppDelegate.h
//  Dwolla Tap
//
//  Created by James Armstead on 4/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Dwolla_TapViewController;

@interface Dwolla_TapAppDelegate : NSObject <UIApplicationDelegate> {
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet Dwolla_TapViewController *viewController;

@end
