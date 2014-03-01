//
//  DCMMiningCalculator.m
//  DogecoinManager
//
//  Created by Paul Brinkmann on 2/17/14.
//  Copyright (c) 2014 Paul Brinkmann. All rights reserved.
//

#import "DCMMiningCalculator.h"

@implementation DCMMiningCalculator


+(id)miningCalculatorWithHashRate:(int)hashrate
                        powerCost:(float)powerCost
                       powerUsage:(int)powerUsage
                     hardwareCost:(int)hardwareCost
                    dogeToUSDRate:(float)dogeToUSDRate
                       difficulty:(float)difficulty
                   avgBlockReward:(int)avgBlockReward;
{
    DCMMiningCalculator* newCalc = [[DCMMiningCalculator alloc] init];
    
    newCalc.hashrate        = hashrate;
    newCalc.powerCost       = powerCost;
    newCalc.powerUsage      = powerUsage;
    newCalc.hardwareCost    = hardwareCost;
    newCalc.dogeToUSDRate   = dogeToUSDRate;
    newCalc.difficulty      = difficulty;
    newCalc.avgBlockReward  = avgBlockReward;
    
    return newCalc;
}


-(void)calculate
{
    double hashesPerBlock  = (double)self.difficulty * ( pow(2, 32) );
    double hashTime        = hashesPerBlock / ( self.hashrate * 1000.0 );
    double powerCostPerDay = ( 24.0 * self.powerUsage / 1000.0 ) * self.powerCost;
    double coinsPerDay     = 60 * 60 * 24 * (double)self.avgBlockReward / hashTime;
    double revenuePerDay   = coinsPerDay * self.dogeToUSDRate;
    double profitPerDay    = revenuePerDay - powerCostPerDay;

    self.powerCostPerDay   = powerCostPerDay;
    self.coinsPerDay       = coinsPerDay;
    self.revenuePerDay     = revenuePerDay;
    self.profitPerDay      = profitPerDay;
}

/*
 #!/usr/bin/env perl
 
 use strict;
 use warnings;
 
 use DateTime;
 
 my $difficulty    = 1000;
 my $hashRate      = 1900;    # KH/s
 my $rejectPercent = .01;
 $hashRate *= ( 1 - $rejectPercent );
 
 my $electricityRate  = .1;        # cost per kw/h in USD
 my $conversionRate   = .0013;     # doge => USD
 my $powerConsumption = 800;       # watts
 my $blockCoins       = 250000;    # avg coins per block
 my $costHardware     = 1800;      # cost of HW in USD
 
 my $hashesPerBlock  = $difficulty * ( 2.0**32 );
 my $hashTime        = $hashesPerBlock / ( $hashRate * 1000.0 );
 my $powerCostPerDay = ( 24.0 * $powerConsumption / 1000.0 ) * $electricityRate;
 my $coinsPerDay     = 60 * 60 * 24 * $blockCoins / $hashTime;
 my $revenuePerDay   = $coinsPerDay * $conversionRate;
 my $profitPerDay    = $revenuePerDay - $powerCostPerDay;
 
 print "hashtime: $hashTime\n";
 print "power cost per day in \$$powerCostPerDay per day\n";
 print "coins per day $coinsPerDay\n";
 print "revenue per day $revenuePerDay\n";
 print "profit per day $profitPerDay\n";
 
 print "but.... block rewards halve!\n";
 
 # include appreciation? what if dc value doubles?  halves?
 # Need chart!
 
 
 # 105406 blocks in chain currently
 
 my $currentBlocks = 105406;
 my $nextHalving = 200000;
 my $blocksTillHalving = $nextHalving - $currentBlocks;
 my $secondsTillHalving = $blocksTillHalving * 60;
 
 my $dt = DateTime->now();
 $dt->add_duration( DateTime::Duration->new(seconds => $secondsTillHalving ));
 print $dt . "\n";
 
 
 # Factor in block jumpers, who only mine high-value blocks!  This seems to reduce the average reward
 
 #my $today = time();
 #
 #
 #April 25th, 2014 200,000
 #July 3rd, 2014 300,000
 #Sept 10th, 2014 400,000
 #Nov 19th, 2014 500,000
 #Jan 27, 2015 600,000
 
 */


@end
