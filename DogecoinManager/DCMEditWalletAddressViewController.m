//
//  DCMEditWalletAddressViewController.m
//  DogecoinManager
//
//  Created by Paul Brinkmann on 1/16/14.
//  Copyright (c) 2014 Paul Brinkmann. All rights reserved.
//

#import "DCMEditWalletAddressViewController.h"

#import "CDZQRScanningViewController.h"

@interface DCMEditWalletAddressViewController ()

@property (weak, nonatomic) IBOutlet UITextField *walletAddressTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;

@property (weak, nonatomic) IBOutlet UILabel *walletAddressErrorLabel;


@end

@implementation DCMEditWalletAddressViewController

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
	// Do any additional setup after loading the view.
    
    self.walletAddressErrorLabel.hidden = YES;
    
    if (self.walletAddress != nil) {
        self.walletAddressTextField.text = self.walletAddress;
    }
    
    // dismiss keyboard when tap outside of text field
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
}

- (IBAction)walletAddressChanged:(id)sender
{
    [self doWalletAddressValidation];
}

- (void)doWalletAddressValidation
{

    NSString *newWalletAddress =self.walletAddressTextField.text;
    DLog(@"wallet address now: %@", newWalletAddress);
    
    if( ! [newWalletAddress hasPrefix: @"D"] ) {
        self.walletAddressErrorLabel.text =  @"Address does not start with D";
        self.walletAddressErrorLabel.hidden = NO;
        self.doneButton.enabled = NO;
        return;
    }

    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^[123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz]+$"
                                                                           options:0
                                                                             error:&error];
    NSUInteger numMatches = [regex numberOfMatchesInString:newWalletAddress
                                                   options:0
                                                     range:NSMakeRange(0, [newWalletAddress length])];
    
    if (numMatches == 0) {
        self.walletAddressErrorLabel.text = @"Invalid character in wallet address";
        self.walletAddressErrorLabel.hidden = NO;
        self.doneButton.enabled = NO;
        return;
    }
  
    
    if ( newWalletAddress.length != 34) {
        self.walletAddressErrorLabel.text = @"Address not correct length";
        self.walletAddressErrorLabel.hidden = NO;
        self.doneButton.enabled = NO;
        return;
    }

    self.walletAddressErrorLabel.hidden = YES;
    self.doneButton.enabled = YES;
}

-(void)updateDefaultWalletAddress:(NSString*) defaultWalletAddress
{
    
    if( defaultWalletAddress != nil) {
        DLog(@"updating with %@", defaultWalletAddress);

        self.walletAddress=defaultWalletAddress;

    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if(sender != self.doneButton ) {
        self.walletAddress = nil;
        return;
    }
    
    if(self.walletAddressTextField.text.length > 0) {
        DLog(@"setting wallet address");
        self.walletAddress = self.walletAddressTextField.text;
    }
}

-(IBAction)startScan:(id)sender
{
    [CDZQRScanningViewController scanIntoTextField:self.walletAddressTextField fromViewController:self withValidationCallback:^{[self doWalletAddressValidation];} ];
}


-(void)dismissKeyboard
{
    [self.walletAddressTextField resignFirstResponder];
}

@end
