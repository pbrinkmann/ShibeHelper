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
    
    
    if (self.walletAddress != nil) {
        self.walletAddressTextField.text = self.walletAddress;
    }
    
}

-(void)updateDefaultWalletAddress:(NSString*) defaultWalletAddress
{
    
    if( defaultWalletAddress != nil) {
        NSLog(@"updating with %@", defaultWalletAddress);

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
        NSLog(@"setting wallet address");
        self.walletAddress = self.walletAddressTextField.text;
    }
}

-(IBAction)startScan:(id)sender
{
    [CDZQRScanningViewController scanIntoTextField:self.walletAddressTextField fromViewController:self];
}



@end
