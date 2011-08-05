//
//  Dwolla_TapViewController.m
//  Dwolla Tap
//
//  Created by James Armstead on 4/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Dwolla_TapViewController.h"
#import "RestKit.h"
#import "TapViewController.h"
#import "SFHFKeychainUtils.h"
#import "BumpConnector.h"

@implementation Dwolla_TapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSError *error = nil;
    _usernameText.text = [SFHFKeychainUtils getPasswordForUsername:@"dwollaEmail" andServiceName:@"dwolla-tap" error:&error];
    _passwordText.text = [SFHFKeychainUtils getPasswordForUsername:_usernameText.text andServiceName:@"dwolla-tap" error:&error];
    _passwordText.delegate = self;
    
    RKClient* client = [RKClient clientWithBaseURL:@"https://www.dwolla.com/rest/mobile.svc/"];
    [client setValue:@"applicati/json" forHTTPHeaderField:@"CONTENT-TYPE"];

    if ([_passwordText.text length] != 0) {
        [self signInButtonPressed: _passwordText]; 
    }
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)signInButtonPressed:(id)sender {    
    bool success = false;
    const char *host_name = [@"dwolla.com" 
                             cStringUsingEncoding:NSASCIIStringEncoding];
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL,
                                                                                host_name);
    SCNetworkReachabilityFlags flags;
    success = SCNetworkReachabilityGetFlags(reachability, &flags);
    bool isAvailable = success && (flags & kSCNetworkFlagsReachable) && 
    !(flags & kSCNetworkFlagsConnectionRequired);
    if (isAvailable) {
        if ([_passwordText.text length] == 0 || [_usernameText.text length] == 0) {
            [_error setText:@"Please set both Username and Password."];
            return;
        }
        NSURL* URL = [NSURL URLWithString:@"https://www.dwolla.com/rest/mobile.svc/account_information"];
        
        NSString* JSON = [NSString stringWithFormat:@"{\"APIUsername\": \"Lgq3P3v1lmt8TkG7k8nZmaq7r\", \"APIPassword\": \"FwCg3flyFZHGXUCcQ46o3zUgd\", \"AccountIdentifier\": \"%@\", \"Password\": \"%@\"}", _usernameText.text, _passwordText.text]; 
        
        RKRequest* request = [[RKRequest alloc] initWithURL:URL delegate:self]; 
        request.method = RKRequestMethodPOST; 
        request.additionalHTTPHeaders = [NSDictionary dictionaryWithObjectsAndKeys:
                                         @"application/json",@"Content-Type", 
                                         nil];
        [request.URLRequest setHTTPBody:[JSON dataUsingEncoding: 
                                         NSASCIIStringEncoding]]; 
        [request send]; 
        if([_error.text isEqualToString: @"We are logging you in, please be patient."]) {
            [_error setText:@"Dwolla Server must be a bit slow, we promise you will get logged in!."];
        } else {
            [_error setText:@"We are logging you in, please be patient."];
        }
        
        [_spinner startAnimating];

    }else{
        [_error setText:@"Dwolla is not reachable."];
    }
}

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response { 
        [_spinner stopAnimating];

        NSDictionary *result = [[response bodyAsJSON] valueForKeyPath:@"AccountInformationResult"];
    
        if ([[result valueForKeyPath:@"Id"] length] == 0)
        {
            _error.text = @"Invalid Credentials";   
            _passwordText.text = @"";
        } else {
            NSError *error = nil;
            [SFHFKeychainUtils storeUsername:_usernameText.text andPassword:_passwordText.text forServiceName:@"dwolla-tap" updateExisting:YES error:&error]; 
            [SFHFKeychainUtils storeUsername:@"dwollaEmail" andPassword:_usernameText.text forServiceName:@"dwolla-tap" updateExisting:YES error:&error];
            
            [_error setText:@""];
            _passwordText.text = @"";
            
            TapViewController *lf = [[TapViewController alloc]initWithNibName:@"TapViewController" bundle:nil];
            lf.delegate = self;
            lf.email = _usernameText.text;
            lf.dwollaId = [result valueForKeyPath:@"Id"];
            lf.name = [result valueForKeyPath:@"Name"];
            lf.modalPresentationStyle =  UIModalTransitionStyleCrossDissolve;
            
            BumpConnector *bc = [BumpConnector instance];
            bc.tapView = lf;
            
            [self presentModalViewController:lf animated:YES];
        }
    [request release];
}

- (void)loginFormDidFinish:(TapViewController*)tapView {
    // do whatever, then
    // hide the modal view
    [self dismissModalViewControllerAnimated:YES];
    // clean up
    [tapView release];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [theTextField resignFirstResponder];
    [self signInButtonPressed: _passwordText];
    return YES;
}

-(void)tapDidFinish:(TabViewController *)tapView{
    
}

@end
