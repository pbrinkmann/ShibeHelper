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

#import "HTProgressHUD.h"

@interface DCMMiningPoolViewController ()

// Pool Info
@property (weak, nonatomic) IBOutlet UILabel *poolNameLabel;

// Your Mining
@property (weak, nonatomic) IBOutlet UILabel *hashrateLabel;
@property (weak, nonatomic) IBOutlet UILabel *confirmedBalanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *unconfirmedBalanceLabel;

// Round Progress
@property (weak, nonatomic) IBOutlet UILabel *validSharesLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondsSinceLastBlockLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentDifficultyLabel;

// Last Block
@property (weak, nonatomic) IBOutlet UILabel *lastBlockAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastBlockDifficultyLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastBlockTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastBlockFinderLabel;


@property (weak, nonatomic) IBOutlet UILabel *lastUpdatedLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editMiningPoolButton;

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
        self.miningPool.websiteURL = source.miningPoolWebsiteURL;

        
        [self updateMiningPoolInfo];
    }
    else {
        NSLog(@"No pool info entered");
        
    }
}

-(void)updateMiningPoolInfo
{
    if (self.miningPool.websiteURL == nil ) return;

    HTProgressHUD *HUD = [[HTProgressHUD alloc] init];
    [HUD showInView:self.view];
    self.editMiningPoolButton.enabled = NO;
    
    dispatch_queue_t myQueue = dispatch_queue_create("Mining Pool Update Queue",NULL);
    dispatch_async(myQueue, ^{

        // synchronous update
        [self.miningPool updatePoolInfo];
        
        // must do UI updates on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [HUD hide];
            self.editMiningPoolButton.enabled = YES;
            
            [self refreshViewLabels];
        });
    });
}

//
// Recalculates all display items based on the latest self.miningPool data
//
-(void)refreshViewLabels
{

    // Do some calculations first
    
    float invalidPercent   = 100.f * self.miningPool.invalidSharesThisRound / (self.miningPool.validSharesThisRound + self.miningPool.invalidSharesThisRound);
    float blockTimePercent = 100.f * self.miningPool.secondsSinceLastBlock / self.miningPool.estimatedSecondsPerBlock;

    float lastBlockPercent = 100.f *self.miningPool.actualSharesToFindLastBlock / self.miningPool.expectedSharesUntilLastBlockFound;

    // And pretty up our numbers
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    [numberFormatter setCurrencySymbol:@"Ɖ"];
    
    NSString *confirmedBalance   = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:self.miningPool.confirmedBalance]];
    NSString *unconfirmedBalance = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:self.miningPool.unconfirmedBalance]];

    
    [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
    
    NSString *hashrate     = [numberFormatter stringFromNumber:[NSNumber numberWithInteger:self.miningPool.hashrate]];

    // even though this is a currency, there are never fractional amounts
    NSString *lastBlockAmount = [NSString stringWithFormat:@"yielded Ɖ%@",
                                        [numberFormatter stringFromNumber:
                                                   [NSNumber numberWithInt:self.miningPool.lastBlockAmount]
                                         ]
                                 ];
    
    
    NSString *timeSinceLastBlock  = [self getFormatedDateStringForSeconds: self.miningPool.secondsSinceLastBlock];
    NSString *timeToFindLastBlock = [self getFormatedDateStringForSeconds: self.miningPool.timeToFindLastBlock];
    
    // Pool Info
    self.poolNameLabel.text                     = self.miningPool.poolName;
 
    //
    // Your mining
    //
    self.hashrateLabel.text                     = [NSString stringWithFormat:@"%@ kh/s", hashrate];
    self.confirmedBalanceLabel.text             = [NSString stringWithFormat:@"%@ confirmed", confirmedBalance];
    self.unconfirmedBalanceLabel.text           = [NSString stringWithFormat:@"%@ unconfirmed", unconfirmedBalance];
    
    
    //
    // Round Progress
    //
    
    self.validSharesLabel.text                  = [NSString stringWithFormat:@"%d/%d (%%%.1f) valid/invalid shares",
                                                                               self.miningPool.validSharesThisRound,
                                                                               self.miningPool.invalidSharesThisRound,
                                                                               invalidPercent
                                                   ];
        
    self.secondsSinceLastBlockLabel.text        = [NSString stringWithFormat:@"%@ (%%%.1f) since last block",
                                                                                timeSinceLastBlock,
                                                                                blockTimePercent
                                                  ];

    self.currentDifficultyLabel.text = [NSString stringWithFormat:@"%d difficulty", self.miningPool.currentDifficulty];

    //
    // Last Block
    //
    self.lastBlockAmountLabel.text      = lastBlockAmount;
    self.lastBlockDifficultyLabel.text  = [NSString stringWithFormat:@"%d difficulty", self.miningPool.lastBlockDifficulty];
    self.lastBlockTimeLabel.text        = [NSString stringWithFormat:@"%@ (%%%.1f of expected)", timeToFindLastBlock, lastBlockPercent];
    self.lastBlockFinderLabel.text      = [NSString stringWithFormat:@"found by %@", self.miningPool.lastBlockFinder];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if(sender != self.editMiningPoolButton ) return;
    
    DCMEditMiningPoolViewController *destination = (DCMEditMiningPoolViewController*)[[segue destinationViewController] visibleViewController];
    
    [destination updateDefaultMiningPoolAdress:self.miningPool.websiteURL andKey:self.miningPool.apiKey];
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
