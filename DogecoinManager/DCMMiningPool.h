//
//  DCMMiningPool.h
//  DogecoinManager
//
//  Created by Paul Brinkmann on 1/18/14.
//  Copyright (c) 2014 Paul Brinkmann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCMMiningPool : NSObject

@property NSDate* lastUpdate;

@property NSString *websiteURL;
@property NSString *apiKey;

// getuserbalance
@property float confirmedBalance;
@property float unconfirmedBalance;

// getpoolstatus
@property NSString *poolName;
@property int poolHashrate; // KHPS
@property int secondsSinceLastBlock;
@property int estimatedSecondsPerBlock;
@property int currentDifficulty;
@property int currentNetworkBlock;
@property int lastBlockFound;

// public
@property int poolSharesThisRound;

// getuserstatus
@property int hashrate; // KHPS
@property int validSharesThisRound;
@property int invalidSharesThisRound;

// getblocksfound
@property int lastBlockAmount;
@property int lastBlockDifficulty;
@property int timeToFindLastBlock; // time seconds to find the block
@property int expectedSharesUntilLastBlockFound;
@property int actualSharesToFindLastBlock;
@property NSString* lastBlockFinder;


@property int numUpdateSteps;

// Are we still on the same block as we were after the last update (or load of saved data)?
@property BOOL stillOnSameBlock;


-(NSString*)getStepName:(int)step;
-(BOOL)updatePoolInfoForStep:(int) step;


@end
