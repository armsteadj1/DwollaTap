//
//  TapViewController.m
//  Dwolla Tap
//
//  Created by James Armstead on 4/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TapViewController.h"
#import "BumpAPI.h"

static NSString *const kOAuthConsumerKey     = @"";
static NSString *const kOAuthConsumerSecret  = @"";
static NSString *const dwollaProviderStore = @"Dwolla";
static NSString *const dwollaPrefixStore = @"Demo";

@implementation TapViewController

@synthesize delegate, email, dwollaId, name, requesterName, requestedAmount, requesterDwollaId, sentSuccessful;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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

- (void)viewWillAppear:(BOOL)animated{
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [self startLogin];
    //[[BumpConnector instance] startBump];
}

- (void)viewDidLoad
{
    [_spinner stopAnimating];
    [super viewDidLoad];
    _send.backgroundColor = [UIColor clearColor];
    _request.backgroundColor = [UIColor clearColor];
    _requestWaiting.backgroundColor = [UIColor clearColor];
    BumpConnector *bc = [BumpConnector instance];
    bc.tapView = self;
}

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

- (IBAction)simulateBumpButtonPressed:(id)sender {
    [[[BumpConnector instance] getBump] simulateBump];
}

/**
 * Result of requestSession on BumpAPI (user wants to connect to another device via Bump). UI should
 * now first appear saying something like "Warming up".
 */
-(void)bumpRequestSessionCalled {
	[_bumpLabel setText:@"Warming up bump!"];
}

/**
 * We were unable to establish a connection to the Bump network. Either show an error message or
 * hide the popup. The BumpAPIDelegate is about to be called with bumpSessionFailedToStart.
 */
-(void)bumpFailedToConnectToBumpNetwork {
	[_bumpLabel setText:@"Still warming up bump..."];
	[[BumpConnector instance] startBump];
}


/**
 * We were able to establish a connection to the Bump network and you are now ready to bump. 
 * The UI should say something like "Ready to Bump".
 */
-(void)bumpConnectedToBumpNetwork {
    [BumpConnector instance].sessionStarted = true;
    [_spinner stopAnimating];
    if (sentSuccessful) { 
        [_successLabel setText:@"Transaction Successful! Ready to Bump again!"];
        [_errorLabel setText:@""];
        sentSuccessful = false;
    }
    [_bumpLabel setText:@"Enter an Amount, then Bump!"];
	
    _amountText.text = @"";
    _send.hidden = false;
    _request.hidden = true;
    _requestWaiting.hidden = true;
    self.requesterName = @"";
    self.requesterDwollaId = @"";
    self.requestedAmount = 0;
}

/**
 * Result of endSession call on BumpAPI. Will soon be followed by the call to bumpSessionEnded: on
 * API delegate. Highly unlikely to happen while the custom UI is up, but provided as a convenience
 * just in case.
 */
-(void)bumpEndSessionCalled {
	[_bumpLabel	 setText:@"End Session was called.. retrying.."];
}

/**
 * Once the intial connection to the bump network has been made, there is a chance the connection
 * to the Bump Network is severed. In this case the bump network might come back, so it's
 * best to put the user back in the warming up state. If this happens too often then you can 
 * provide extra messaging and/or explicitly call endSession on the BumpAPI.
 */
-(void)bumpNetworkLost {
    [_spinner startAnimating];
	[_bumpLabel setText:@"Warming up again..."];
}

/**
 * Physical bump occurced. Update UI to tell user that a bump has occured and the Bump System is
 * trying to figure out who it matched with.
 */
-(void)bumpOccurred {
    [_spinner startAnimating];
	[_bumpLabel setText:@"Bumped! Trying to connect..."];
    [_amountText resignFirstResponder];
}

/**
 * Let's you know that a match could not be made via a bump. It's best to prompt users to try again.
 * @param		reason			Why the match failed
 */
-(void)bumpMatchFailedReason:(BumpMatchFailedReason)reason {
    [_spinner stopAnimating];
	[_bumpLabel setText:@"Bump failed, bump again! Verify GPS is on."];
}

/**
 * The user should be presented with some data about who they matched, and whether they want to
 * accept this connection. (Pressing Yes/No should call confirmMatch:(BOOL) on the BumpAPI).
 * param		bumper			Information about the device the bump system mached with
 */
-(void)bumpMatched:(Bumper*)bumper {
	[_spinner stopAnimating];
	[[[BumpConnector instance] getBump] confirmMatch:YES];
}

/**
 * Called after both parties have pressed yes, and bumpSessionStartedWith:(Bumper) is about to be 
 * called on the API Delegate. You should now close the matching UI.
 */
-(void)bumpSessionStarted {
    [_successLabel setText:@""];
    [_spinner startAnimating];
	[_bumpLabel setText:@"Transfering data..."];
    
    NSMutableDictionary *moveDict = [[NSMutableDictionary alloc] initWithCapacity:3];
    [moveDict setObject:self.name  forKey:@"NAME"];
    
    if([_amountText.text length] > 0) {
        [moveDict setObject:@"true"  forKey:@"SENDING"];
    } else {
        NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithString:_amountText.text];
        if([amount isEqualToNumber:[NSDecimalNumber notANumber]] == true) {
            amount = 0;
        }
        [moveDict setObject:@"true"  forKey:@"WAITING"];
        [moveDict setObject:self.dwollaId  forKey:@"DWOLLAID"];
        
        _send.hidden = true;
        _request.hidden = true;
        _requestWaiting.hidden = false;
    }
    
    //Now we need to package our move dictionary up into an NSData object so we can send it up to Bump.
    //We'll do that with with an NSKeyedArchiver.
    NSData *moveChunk = [NSKeyedArchiver archivedDataWithRootObject:moveDict];
    
    [[[BumpConnector instance] getBump] sendData:moveChunk];
}

-(void)sendSuccess {    
    NSMutableDictionary *moveDict = [[NSMutableDictionary alloc] initWithCapacity:3];
    [moveDict setObject:@"true"  forKey:@"SUCCESS"];
    NSData *moveChunk = [NSKeyedArchiver archivedDataWithRootObject:moveDict];
    
    [[[BumpConnector instance] getBump] sendData:moveChunk];
}

#pragma mark *********************** API Delegate

/**
 Successfully started a Bump session with another device.
 @param		otherBumper		Let's you know how the other device identifies itself
 Can also be accessed later via the otherBumper method on the API
 */
- (void) bumpSessionStartedWith:(Bumper *)otherBumper {
    
}
/**
 There was an error while trying to start the session these reasons are helpful and let you know
 what's going on
 @param		reason			Why the session failed to start
 */
- (void) bumpSessionFailedToStart:(BumpSessionStartFailedReason)reason {
	[_spinner stopAnimating];
    [_bumpLabel setText:@"Hrm. Error. Please login again."];
}

/**
 The bump session was ended, reason tells you wheter it was expected or not
 @param		reason			Why the session ended. Could be either expected or unexpected.
 */
- (void) bumpSessionEnded:(BumpSessionEndReason)reason {
    [_spinner stopAnimating];
	NSLog(@"Session has ended, requesting a new one");
    [BumpConnector instance].sessionStarted = false;
	[[BumpConnector instance] startBump];//auto request a new session since we always want
    //to be doing something
}

/**
 The symmetrical call to sendData on the API. When the other device conneced via Bump calls sendData
 this device get's this call back
 @param		reason			Data sent by the other device.
 */
- (void) bumpDataReceived:(NSData *)chunk {
    NSDictionary *responseDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:chunk];
	_approveButton.enabled = true;
    
    [_errorLabel setText:@""];
    [_bumpLabel setText:@""];
    NSDecimalNumber *amount;
    if([_amountText.text length] != 0) {
        amount = [NSDecimalNumber decimalNumberWithString:_amountText.text];
    } else {
        amount = 0;
    }
        
    NSDecimalNumber *one = [NSDecimalNumber decimalNumberWithString:@"1.0f"];
    if([[responseDictionary objectForKey:@"WAITING"] length] != 0) {
        if ([_amountText.text length] == 0) {
            [_errorLabel setText:@"One of you needs to enter an Amount."];
            [[BumpConnector instance] stopBump];
        } else if ([amount compare:one] == NSOrderedAscending) {
            [_errorLabel setText:@"Enter an amount to send above $.99."];
            [[BumpConnector instance] stopBump]; 
        } else {
            [_bumpLabel setText:@""];
                
            NSDecimalNumber *askedAmount = [NSDecimalNumber decimalNumberWithString: _amountText.text];
                
            _send.hidden = true;
            _request.hidden = false;
            _requestWaiting.hidden = true;
                
            [_nameLabel setText: [responseDictionary objectForKey:@"NAME"]];
            [_amountLabel setText: [NSString stringWithFormat:@"$%@",[askedAmount stringValue]]];
            
            self.requesterName = [responseDictionary objectForKey:@"NAME"];
            self.requesterDwollaId = [responseDictionary objectForKey:@"DWOLLAID"];
            self.requestedAmount = askedAmount;
        }
    } else if([[responseDictionary objectForKey:@"SUCCESS"] length] != 0) {
        sentSuccessful = true;
        [[BumpConnector instance] stopBump];
    } else if([[responseDictionary objectForKey:@"SENDING"] length] != 0) {
        if (!([_amountText.text length] == 0 || amount < one)) {
            [_errorLabel setText:@"Only one can send an amount."];
            [_amountText setText:@""];
            [[BumpConnector instance] stopBump];
        } else {
            [_requestNameLabel setText:[responseDictionary objectForKey:@"NAME"]];
        }
    }
    
    [_spinner stopAnimating];
}

- (IBAction)lostFocusAmountText:(id)sender {
    [_amountText resignFirstResponder];
}

- (IBAction)cancelButtonPressed:(id)sender {
    [_pin resignFirstResponder];
    [_spinner startAnimating];
    [[BumpConnector instance] stopBump];
}

- (IBAction)cancelRequestPressed:(id)sender {
    [_spinner startAnimating];
    [[BumpConnector instance] stopBump];
}

- (IBAction)approveButtonPressed:(id)sender {
    [_pin resignFirstResponder];
    [_spinner startAnimating];
    
    [dwollaEngine sendMoneyWithPin:[_pin text] withDestinationId:[self requesterDwollaId] withAmount:[self requestedAmount] withNotes:@"TAP TAP!" withDestinationType:@"dwolla" withAssumeCost:false withFundsSource:@"balance"];
    
    _pin.text = @"";
    _approveButton.enabled = false;
}

- (IBAction) amountTextChanged:(id)sender;
{
    [_successLabel setText:@""];
    NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithString:_amountText.text];
    NSDecimalNumber *one = [NSDecimalNumber decimalNumberWithString:@"1"];
    NSDecimalNumber *cents = [NSDecimalNumber decimalNumberWithString:@".99"];
    
    if([_amountText.text length] != 0 && [amount compare:one] == NSOrderedAscending) {
        [_errorLabel setText:@"Amount should be higher than $.99"];        
        [_amountText setTextColor:[UIColor redColor]]; 
    } else if (([amount isEqualToNumber:[NSDecimalNumber notANumber]] == false && [amount compare:cents] == NSOrderedDescending) || [_amountText.text length] == 0) {
        
        if(_errorLabel.text == @"Amount should be higher than $.99" || _errorLabel.text == @"Amount is invalid.") {
            [_errorLabel setText:@""];
        }
        [_amountText setTextColor:[UIColor blackColor]];
    } else {
        [_errorLabel setText:@"Amount is invalid."];        
        [_amountText setTextColor:[UIColor redColor]]; 
    }
}

- (IBAction)logoutButtonPressed:(id)sender {
    dwollaEngine = nil;
    [dwollaEngine release];
    [DwollaToken removeFromUserDefaultsWithServiceProviderName:dwollaProviderStore prefix:dwollaPrefixStore];
    
    [self startLogin];
}


- (void) changeView:(int)viewId {
    _send.hidden = (viewId != 1);
    _request.hidden = (viewId != 2);
    _requestWaiting.hidden = (viewId != 3);
}



#pragma mark -
#pragma mark DwollaEngineDelegate

- (void)dwollaEngineAccessToken:(DwollaOAuthEngine *)engine setAccessToken:(DwollaToken *)token {
	[token storeInUserDefaultsWithServiceProviderName:dwollaProviderStore prefix:dwollaPrefixStore];
}

- (OAToken *)dwollaEngineAccessToken:(DwollaOAuthEngine *)engine {
    return [[[DwollaToken alloc] initWithUserDefaultsUsingServiceProviderName:dwollaProviderStore prefix:dwollaPrefixStore] autorelease];
}

- (void)dwollaEngine:(DwollaOAuthEngine *)engine requestSucceeded:(DwollaConnectionID *)identifier withResults:(id)results {
    if ([[results objectForKey:@"Name"] length] > 0) {
        [self setName:[results objectForKey:@"Name"]];
        [self setDwollaId:[results objectForKey:@"Id"]];
    } else {
        _approveButton.enabled = true;
        [_spinner stopAnimating];
        [self sendSuccess];
        sentSuccessful = true;
        //Start a new session
        [[BumpConnector instance] stopBump]; 
    }
}

- (void)dwollaEngine:(DwollaOAuthEngine *)engine requestFailed:(DwollaConnectionID *)identifier withError:(NSError *)error {
    _approveButton.enabled = true;
    [_spinner stopAnimating];

    _pin.text = @"";
    if([[error domain] isEqualToString: @"INSUFFICIENT_FUNDS"]) {
        [_errorLabel setText:@"Insufficient Funds!"];
    } else if([[error domain] isEqualToString:@"INVALID_ACCOUNT_PIN"]){
        [_errorLabel setText:@"Invalid PIN, please try again!"];   
    } else {
        [_errorLabel setText:@"Amount should be higher than $.99"];
    }
}

#pragma mark -
#pragma mark DwollaAuthorizationControllerDelegate

- (void)dwollaAuthorizationControllerSucceeded:(DwollaAuthorizationController *)controller {
    NSLog(@"Authentication succeeded.");
}

- (void)dwollaAuthorizationControllerFailed:(DwollaAuthorizationController *)controller {
    NSLog(@"Authentication failed!");
}

- (void)dwollaAuthorizationControllerCanceled:(DwollaAuthorizationController *)controller {
    NSLog(@"Authentication was cancelled.");
}

-(void) createEngine
{
    if (dwollaEngine == nil) {
        dwollaEngine = [[DwollaOAuthEngine 
                         engineWithConsumerKey:kOAuthConsumerKey 
                         consumerSecret:kOAuthConsumerSecret 
                         scope: @"AccountAPI:AccountInfoFull|AccountAPI:Send"
                         callback: @"http://www.kwekenstudios.com/loadingDwolla.html" //Needs 'http://' and also trailing '/'
                         delegate:self] retain];   
    }
}


-(void) openLoginView
{
    controller = [DwollaAuthorizationController authorizationControllerWithEngine:dwollaEngine delegate:self];
    if( controller ) {
        [self presentModalViewController:controller animated:YES];
    }
}

-(void) startLogin 
{
    [self createEngine];
    if ([dwollaEngine isAuthorized] == false) {
        [self openLoginView];
    } else {
        [dwollaEngine accountInformationCurrentUser];
    }
}

@end
