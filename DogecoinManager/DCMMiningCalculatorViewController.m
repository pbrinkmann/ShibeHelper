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

@property DCMMiningCalculator* miningCalc;

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

@property (weak, nonatomic) IBOutlet UILabel *timeToBreakEvenLabel;

@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;

@end

#define LEFT 0
#define RIGHT 1

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
    
    self.miningCalc = [[DCMMiningCalculator alloc] init];
    
    if(self.miningCalc.hashrate > 0) {
        [self restoreInputTextFields];
        [self refreshProfitabilityViewLabels];
    }
    
    [self addResultsGridLines];
    
    [DCMUtils makeLabelHeaderLabel:self.yourRigLabel];
    [DCMUtils makeLabelHeaderLabel:self.currentRatesLabel];
    [DCMUtils makeLabelHeaderLabel:self.profitabilityLabel];
    
    // dismiss keyboard when tap outside of text field
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(tapHandler)];
    
    [self.view addGestureRecognizer:tap];
    

    //
    // Configure units for the text views
    //
    [self addUnitsToTextView:self.hashrateTextField     withUnitString:@"kh/s"   toSide:RIGHT];
    [self addUnitsToTextView:self.hardwareCostTextField withUnitString:@"$"      toSide:LEFT];
    [self addUnitsToTextView:self.powerUsageTextField   withUnitString:@"watts"  toSide:RIGHT];
    [self addUnitsToTextView:self.powerCostTextField    withUnitString:@"$/kWh"  toSide:RIGHT];
    [self addUnitsToTextView:self.dogeToUSDRateTextField withUnitString:@"USD/Ð" toSide:RIGHT];
}

-(void)addUnitsToTextView:(UITextField*)textView withUnitString:(NSString*)str toSide:(int)side
{
    int padding = 5;
    
    UIFont *textFont = [UIFont systemFontOfSize:14];
    CGSize s = [str sizeWithAttributes:@{ NSFontAttributeName : textFont }];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, s.width + padding, 30)];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = textFont;
    label.text = str;
    label.textColor = [UIColor lightGrayColor];
    label.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0];
    
    if(side == RIGHT) {
        textView.rightViewMode = UITextFieldViewModeAlways;
        textView.rightView = label;
    }
    else {
        textView.leftViewMode = UITextFieldViewModeAlways;
        textView.leftView = label;
    }
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

- (IBAction)anyValueChanged:(id)sender {
    // If all fields have a value, recalc

    if (![self.hashrateTextField.text isEqualToString:@""]      &&
        ![self.powerUsageTextField.text isEqualToString:@""]    &&
        ![self.hardwareCostTextField.text isEqualToString:@""]  &&
        ![self.powerCostTextField.text isEqualToString:@""]     &&
        ![self.dogeToUSDRateTextField.text isEqualToString:@""] &&
        ![self.difficultyTextField.text isEqualToString:@""]    &&
        ![self.avgBlockRewardTextField.text isEqualToString:@""])
    {
        [self saveValuesToMiningCalc];
        [self recalculate];
    }
}

-(void)saveValuesToMiningCalc {
    self.miningCalc.hashrate        = [self.hashrateTextField.text       intValue];
    self.miningCalc.powerCost       = [self.powerCostTextField.text      floatValue];
    self.miningCalc.powerUsage      = [self.powerUsageTextField.text     intValue];
    self.miningCalc.hardwareCost    = [self.hardwareCostTextField.text   intValue];
    self.miningCalc.dogeToUSDRate   = [self.dogeToUSDRateTextField.text  floatValue];
    self.miningCalc.difficulty      = [self.difficultyTextField.text     floatValue];
    self.miningCalc.avgBlockReward  = [self.avgBlockRewardTextField.text intValue];
    
    [self.miningCalc saveValues];
}

- (void)recalculate {
    [self.miningCalc calculate];
    [self refreshProfitabilityViewLabels];
}

-(void)restoreInputTextFields {
    self.hashrateTextField.text         = [NSString stringWithFormat:@"%d", self.miningCalc.hashrate ];
    self.powerCostTextField.text        = [NSString stringWithFormat:@"%.3f", self.miningCalc.powerCost ];
    self.powerUsageTextField.text       = [NSString stringWithFormat:@"%d", self.miningCalc.powerUsage];
    self.hardwareCostTextField.text     = [NSString stringWithFormat:@"%d", self.miningCalc.hardwareCost];
    self.dogeToUSDRateTextField.text    = [NSString stringWithFormat:@"%.5f", self.miningCalc.dogeToUSDRate];
    self.difficultyTextField.text       = [NSString stringWithFormat:@"%.1f", self.miningCalc.difficulty];
    self.avgBlockRewardTextField.text   = [NSString stringWithFormat:@"%d", self.miningCalc.avgBlockReward];
}

-(void)refreshProfitabilityViewLabels {

    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
    
    self.coinsDailyLabel.text   = [numberFormatter stringFromNumber:[NSNumber numberWithInt:self.miningCalc.coinsPerDay]];
    self.revenueDailyLabel.text = [NSString stringWithFormat:@"$%.2f", self.miningCalc.revenuePerDay];
    self.powerDailyLabel.text   = [NSString stringWithFormat:@"$%.2f", self.miningCalc.powerCostPerDay];
    self.profitDailyLabel.text  = [NSString stringWithFormat:@"$%.2f", self.miningCalc.profitPerDay];
    
    self.coinsWeeklyLabel.text   = [numberFormatter stringFromNumber:[NSNumber numberWithInt:self.miningCalc.coinsPerDay * 7]];
    self.revenueWeeklyLabel.text = [NSString stringWithFormat:@"$%.2f", self.miningCalc.revenuePerDay * 7];
    self.powerWeeklyLabel.text   = [NSString stringWithFormat:@"$%.2f", self.miningCalc.powerCostPerDay * 7];
    self.profitWeeklyLabel.text  = [NSString stringWithFormat:@"$%.2f", self.miningCalc.profitPerDay * 7];

    self.coins30Label.text   = [numberFormatter stringFromNumber:[NSNumber numberWithInt:self.miningCalc.coinsPerDay * 30]];
    self.revenue30Label.text = [NSString stringWithFormat:@"$%.2f", self.miningCalc.revenuePerDay * 30];
    self.power30Label.text   = [NSString stringWithFormat:@"$%.2f", self.miningCalc.powerCostPerDay * 30];
    self.profit30Label.text  = [NSString stringWithFormat:@"$%.2f", self.miningCalc.profitPerDay * 30];
    
    if( self.miningCalc.profitPerDay <= 0 ) {
        self.timeToBreakEvenLabel.text = @"time to break even: never";
    }
    else {
        self.timeToBreakEvenLabel.text = [NSString
                                          stringWithFormat:@"time to break even: %d days",
                                          (int)(self.miningCalc.hardwareCost / self.miningCalc.profitPerDay)];
    }
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
    
    int leftUnderlineX  = 10;
    int underlineWidth  = 70;
    
    int leftBorderX     = leftUnderlineX + underlineWidth;

    int rightBorderX    = leftUnderlineX + 295;

    int topBorderY      = 370;
    int bottomBorderY   = topBorderY + 100;
    
    int rowHeight       = 25;
    int firstUnderlineY = topBorderY + rowHeight;
    
    // top bar
    [path moveToPoint:CGPointMake(leftBorderX, topBorderY)];
    [path addLineToPoint:CGPointMake(rightBorderX, topBorderY)];
    
    // underlines
    for(int i = 0; i < 4; i++) {
        [path moveToPoint:CGPointMake(leftUnderlineX,  firstUnderlineY + i * rowHeight)];
        [path addLineToPoint:CGPointMake(rightBorderX, firstUnderlineY + i * rowHeight)];
    }

    // vertical lines
    [path moveToPoint:CGPointMake(   leftBorderX, topBorderY)];
    [path addLineToPoint:CGPointMake(leftBorderX, bottomBorderY)];
    
    [path moveToPoint:CGPointMake(   leftBorderX + 65, topBorderY)];
    [path addLineToPoint:CGPointMake(leftBorderX + 65, bottomBorderY)];
    
    [path moveToPoint:CGPointMake(   leftBorderX + 140, topBorderY)];
    [path addLineToPoint:CGPointMake(leftBorderX + 140, bottomBorderY)];
    
    [path moveToPoint:CGPointMake(   rightBorderX, topBorderY)];
    [path addLineToPoint:CGPointMake(rightBorderX, bottomBorderY)];
    
    
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [[UIColor lightGrayColor] CGColor];
    shapeLayer.lineWidth = .5;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    
    [self.mainScrollView.layer addSublayer:shapeLayer];
}

@end
