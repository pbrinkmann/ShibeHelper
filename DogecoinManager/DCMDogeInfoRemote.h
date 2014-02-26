//
//  DCMDogeInfoRemote.h
//  DogecoinManager
//
//  Created by Paul Brinkmann on 2/26/14.
//  Copyright (c) 2014 Paul Brinkmann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCMDogeInfoRemote : NSObject

+(DCMDogeInfoRemote*)sharedInstance;

//
// Returns balance for given wallet address, or -1 if an error occurs
//
-(float)getBalanceForWallet:(NSString*)walletAddress;

//
// Returns conversion rate from Doge to USD, or -1 if an error occurs
//
- (float)getDogeToUSDRate;

@end
