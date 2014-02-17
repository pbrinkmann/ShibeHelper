//
//  DCMEditMiningPoolViewController.m
//  DogecoinManager
//
//  Created by Paul Brinkmann on 1/19/14.
//  Copyright (c) 2014 Paul Brinkmann. All rights reserved.
//

#import "DCMEditMiningPoolViewController.h"
#import "DCMMiningPool.h"

#import "CDZQRScanningViewController.h"
#import "HTProgressHUD.h"
#import "HTProgressHUDFadeZoomAnimation.h"
#import "HTProgressHUDPieIndicatorView.h"
#import "KeyboardStateListener.h"

@interface DCMEditMiningPoolViewController ()
@property (weak, nonatomic) IBOutlet UITextField *miningPoolWebsiteURLTextField;
@property (weak, nonatomic) IBOutlet UITextField *miningPoolAPIKeyTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;

@property (weak, nonatomic) IBOutlet UILabel *mposPoolsOnlyLabel;

// When doing URL validation, what was the last URL we checked
@property (strong, nonatomic) NSString* lastCheckedMiningPoolWebsiteURL;

@end

@implementation DCMEditMiningPoolViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.lastCheckedMiningPoolWebsiteURL = nil;

    
    if( self.miningPoolWebsiteURL  != nil ) {
        self.miningPoolWebsiteURLTextField.text = self.miningPoolWebsiteURL;
        self.miningPoolAPIKeyTextField.text = self.miningPoolAPIKey;
    }
    
    // wire up fake link behavior
    self.mposPoolsOnlyLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openMPOSPoolList:)];
    [self.mposPoolsOnlyLabel addGestureRecognizer:gr];
    gr.numberOfTapsRequired = 1;
    
    // dismiss keyboard when tap outside of text field
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(tapHandler)];
    
    [self.view addGestureRecognizer:tap];
    
}

// If top-level view touched, close keyboard and validate URL
-(void)tapHandler
{
    if( [KeyboardStateListener sharedInstance].isVisible ) {
        [self dismissKeyboard];
        [self validateURL];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)openMPOSPoolList:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.doktorrf.com/dogecoin/pools.html"]];
}

-(void) updateDefaultMiningPoolAdress:(NSString*)defaultAPIUrl andKey:(NSString*)defaultAPIKey
{
    if( defaultAPIUrl != nil) {
        self.miningPoolWebsiteURL = defaultAPIUrl;
        self.miningPoolAPIKey = defaultAPIKey;
    }
}


- (IBAction)scanMiningPoolAPIKeyQRCode:(id)sender
{
    [CDZQRScanningViewController scanWithCallback:^(NSString* result) { [self updateMiningInfoWithScan:result];} fromViewController:self];

}

-(void)updateMiningInfoWithScan:(NSString*)result
{
    // so actualy, we need to do some processing on the value, because it seems to be in the format of:
    
    // | api base url                         | api key                                                        | user id |

    // |http://teamdoge.com/index.php?page=api|042942b4863c05351976f0e779dc15a076e70a12a1d75371a3c512c0c33872d7|1727|
    
    NSArray *resultItems = [result componentsSeparatedByString:@"|"];
    
    DLog(@"URL: %@\nKEY: %@\nID: %@\n", [resultItems objectAtIndex:1],[resultItems objectAtIndex:2],[resultItems objectAtIndex:3] );
    
    NSString* url = [resultItems objectAtIndex:1];
    NSRange indexphpLocation =  [url rangeOfString:@"/index.php"];
    
    if(indexphpLocation.location == NSNotFound ) {
        // TODO: let the user know this
        DLog(@"%@ doesn't look like a valid MPOS URL", url);
        return;
    }
    
    self.miningPoolWebsiteURLTextField.text = [url substringToIndex:indexphpLocation.location];
    self.miningPoolAPIKeyTextField.text = [resultItems objectAtIndex:2];
    
}
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    // only validate when done button pressed
    if( sender != self.doneButton ) return TRUE;
    
    //  Close the keyboard and validate URL if the keyboard is visible
    if( [KeyboardStateListener sharedInstance].isVisible ) {
        [self dismissKeyboard];
        DLog(@"ecalling validate now")

        [self validateURLAndSegueBack:TRUE];
        DLog(@"exiting shoudl perform segue")
        return FALSE;
    }
    else {
        return TRUE;
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if(sender == self.cancelButton ) {
        self.miningPoolWebsiteURL = nil;
        self.miningPoolAPIKey = nil;
        
        return;
    }
        
    if(self.miningPoolWebsiteURLTextField.text.length > 0) {
        self.miningPoolWebsiteURL = [self.miningPoolWebsiteURLTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        self.miningPoolAPIKey =     [self.miningPoolAPIKeyTextField.text     stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
}

-(IBAction)miningPoolWebsiteURLChanged:(id)sender
{
    [self validateCurrentValues];
}

-(IBAction)miningPoolAPIKeyChanged:(id)sender
{
    [self validateCurrentValues];
}

-(void)validateCurrentValues
{
    if( self.miningPoolWebsiteURLTextField.text.length < 9 || self.miningPoolAPIKeyTextField.text.length < 15) {
        self.doneButton.enabled = FALSE;
    }
    else {
        self.doneButton.enabled = TRUE;
        
    }
}


-(void)ensureHTTPOnWebsiteURL
{
    if (   ![self.miningPoolWebsiteURLTextField.text hasPrefix:@"http://"]
        && ![self.miningPoolWebsiteURLTextField.text hasPrefix:@"https://"] ) {
        self.miningPoolWebsiteURLTextField.text = [NSString stringWithFormat:@"http://%@", self.miningPoolWebsiteURLTextField.text ];
    }
}

-(void)dismissKeyboard
{
    [self.miningPoolWebsiteURLTextField resignFirstResponder];
    [self.miningPoolAPIKeyTextField resignFirstResponder];
}

-(IBAction)validateURLAfterEditDone:(id)sender
{
    [self validateURL];
}

-(void)validateURL
{
    [self validateURLAndSegueBack:FALSE];
}

-(void)validateURLAndSegueBack:(BOOL)doSegue
{
    if( self.lastCheckedMiningPoolWebsiteURL != nil && [self.lastCheckedMiningPoolWebsiteURL isEqualToString:self.miningPoolWebsiteURLTextField.text] ) {
        DLog("no validation needed since URL hasn't changed");
        return;
    }
    
    [self ensureHTTPOnWebsiteURL];
    
    self.lastCheckedMiningPoolWebsiteURL  = self.miningPoolWebsiteURLTextField.text;
    
    self.doneButton.enabled = NO;
    self.cancelButton.enabled = NO;

    
    __block HTProgressHUD *HUD = [[HTProgressHUD alloc] init];
    [HUD showInView:self.view];
    
    dispatch_queue_t myQueue = dispatch_queue_create("Mining Pool Validation Queue",NULL);
    dispatch_async(myQueue, ^{
        HUD.text = @"validating URL";

        // synchronous call
        NSString* error = [DCMMiningPool checkForValidURL:self.miningPoolWebsiteURLTextField.text];

        
        // must do UI updates on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [HUD hide];
            
            // set value of Done button
            [self validateCurrentValues];
            self.cancelButton.enabled = YES;

            
            if (error != nil) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Possible Invalid URL"
                                                                message:error
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            else if(doSegue) {
                DLog(@"rewind!");
                [self performSegueWithIdentifier:@"unwindToMiningPool" sender:self];
            }
        });
    });
}


@end
