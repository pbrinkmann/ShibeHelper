//
//  DCMMiningPool.h
//  DogecoinManager
//
//  Created by Paul Brinkmann on 1/18/14.
//  Copyright (c) 2014 Paul Brinkmann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCMMiningPool : NSObject

@property NSString *apiURL;
@property NSString *apiKey;

// getuserbalance
@property NSNumber *confirmedBalance;
@property NSNumber *unconfirmedBalance;

// gettimesincelastblock
@property NSNumber *secondsSinceLastBlock;

// getestimatedtime
@property NSNumber *estimatedSecondsPerBlock;

// getuserstatus
@property NSNumber *hashrateKHPS;
@property NSNumber *validSharesThisRound;
@property NSNumber *invalidSharesThisRound;

// public
@property NSString *poolName;
@property NSNumber *poolHashrateKHPS;
@property NSNumber *poolWorkers;
@property NSNumber *poolSharesThisRound;
// @property NSNumber *dogecoinNetworkHashrateKHPS;

-(void)updatePoolInfo;


@end
