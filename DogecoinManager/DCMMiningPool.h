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
@property int secondsSinceLastBlock;
@property int estimatedSecondsPerBlock;

// getuserstatus
@property int hashrate; // KHPS
@property int validSharesThisRound;
@property int invalidSharesThisRound;

// public
@property NSString *poolName;
@property int poolHashrate; // KHPS
@property int poolWorkers;
@property int poolSharesThisRound;
// @property NSNumber *dogecoinNetworkHashrateKHPS;

-(void)updatePoolInfo;


@end
