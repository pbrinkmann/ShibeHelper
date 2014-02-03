//
//  DCMWallet.h
//  DogecoinManager
//
//  Created by Paul Brinkmann on 1/16/14.
//  Copyright (c) 2014 Paul Brinkmann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCMWallet : NSObject

@property NSString* address;
@property NSNumber* balance;
@property NSNumber* balanceUSD;

@property NSDate* lastUpdate;


-(BOOL)updateBalance;

@end
