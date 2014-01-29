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

@interface DCMWalletViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lastWalletUpdateLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editWalletAddressButton;
@property (weak, nonatomic) IBOutlet UITextField *walletAddressTextfield;

@property (weak, nonatomic) IBOutlet UILabel *balance;
@property (weak, nonatomic) IBOutlet UILabel *balanceUSDLabel;


@end

@implementation DCMWalletViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.wallet = [[DCMWallet alloc] init];
    
    if (self.wallet.address != nil) {
        self.walletAddressTextfield.text = self.wallet.address;
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
    NSLog(@"User left wallet address edit view");
    
    DCMEditWalletAddressViewController *source = [segue sourceViewController];
    
    if (source.walletAddress != nil) {
        NSLog(@"Looks like we have a new address");
        self.walletAddressTextfield.text = source.walletAddress;
        self.wallet.address = source.walletAddress;
        
        [self updateWalletBalance];
    }
    else {
        NSLog(@"No new address entered");
    }
 }

-(void)updateWalletBalance {
    [self.wallet updateBalance];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    [numberFormatter setCurrencySymbol:@"Ɖ"];
    
    NSString *balance = [numberFormatter stringFromNumber:self.wallet.balance];
    self.balance.text = balance;

    [numberFormatter setCurrencySymbol:@"$"];
    NSString *balanceUSD = [numberFormatter stringFromNumber:self.wallet.balanceUSD];
    self.balanceUSDLabel.text = [NSString stringWithFormat:@"(%@)",balanceUSD];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if(sender != self.editWalletAddressButton ) return;
    
    DCMEditWalletAddressViewController *destination = (DCMEditWalletAddressViewController*)[[segue destinationViewController] visibleViewController];
    [destination updateDefaultWalletAddress:self.wallet.address];
}


-(IBAction)refreshBalance:(id)sender
{
    [self updateWalletBalance];
}

-(void)lastUpdatedTimerFired:(NSTimer *) theTimer
{
    if(self.wallet.lastUpdate != nil) {
        NSTimeInterval timeSinceLastUpdate =[[theTimer fireDate] timeIntervalSinceDate:self.wallet.lastUpdate];
        self.lastWalletUpdateLabel.text = [DCMUtils lastUpdatedForInterval:timeSinceLastUpdate];
               
    }
}

@end
