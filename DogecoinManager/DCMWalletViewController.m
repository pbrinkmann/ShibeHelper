//
//  DCMWalletViewController
//  DogecoinManager
//
//  Created by Paul Brinkmann on 1/9/14.
//  Copyright (c) 2014 Paul Brinkmann. All rights reserved.
//

#import "DCMWalletViewController.h"

#import "DCMEditWalletAddressViewController.h"
#import "DCMUtils.h"

#import "HTProgressHUD.h"

@interface DCMWalletViewController ()

@property (weak, nonatomic) IBOutlet UILabel *lastWalletUpdateLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editWalletAddressButton;

@property (weak, nonatomic) IBOutlet UITextField *walletAddressTextfield;
@property (weak, nonatomic) IBOutlet UILabel *walletAddressTitleLabel;

// used to display error messages when wallet update failed
@property (weak, nonatomic) IBOutlet UILabel *walletUpdateFailedLabel;

@property (weak, nonatomic) IBOutlet UILabel *balance;
@property (weak, nonatomic) IBOutlet UILabel *balanceUSDLabel;

@end

@implementation DCMWalletViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.walletUpdateFailedLabel.hidden = YES;

    self.wallet = [[DCMWallet alloc] init];
    
    if (self.wallet.address != nil) {
        self.walletAddressTextfield.text = self.wallet.address;
        
        [self refreshViewLabels];
    }
    
    // hide wallet address on smaller devices
    if( ! [DCMUtils isTallDevice] ) {
        self.walletAddressTextfield.hidden = TRUE;
        self.walletAddressTitleLabel.hidden = TRUE;
    }
    
    [self updateWalletBalance];
    
    lastUpdatedTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                        target:self
                                                      selector:@selector(lastUpdatedTimerFired:)
                                                      userInfo:nil
                                                      repeats:YES];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)unwindToWalletBalance:(UIStoryboardSegue *)segue
{
    DCMEditWalletAddressViewController *source = [segue sourceViewController];
    
    if (source.walletAddress != nil) {
        self.walletAddressTextfield.text = source.walletAddress;
        self.wallet.address = source.walletAddress;
        
        [self updateWalletBalance];
    }
    else {
        NSLog(@"No new address entered");
    }
 }

-(IBAction)refreshWalletBalanceFromTouch:(id)sender
{
   [self updateWalletBalance];
}

-(void)updateWalletBalance {
    
    if( self.wallet.address == nil ) {
        NSLog(@"controller skipping wallet update - no addres");
        return;
    }
    
    HTProgressHUD *HUD = [[HTProgressHUD alloc] init];
    [HUD showInView:self.view];
    self.editWalletAddressButton.enabled = NO;
    
    self.walletUpdateFailedLabel.hidden = YES;
    
    dispatch_queue_t myQueue = dispatch_queue_create("Wallet Update Queue",NULL);
    dispatch_async(myQueue, ^{

        // synchronous update
        BOOL success = [self.wallet updateBalance];
        
        // must do UI updates on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [HUD hide];
            self.editWalletAddressButton.enabled = YES;
            
            if (success) {
                self.walletUpdateFailedLabel.hidden = YES;
            }
            else {
                self.walletUpdateFailedLabel.hidden = NO;
                return;
            }
            [self refreshViewLabels];
        });
    });
}

-(void)refreshViewLabels
{
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    [numberFormatter setCurrencySymbol:@"Ɖ"];
    
    NSString *balance = [numberFormatter stringFromNumber:self.wallet.balance];
    self.balance.text = balance;
    
    // we set the conversion rate to -1 if there was an error, so negative balance means something went wrong
    // In this case, just hide the USD balance display
    if( [self.wallet.balanceUSD floatValue] < 0) {
        self.balanceUSDLabel.hidden = YES;
    }
    else {
        self.balanceUSDLabel.hidden = NO;
        
        [numberFormatter setCurrencySymbol:@"$"];
        NSString *balanceUSD = [numberFormatter stringFromNumber:self.wallet.balanceUSD];
        self.balanceUSDLabel.text = [NSString stringWithFormat:@"(%@)",balanceUSD];
    }
    

}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if(sender != self.editWalletAddressButton ) return;
    
    DCMEditWalletAddressViewController *destination = (DCMEditWalletAddressViewController*)[[segue destinationViewController] visibleViewController];
    [destination updateDefaultWalletAddress:self.wallet.address];
}



-(void)lastUpdatedTimerFired:(NSTimer *) theTimer
{
    if(self.wallet.lastUpdate != nil) {
        NSTimeInterval timeSinceLastUpdate =[[theTimer fireDate] timeIntervalSinceDate:self.wallet.lastUpdate];
        self.lastWalletUpdateLabel.text = [DCMUtils lastUpdatedForInterval:timeSinceLastUpdate];
               
    }
}

@end
