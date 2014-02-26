//
//  DCMWallet.m
//  DogecoinManager
//
//  Created by Paul Brinkmann on 1/16/14.
//  Copyright (c) 2014 Paul Brinkmann. All rights reserved.
//

#import <Foundation/NSURLRequest.h>
#import <Foundation/NSUserDefaults.h>

#import "DCMWallet.h"

#import "DCMDogeInfoRemote.h"

@implementation DCMWallet

-(id)init
{
    self = [super init];
    if(self) {
        [self loadDataFromUserDefaults];
    }
 
    return self;
}


- (void)loadDataFromUserDefaults {
    NSUserDefaults *stdDefaults = [NSUserDefaults standardUserDefaults];

    if ([stdDefaults objectForKey:@"wallet.address"]) {

        self.address    = [stdDefaults objectForKey:@"wallet.address"];
        self.balance    = [stdDefaults objectForKey:@"wallet.balance"];
        self.balanceUSD = [stdDefaults objectForKey:@"wallet.balanceUSD"];
        self.lastUpdate = [stdDefaults objectForKey:@"wallet.lastUpdate"];

        if (self.balanceUSD == nil) {
            self.balanceUSD = [NSNumber numberWithInt:0];
        }

    } else {
        DLog(@"no defaults found, setting balance to 0");
        self.balance = [NSNumber numberWithInt:0];
    }
}

- (void)saveDataToUserDefaults {
    NSUserDefaults *stdDefaults = [NSUserDefaults standardUserDefaults];

    [stdDefaults setObject:self.address    forKey:@"wallet.address"];
    [stdDefaults setObject:self.balance    forKey:@"wallet.balance"];
    [stdDefaults setObject:self.balanceUSD forKey:@"wallet.balanceUSD"];
    [stdDefaults setObject:self.lastUpdate forKey:@"wallet.lastUpdate"];

    [stdDefaults synchronize];
}

-(BOOL)updateBalance
{
    if(self.address == nil) {
        DLog(@"No address found, wallet skipping update");
        return FALSE;
    }
    
    DCMDogeInfoRemote* fetcher = [DCMDogeInfoRemote sharedInstance];

    //
    // Fetch the wallet balance
    //
    float balance = [fetcher getBalanceForWallet: self.address];
  
    if(balance < 0) {
        balance = 0;
        DLog(@"DCMWallet balance update failed");
        return FALSE;
    }
    
    //
    // Fetch the DOGE => USD conversion rate
    //
    float doge_to_usd = [fetcher getDogeToUSDRate];
    float usd_balance;
    
    if(doge_to_usd < 0) {
        usd_balance = -1;
        DLog(@"DCMWallet conversion rate failed")
    }
    else {
        usd_balance = balance * doge_to_usd;
    }
    
    //
    // Update our fields with the fetched data
    //
    self.balance    = [NSNumber numberWithFloat: balance];
    self.balanceUSD = [NSNumber numberWithFloat: usd_balance];

    self.lastUpdate = [NSDate date];
    
    
    [self saveDataToUserDefaults];
    
    return TRUE;
}

@end
