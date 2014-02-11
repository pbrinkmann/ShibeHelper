//
//  DCMEditMiningPoolViewController.m
//  DogecoinManager
//
//  Created by Paul Brinkmann on 1/19/14.
//  Copyright (c) 2014 Paul Brinkmann. All rights reserved.
//

#import "DCMEditMiningPoolViewController.h"

#import "CDZQRScanningViewController.h"

@interface DCMEditMiningPoolViewController ()
@property (weak, nonatomic) IBOutlet UITextField *miningPoolWebsiteURLTextField;
@property (weak, nonatomic) IBOutlet UITextField *miningPoolAPIKeyTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@property (weak, nonatomic) IBOutlet UILabel *mposPoolsOnlyLabel;
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
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)openMPOSPoolList:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.doktorrf.com/dogecoin/pools.html"]];
    NSLog(@"touchy touchy");
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
    
    NSLog(@"URL: %@\nKEY: %@\nID: %@\n", [resultItems objectAtIndex:1],[resultItems objectAtIndex:2],[resultItems objectAtIndex:3] );
    
    NSString* url = [resultItems objectAtIndex:1];
    NSRange indexphpLocation =  [url rangeOfString:@"/index.php"];
    
    if(indexphpLocation.location == NSNotFound ) {
        // TODO: let the user know this
        NSLog(@"%@ doesn't look like a valid MPOS URL", url);
        return;
    }
    
    self.miningPoolWebsiteURLTextField.text = [url substringToIndex:indexphpLocation.location];
    self.miningPoolAPIKeyTextField.text = [resultItems objectAtIndex:2];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if(sender != self.doneButton ) {
        self.miningPoolWebsiteURL = nil;
        self.miningPoolAPIKey = nil;
        
        return;
    }
        
    if(self.miningPoolWebsiteURLTextField.text.length > 0) {
        self.miningPoolWebsiteURL = self.miningPoolWebsiteURLTextField.text;
        self.miningPoolAPIKey = self.miningPoolAPIKeyTextField.text;
    }
}

-(IBAction)miningPoolWebsiteURLChanged:(id)sender
{
    [self ensureHTTPOnWebsiteURL];
    
    [self validateCurrentValues];
    

}

-(IBAction)miningPoolAPIKeyChanged:(id)sender
{
    [self validateCurrentValues];
}

-(void)validateCurrentValues
{
    if( self.miningPoolWebsiteURLTextField.text.length < 9 || self.miningPoolAPIKeyTextField.text.length < 10) {
        self.doneButton.enabled = FALSE;
    }
    else {
        self.doneButton.enabled = TRUE;
        
    }
}


-(void)ensureHTTPOnWebsiteURL
{
    if( [self.miningPoolWebsiteURLTextField.text isEqualToString:@"http:/"] ) {
        self.miningPoolWebsiteURLTextField.text = @"http://";
    }
    else if( [self.miningPoolWebsiteURLTextField.text isEqualToString:@"https:/"] ) {
        self.miningPoolWebsiteURLTextField.text = @"https://";
    }
    else if ( ![self.miningPoolWebsiteURLTextField.text hasPrefix:@"http://"] && ![self.miningPoolWebsiteURLTextField.text hasPrefix:@"https://"] ) {
        self.miningPoolWebsiteURLTextField.text = [NSString stringWithFormat:@"http://%@", self.miningPoolWebsiteURLTextField.text ];
    }
}

-(void)dismissKeyboard
{
    [self.miningPoolWebsiteURLTextField resignFirstResponder];
    [self.miningPoolAPIKeyTextField resignFirstResponder];
}

@end
