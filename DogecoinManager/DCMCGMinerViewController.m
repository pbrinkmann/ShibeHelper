//
//  DCMCGMinerViewController.m
//  DogecoinManager
//
//  Created by Paul Brinkmann on 3/15/14.
//  Copyright (c) 2014 Paul Brinkmann. All rights reserved.
//

#import "DCMCGMinerViewController.h"

#import "DCMCGMiner.h"

@interface DCMCGMinerViewController ()

@property (weak, nonatomic) IBOutlet UITextField *cgminerAddressTextField;

@property (weak, nonatomic) IBOutlet UILabel *cgminerversionLabel;
@property (weak, nonatomic) IBOutlet UILabel *cgminerHashrateLabel;

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
    [self.cgminer fetchyDoShit:^{
        self.cgminerversionLabel.text = self.cgminer.cgminerVersion;
        self.cgminerHashrateLabel.text = [NSString stringWithFormat:@"%ld KH/s", (long)self.cgminer.cgminerHashrate];
    }];
    
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
