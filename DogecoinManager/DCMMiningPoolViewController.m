//
//  DCMMiningPoolViewController
//  DogecoinManager
//
//  Created by Paul Brinkmann on 1/9/14.
//  Copyright (c) 2014 Paul Brinkmann. All rights reserved.
//

#import "DCMMiningPoolViewController.h"
#import "DCMEditMiningPoolViewController.h"

#import "DCMUtils.h"

@interface DCMMiningPoolViewController ()

@property (weak, nonatomic) IBOutlet UILabel *poolNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *hashrateLabel;
@property (weak, nonatomic) IBOutlet UILabel *validSharesLabel;
@property (weak, nonatomic) IBOutlet UILabel *confirmedBalanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *unconfirmedBalanceLabel;

@property (weak, nonatomic) IBOutlet UILabel *poolHashrateLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondsSinceLastBlockLabel;

@property (weak, nonatomic) IBOutlet UILabel *lastUpdatedLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;

@end

@implementation DCMMiningPoolViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.miningPool = [[DCMMiningPool alloc] init];
    
    [self updateMiningPoolInfo];
    
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
    
    // Do some calculations first
    
    float invalidPercent   = 100.f * self.miningPool.invalidSharesThisRound / (self.miningPool.validSharesThisRound + self.miningPool.invalidSharesThisRound);
    float blockTimePercent = 100.f * self.miningPool.secondsSinceLastBlock / self.miningPool.estimatedSecondsPerBlock;

    // And pretty up our numbers
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    [numberFormatter setCurrencySymbol:@"Ɖ"];
    
    NSString *confirmedBalance   = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:self.miningPool.confirmedBalance]];
    NSString *unconfirmedBalance = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:self.miningPool.unconfirmedBalance]];
    
    [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
    
    NSString *hashrate     = [numberFormatter stringFromNumber:[NSNumber numberWithInteger:self.miningPool.hashrate]];
    NSString *poolHashrate = [numberFormatter stringFromNumber:[NSNumber numberWithInteger:self.miningPool.poolHashrate]];

    NSString *timeSinceLastBlock = [self getFormatedDateStringForSeconds: self.miningPool.secondsSinceLastBlock];
    
    
    self.hashrateLabel.text                     = [NSString stringWithFormat:@"%@ kh/s", hashrate];
    self.validSharesLabel.text                  = [NSString stringWithFormat:@"%d/%d (%%%.1f) valid/invalid shares",
                                                                               self.miningPool.validSharesThisRound,
                                                                               self.miningPool.invalidSharesThisRound,
                                                                               invalidPercent
                                                   ];
        
  
    self.confirmedBalanceLabel.text             = [NSString stringWithFormat:@"%@ confirmed", confirmedBalance];
    self.unconfirmedBalanceLabel.text           = [NSString stringWithFormat:@"%@ unconfirmed", unconfirmedBalance];
    
    self.poolNameLabel.text                     = self.miningPool.poolName;
    self.poolHashrateLabel.text                 = [NSString stringWithFormat:@"%@ kh/s", poolHashrate];

    self.secondsSinceLastBlockLabel.text        = [NSString stringWithFormat:@"%@ (%%%.1f) since last block",
                                                                                timeSinceLastBlock,
                                                                                blockTimePercent
                                                  ];

}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if(sender != self.editButton ) return;
    
    DCMEditMiningPoolViewController *destination = (DCMEditMiningPoolViewController*)[[segue destinationViewController] visibleViewController];
    
    [destination updateDefaultMiningPoolAdress:self.miningPool.apiURL andKey:self.miningPool.apiKey];
}

-(NSString*)getFormatedDateStringForSeconds:(int)total_seconds
{
    int seconds = total_seconds % 60;
    int minutes = (total_seconds / 60) % 60;
    int hours   = (total_seconds / 3600) % 60;
    
    if( hours > 0 ) {
        return [NSString stringWithFormat:@"%ih %im %is", hours, minutes, seconds];
    }
    else if (minutes > 0 ) {
        return [NSString stringWithFormat:@"%im %is", minutes, seconds];

    }
    else {
         return [NSString stringWithFormat:@"%is", seconds];
    }
}

-(void)lastUpdatedTimerFired:(NSTimer *) theTimer
{
    if(self.miningPool.lastUpdate != nil) {
        NSTimeInterval timeSinceLastUpdate =[[theTimer fireDate] timeIntervalSinceDate:self.miningPool.lastUpdate];
        self.lastUpdatedLabel.text = [DCMUtils lastUpdatedForInterval:timeSinceLastUpdate];
        
    }
}

@end
