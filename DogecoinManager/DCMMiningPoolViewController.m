//
//  DCMMiningPoolViewController
//  DogecoinManager
//
//  Created by Paul Brinkmann on 1/9/14.
//  Copyright (c) 2014 Paul Brinkmann. All rights reserved.
//

#import "DCMMiningPoolViewController.h"
#import "DCMEditMiningPoolViewController.h"

@interface DCMMiningPoolViewController ()

@property (weak, nonatomic) IBOutlet UILabel *miningPoolNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *hashrateLabel;
@property (weak, nonatomic) IBOutlet UILabel *validSharesLabel;
@property (weak, nonatomic) IBOutlet UILabel *invalidSharesLabel;
@property (weak, nonatomic) IBOutlet UILabel *confirmedBalanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *unconfirmedBalanceLabel;

@end

@implementation DCMMiningPoolViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.miningPool = [[DCMMiningPool alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)doRefresh:(id)sender
{
    [self updateMiningPoolInfo];
}

- (IBAction)unwindToMiningPool:(UIStoryboardSegue *)segue
{
    NSLog(@"User left mining pool edit view");
    
    DCMEditMiningPoolViewController *source = [segue sourceViewController];
    
    if (source.miningPoolAPIKey != nil) {
        NSLog(@"Looks like we have a new mining pool API key: %@", source.miningPoolAPIKey);
        self.miningPool.apiKey = source.miningPoolAPIKey;
        self.miningPool.apiURL = source.miningPoolAPIURL;

        
        [self updateMiningPoolInfo];
    }
    else {
        NSLog(@"No pool info entered");
        
    }
}

-(void)updateMiningPoolInfo
{
    [self.miningPool updatePoolInfo];
    
    self.hashrateLabel.text = [NSString stringWithFormat:@"%@ KHPS", self.miningPool.hashrateKHPS];
    self.validSharesLabel.text = [NSString stringWithFormat:@"%@ valid shares", self.miningPool.validSharesThisRound];
    self.invalidSharesLabel.text = [NSString stringWithFormat:@"%@ invalid shares", self.miningPool.invalidSharesThisRound];
    
    self.confirmedBalanceLabel.text = [NSString stringWithFormat:@"%@Ɖ confirmed", self.miningPool.confirmedBalance];
    self.unconfirmedBalanceLabel.text = [NSString stringWithFormat:@"%@Ɖ unconfirmed", self.miningPool.unconfirmedBalance];


}

@end
