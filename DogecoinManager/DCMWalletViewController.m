//
//  DCMWalletViewController
//  DogecoinManager
//
//  Created by Paul Brinkmann on 1/9/14.
//  Copyright (c) 2014 Paul Brinkmann. All rights reserved.
//

#import "DCMWalletViewController.h"

#import "DCMEditWalletAddressViewController.h"

@interface DCMWalletViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lastWalletUpdate;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editWalletAddressButton;

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
    
    aTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                              target:self
                                            selector:@selector(timerFired:)
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
    
    
    self.balance.text = [NSString stringWithFormat:@"%@Ɖ", self.wallet.balance];
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

-(void)timerFired:(NSTimer *) theTimer
{
    if(self.wallet.lastUpdate != nil) {
        NSTimeInterval timeSinceUpdate = [[theTimer fireDate] timeIntervalSinceDate:self.wallet.lastUpdate];
        if(timeSinceUpdate < 1 ) timeSinceUpdate = 1;
        
        if(timeSinceUpdate < 2)  {
            self.lastWalletUpdate.text = @"last updated 1 second  ago";
        }
        else if( timeSinceUpdate < 60 ) {
            self.lastWalletUpdate.text = [NSString stringWithFormat:@"last updated %d seconds ago", (int)timeSinceUpdate];
        }
        else if ( timeSinceUpdate < 120)  {
            self.lastWalletUpdate.text = @"last updated 1 minute ago";
        }
        else if ( timeSinceUpdate < 3600) {
            self.lastWalletUpdate.text = [NSString stringWithFormat:@"last updated %d minutes ago", (int)timeSinceUpdate/60];
        }
        else if ( timeSinceUpdate < 7200 ) {
            self.lastWalletUpdate.text = @"last updated 1 hour ago";
        }
        else {
            self.lastWalletUpdate.text = [NSString stringWithFormat:@"last updated %d hours ago", (int)timeSinceUpdate/3600];
        }
        
    }
}

@end
