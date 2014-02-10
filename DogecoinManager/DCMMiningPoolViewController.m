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
#import "HTProgressHUDFadeZoomAnimation.h"
#import "HTProgressHUDPieIndicatorView.h"

@interface DCMMiningPoolViewController ()

// Pool Info
@property (weak, nonatomic) IBOutlet UILabel *poolNameLabel;

// Your Mining
@property (weak, nonatomic) IBOutlet UILabel *yourAccountLabel;

@property (weak, nonatomic) IBOutlet UILabel *hashrateLabel;
@property (weak, nonatomic) IBOutlet UILabel *confirmedBalanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *unconfirmedBalanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalBalanceLabel;

// Round Progress
@property (weak, nonatomic) IBOutlet UILabel *currentRoundLabel;

@property (weak, nonatomic) IBOutlet UILabel *timeSinceLastBlockLabel;
@property (weak, nonatomic) IBOutlet UILabel *estPercentDoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *validSharesLabel;
@property (weak, nonatomic) IBOutlet UILabel *validsharesPercentLabel;
@property (weak, nonatomic) IBOutlet UILabel *estimatedEarningsLabel;

// Last Block
@property (weak, nonatomic) IBOutlet UILabel *lastBlockLabel;

@property (weak, nonatomic) IBOutlet UILabel *lastBlockAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastBlockTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastBlockPercentLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastBlockFinderLabel;


@property (weak, nonatomic) IBOutlet UILabel *lastUpdatedLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editMiningPoolButton;


@end

@implementation DCMMiningPoolViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
   
    [self makeLabelHeaderLabel:self.yourAccountLabel];
    [self makeLabelHeaderLabel:self.currentRoundLabel];
    [self makeLabelHeaderLabel:self.lastBlockLabel];
    
    self.miningPool = [[DCMMiningPool alloc] init];
    [self refreshViewLabels];

    
    
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

- (void)makeLabelHeaderLabel:(UILabel*)headerLabel
{
    CALayer *yourAccountLayer = [headerLabel layer];
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.borderColor =  CreateDeviceRGBColor(.6,.6,.6,1); //[UIColor lightGrayColor].CGColor;
    bottomBorder.borderWidth = 1;
    bottomBorder.frame =
    CGRectMake(-1, yourAccountLayer.frame.size.height - 1, yourAccountLayer.frame.size.width, 1);
    //[bottomBorder setBorderColor:[UIColor blackColor].CGColor];
    [yourAccountLayer addSublayer:bottomBorder];
    
    yourAccountLayer.backgroundColor = CreateDeviceRGBColor(.9,.9,.9,1);
}


-(IBAction)refreshMiningPoolFromTouch:(id)sender
{
    if( self.miningPool.websiteURL == nil || self.miningPool.apiKey == nil ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No mining pool configured"
                                                        message:@"You need to configure your mining pool (click Edit in the top right)"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
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
    if (self.miningPool.websiteURL == nil ) {
        NSLog(@"skipping update mining pool, no website URL");
        return;
    }

    self.editMiningPoolButton.enabled = NO;
    
    __block HTProgressHUD *progressHUD = [[HTProgressHUD alloc] init];
    progressHUD.animation = [HTProgressHUDFadeZoomAnimation animation];
    progressHUD.indicatorView = [HTProgressHUDIndicatorView indicatorViewWithType:HTProgressHUDIndicatorTypePie];
    
    [progressHUD showWithAnimation:YES inView:self.view whileExecutingBlock:^{
        
        DCMMiningPool* pool = self.miningPool;
                              
        int numUpdateSteps = pool.numUpdateSteps;
        
        BOOL updatesFailed = NO;
        
        for (int i = 0; i < numUpdateSteps; i++) {
            
            progressHUD.text = [NSString stringWithFormat:@"fetching %@", [pool getStepName:i]];

            BOOL stepOk = [pool updatePoolInfoForStep:i];
            
            if( !stepOk) {
                progressHUD.progress = (i*2.f + 1.f) / (numUpdateSteps * 2.f);
                progressHUD.text = [NSString stringWithFormat:@"retrying %@", [pool getStepName:i]];

                stepOk = [pool updatePoolInfoForStep:i];
                
                if( stepOk == NO ) {
                    updatesFailed = YES;
                    break;
                }
            }
            
            progressHUD.progress = ((i+1)*2.f)/ (numUpdateSteps * 2.f);

        }
        
        // must do UI updates on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            self.editMiningPoolButton.enabled = YES;
            
            if( updatesFailed ) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable failed"
                                                                message:@"Unable to update mining pool, please check your settings or try again later"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            else {
                [self refreshViewLabels];
            }
        });
    }];
}

//
// Recalculates all display items based on the latest self.miningPool data
//
-(void)refreshViewLabels
{

    // Do some calculations first
    
    float validSharesPercent =
        100.f - 100.f * self.miningPool.invalidSharesThisRound /
                    (self.miningPool.validSharesThisRound + self.miningPool.invalidSharesThisRound);
    float blockTimePercent =
        100.f * self.miningPool.secondsSinceLastBlock / self.miningPool.estimatedSecondsPerBlock;

    float lastBlockPercent = 100.f * self.miningPool.actualSharesToFindLastBlock /
                             self.miningPool.expectedSharesUntilLastBlockFound;

    // And pretty up our numbers
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    [numberFormatter setCurrencySymbol:@"Ɖ"];
    
    NSString *confirmedBalance   = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:self.miningPool.confirmedBalance]];
    NSString *unconfirmedBalance = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:self.miningPool.unconfirmedBalance]];
    NSString *totalBalance       = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:
                                                            self.miningPool.confirmedBalance + self.miningPool.unconfirmedBalance]];
    int avgBlockReward           = [DCMUtils getAvgBlockRewardForBlock:self.miningPool.currentNetworkBlock];
    float estEarnings            = (float)avgBlockReward * self.miningPool.validSharesThisRound / (float)self.miningPool.poolSharesThisRound;
    NSString *estimatedEarnings  = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:estEarnings]];
    
    [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
    
    NSString *hashrate     = [numberFormatter stringFromNumber:[NSNumber numberWithInteger:self.miningPool.hashrate]];

    // even though this is a currency, there are never fractional amounts
    NSString *lastBlockAmount = [NSString stringWithFormat:@"Ɖ%@",
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
    self.hashrateLabel.text              = [NSString stringWithFormat:@"%@ kh/s", hashrate];
    self.confirmedBalanceLabel.text      = confirmedBalance;
    self.unconfirmedBalanceLabel.text    = unconfirmedBalance;
    self.totalBalanceLabel.text          = totalBalance;
    
    //
    // Round Progress
    //
    self.timeSinceLastBlockLabel.text   = timeSinceLastBlock;
    self.estPercentDoneLabel.text       = [NSString stringWithFormat:@"%.1f%%", blockTimePercent];
    self.validSharesLabel.text          = [NSString stringWithFormat:@"%d", self.miningPool.validSharesThisRound];
    self.validsharesPercentLabel.text   = [NSString stringWithFormat:@"%.1f%%", validSharesPercent];
    self.estimatedEarningsLabel.text    = estimatedEarnings;
    
    //
    // Last Block
    //
    self.lastBlockAmountLabel.text      = lastBlockAmount;
    self.lastBlockTimeLabel.text        = timeToFindLastBlock;
    self.lastBlockPercentLabel.text     = [NSString stringWithFormat:@"%.1f%%", lastBlockPercent];
    self.lastBlockFinderLabel.text      = self.miningPool.lastBlockFinder;
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
                                        
CGColorRef CreateDeviceRGBColor(CGFloat r, CGFloat g, CGFloat b, CGFloat a)
{
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    CGFloat comps[] = {r, g, b, a};
    CGColorRef color = CGColorCreate(rgb, comps);
    CGColorSpaceRelease(rgb);
    return color;
}


@end
