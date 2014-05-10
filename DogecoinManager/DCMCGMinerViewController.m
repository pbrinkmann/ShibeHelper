//
//  DCMCGMinerViewController.m
//  DogecoinManager
//
//  Created by Paul Brinkmann on 3/15/14.
//  Copyright (c) 2014 Paul Brinkmann. All rights reserved.
//

#import "DCMCGMinerViewController.h"
#import "DCMCGMinerGPUTableViewCell.h"
#import "DCMCGMinerGPU.h"

#import "DCMCGMinerPoolTableViewCell.h"
#import "DCMCGMinerPool.h"

#import "DCMCGMiner.h"

@interface DCMCGMinerViewController ()

@property (weak, nonatomic) IBOutlet UITextField *cgminerAddressTextField;

@property (weak, nonatomic) IBOutlet UILabel *cgminerversionLabel;
@property (weak, nonatomic) IBOutlet UILabel *cgminerHashrateLabel;
@property (weak, nonatomic) IBOutlet UILabel *cgminerGPUCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *cgminerPoolCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *cgminerPoolStrategyLabel;
@property (weak, nonatomic) IBOutlet UILabel *cgminerOSLabel;

@property (weak, nonatomic) IBOutlet UITableView *cgminerGPUTableView;
@property (weak, nonatomic) IBOutlet UITableView *cgminerPoolTableView;



@property DCMCGMiner* cgminer;

@end

@implementation DCMCGMinerViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)lookupMinerStats:(id)sender
{
    self.cgminer =[[DCMCGMiner alloc] init];
    [self.cgminer updateStats:^{
        DCMCGMiner* cgminer = self.cgminer;
        self.cgminerversionLabel.text = cgminer.cgminerVersion;
        self.cgminerHashrateLabel.text = [NSString stringWithFormat:@"%ld KH/s", (long)cgminer.cgminerHashrate];
        self.cgminerGPUCountLabel.text = [NSString stringWithFormat:@"%ld", cgminer.gpuCount];
        self.cgminerPoolCountLabel.text = [NSString stringWithFormat:@"%ld", cgminer.poolCount];
        self.cgminerPoolStrategyLabel.text = cgminer.poolStrategy;
        self.cgminerOSLabel.text = cgminer.os;
        

        [self.cgminerGPUTableView reloadData];
        [self.cgminerPoolTableView reloadData];
    }];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if( tableView == self.cgminerGPUTableView ) {
        if( self.cgminer && self.cgminer.gpus ) {
            return [self.cgminer.gpus count];
        }
    }
    else if(tableView == self.cgminerPoolTableView) {
        if( self.cgminer && self.cgminer.pools ) {
            return [self.cgminer.pools count];
        }
    }
    else {
        DLog(@"wtf is this table view: %@", tableView);
        assert( 0 && "invalid table view given");
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( tableView == self.cgminerGPUTableView ) {
        DCMCGMinerGPUTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DCMCGMinerGPUTableViewCell"];
        
        if( cell == nil ) {
            assert(0 && "Cell is nil");
        }
        DLog(@"inpexpath: %@", indexPath);
        DCMCGMinerGPU *gpu = self.cgminer.gpus[ [indexPath indexAtPosition:1] ] ;
        
        cell.gpuName.text       = [NSString stringWithFormat:@"GPU %d", gpu.gpuNumber];
        cell.hashrate.text      = [NSString stringWithFormat:@"%d KH/s", gpu.hashrate];
        cell.temperature.text   = [NSString stringWithFormat:@"%.1f C", gpu.temperature];
        cell.gpuClock.text      = [NSString stringWithFormat:@"%d mhz", gpu.gpuClock];
        cell.memoryClock.text   = [NSString stringWithFormat:@"%d mhz", gpu.memoryClock];
        cell.intensity.text     = [NSString stringWithFormat:@"I: %d", gpu.intensity];
        cell.fanSpeed.text      = [NSString stringWithFormat:@"%d RPM", gpu.fanSpeed];
        cell.fanPercent.text    = [NSString stringWithFormat:@"%d%%", gpu.fanPercent];
        
        return cell;

    }
    else if( tableView == self.cgminerPoolTableView ) {
        DCMCGMinerPoolTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DCMCGMinerPoolTableViewCell"];
        
        if( cell == nil ) {
            assert(0 && "Cell is nil");
        }
        DLog(@"inpexpath: %@", indexPath);
        DCMCGMinerPool *pool = self.cgminer.pools[ [indexPath indexAtPosition:1] ] ;
        
        cell.number.text       =  [NSString stringWithFormat:@"%d", pool.poolNumber];
        cell.url.text           = pool.poolURL;
        cell.status.text   = pool.status;
        cell.worker.text      =  pool.workerName;
        
        return cell;


    }
    else {
        DLog(@"wtf is this table view: %@", tableView);
        assert( 0 && "invalid table view given");
    }
        
    return nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
