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
@property (weak, nonatomic) IBOutlet UITextField *miningPoolAPIURLTextField;
@property (weak, nonatomic) IBOutlet UITextField *miningPoolAPIKeyTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

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

    if( self.miningPoolAPIURL  != nil ) {
        self.miningPoolAPIURLTextField.text = self.miningPoolAPIURL;
        self.miningPoolAPIKeyTextField.text = self.miningPoolAPIKey;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) updateDefaultMiningPoolAdress:(NSString*)defaultAPIUrl andKey:(NSString*)defaultAPIKey
{
    if( defaultAPIUrl != nil) {
        self.miningPoolAPIURL = defaultAPIUrl;
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
    
    self.miningPoolAPIURLTextField.text = [resultItems objectAtIndex:1];
    self.miningPoolAPIKeyTextField.text = [resultItems objectAtIndex:2];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if(sender != self.doneButton ) {
        self.miningPoolAPIURL = nil;
        self.miningPoolAPIKey = nil;
        
        return;
    }
        
    if(self.miningPoolAPIURLTextField.text.length > 0) {
        self.miningPoolAPIURL = self.miningPoolAPIURLTextField.text;
        self.miningPoolAPIKey = self.miningPoolAPIKeyTextField.text;
    }
}

@end
