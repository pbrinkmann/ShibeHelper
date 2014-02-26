//
//  DCMMiningCalculator.h
//  DogecoinManager
//
//  Created by Paul Brinkmann on 2/17/14.
//  Copyright (c) 2014 Paul Brinkmann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCMMiningCalculator : NSObject

#pragma mark - input variables
    
@property int hashrate; // KH/s
// PRO VERSION @property float rejectPercent; // 0 -> 1 ( 0% -> 100%)
// PRO VERSION pool fees    
@property float powerCost; // KW/$  ex: 0.15
@property int powerUsage; // watts ex: 1250
@property int hardwareCost;  // USD

#pragma mark - calculated/loaded variables

@property float dogeToUSDRate; // ex: .0015
@property float difficulty;
@property int avgBlockReward;
// PRO VERSION @property int effectiveHashRate;
    
#pragma mark - output variables
    
@property float powerCostPerDay;
@property float coinsPerDay;
@property float revenuePerDay;
@property float profitPerDay;

#pragma mark - Public Methods

+(id)miningCalculatorWithHashRate:(int)hashrate
                        powerCost:(float)powerCost
                       powerUsage:(int)powerUsage
                     hardwareCost:(int)hardwareCost
                    dogeToUSDRate:(float)dogeToUSDRate
                       difficulty:(float)difficulty
                   avgBlockReward:(int)avgBlockReward;

-(void)calculate;

@end
