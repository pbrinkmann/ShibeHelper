//
//  DCMMiningCalculatorViewController.m
//  DogecoinManager
//
//  Created by Paul Brinkmann on 2/26/14.
//  Copyright (c) 2014 Paul Brinkmann. All rights reserved.
//

#import "DCMMiningCalculatorViewController.h"

#import "DCMMiningCalculator.h"
#import "DCMUtils.h"
#import "KeyboardStateListener.h"


@interface DCMMiningCalculatorViewController ()

@property (weak, nonatomic) IBOutlet UILabel *yourRigLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentRatesLabel;
@property (weak, nonatomic) IBOutlet UILabel *profitabilityLabel;


@property (weak, nonatomic) IBOutlet UITextField *hashrateTextField;
@property (weak, nonatomic) IBOutlet UITextField *powerUsageTextField;
@property (weak, nonatomic) IBOutlet UITextField *hardwareCostTextField;
@property (weak, nonatomic) IBOutlet UITextField *powerCostTextField;

@property (weak, nonatomic) IBOutlet UITextField *dogeToUSDRateTextField;
@property (weak, nonatomic) IBOutlet UITextField *difficultyTextField;
@property (weak, nonatomic) IBOutlet UITextField *avgBlockRewardTextField;


@property (weak, nonatomic) IBOutlet UILabel *coinsDailyLabel;
@property (weak, nonatomic) IBOutlet UILabel *revenueDailyLabel;
@property (weak, nonatomic) IBOutlet UILabel *powerDailyLabel;
@property (weak, nonatomic) IBOutlet UILabel *profitDailyLabel;

@property (weak, nonatomic) IBOutlet UILabel *coinsWeeklyLabel;
@property (weak, nonatomic) IBOutlet UILabel *revenueWeeklyLabel;
@property (weak, nonatomic) IBOutlet UILabel *powerWeeklyLabel;
@property (weak, nonatomic) IBOutlet UILabel *profitWeeklyLabel;

@property (weak, nonatomic) IBOutlet UILabel *coins30Label;
@property (weak, nonatomic) IBOutlet UILabel *revenue30Label;
@property (weak, nonatomic) IBOutlet UILabel *power30Label;
@property (weak, nonatomic) IBOutlet UILabel *profit30Label;

@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;

@end

@implementation DCMMiningCalculatorViewController

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
    
    [self addResultsGridLines];
    
    [DCMUtils makeLabelHeaderLabel:self.yourRigLabel];
    [DCMUtils makeLabelHeaderLabel:self.currentRatesLabel];
    [DCMUtils makeLabelHeaderLabel:self.profitabilityLabel];
    
    // dismiss keyboard when tap outside of text field
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(tapHandler)];
    
    [self.view addGestureRecognizer:tap];

}

// If top-level view touched, close keyboard and validate URL
-(void)tapHandler
{
    if( [KeyboardStateListener sharedInstance].isVisible ) {
        [self dismissKeyboard];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)recalculate:(id)sender {
    [self dismissKeyboard];
    
    DCMMiningCalculator *calc = [DCMMiningCalculator
        miningCalculatorWithHashRate:[self.hashrateTextField.text intValue]
                           powerCost:[self.powerCostTextField.text floatValue]
                          powerUsage:[self.powerUsageTextField.text intValue]
                        hardwareCost:[self.hardwareCostTextField.text intValue]
                       dogeToUSDRate:[self.dogeToUSDRateTextField.text floatValue]
                          difficulty:[self.difficultyTextField.text floatValue]
                      avgBlockReward:[self.avgBlockRewardTextField.text floatValue]];

    [calc calculate];

    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
    
    self.coinsDailyLabel.text   = [numberFormatter stringFromNumber:[NSNumber numberWithInt:calc.coinsPerDay]];
    self.revenueDailyLabel.text = [NSString stringWithFormat:@"$%.2f", calc.revenuePerDay];
    self.powerDailyLabel.text   = [NSString stringWithFormat:@"$%.2f", calc.powerCostPerDay];
    self.profitDailyLabel.text  = [NSString stringWithFormat:@"$%.2f", calc.profitPerDay];
    
    self.coinsWeeklyLabel.text   = [numberFormatter stringFromNumber:[NSNumber numberWithInt:calc.coinsPerDay * 7]];
    self.revenueWeeklyLabel.text = [NSString stringWithFormat:@"$%.2f", calc.revenuePerDay * 7];
    self.powerWeeklyLabel.text   = [NSString stringWithFormat:@"$%.2f", calc.powerCostPerDay * 7];
    self.profitWeeklyLabel.text  = [NSString stringWithFormat:@"$%.2f", calc.profitPerDay * 7];

    self.coins30Label.text   = [numberFormatter stringFromNumber:[NSNumber numberWithInt:calc.coinsPerDay * 30]];
    self.revenue30Label.text = [NSString stringWithFormat:@"$%.2f", calc.revenuePerDay * 30];
    self.power30Label.text   = [NSString stringWithFormat:@"$%.2f", calc.powerCostPerDay * 30];
    self.profit30Label.text  = [NSString stringWithFormat:@"$%.2f", calc.profitPerDay * 30];
}

-(void)dismissKeyboard
{
    [self.hashrateTextField resignFirstResponder];
    [self.powerCostTextField  resignFirstResponder];
    [self.powerUsageTextField  resignFirstResponder];
    [self.hardwareCostTextField  resignFirstResponder];
    [self.dogeToUSDRateTextField  resignFirstResponder];
    [self.difficultyTextField resignFirstResponder];
    [self.avgBlockRewardTextField resignFirstResponder];
}

-(void)addResultsGridLines
{
    // add graph view layer
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    // top bar
    [path moveToPoint:CGPointMake(80.0, 390.0)];
    [path addLineToPoint:CGPointMake(305.0, 390.0)];
    
    // underlines
    for(int i = 0; i < 4; i++) {
        [path moveToPoint:CGPointMake(10.0, 415.0 + i * 25)];
        [path addLineToPoint:CGPointMake(305.0, 415.0 + i * 25)];
    }

    // vertical lines
    [path moveToPoint:CGPointMake(80.0, 390.0)];
    [path addLineToPoint:CGPointMake(80, 490.0)];
    
    [path moveToPoint:CGPointMake(145.0, 390.0)];
    [path addLineToPoint:CGPointMake(145.0, 490.0)];
    
    [path moveToPoint:CGPointMake(220, 390.0)];
    [path addLineToPoint:CGPointMake(220, 490.0)];
    
    [path moveToPoint:CGPointMake(305, 390.0)];
    [path addLineToPoint:CGPointMake(305, 490.0)];
    
    
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [[UIColor lightGrayColor] CGColor];
    shapeLayer.lineWidth = .5;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    
    [self.mainScrollView.layer addSublayer:shapeLayer];
}

@end
