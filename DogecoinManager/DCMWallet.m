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
        NSLog(@"no defaults found, setting balance to 0");
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
        NSLog(@"No address found, wallet skipping update");
        return FALSE;
    }
    //
    // Fetch the wallet balance
    //
    NSString* serverAddress = [NSString stringWithFormat: @"http://dogechain.info/chain/Dogecoin/q/addressbalance/%@", self.address];
    
    NSError *error;
    NSString *str = [NSString stringWithContentsOfURL:[NSURL URLWithString:serverAddress] encoding:NSUTF8StringEncoding error:&error];
    
    if (str == nil) {
        NSLog(@"Failed to fetch wallet balance: %@", [error localizedDescription]);
        return FALSE;
    }
    
    float balance;
    NSScanner* scanner = [NSScanner scannerWithString:str];
    
    if( ![scanner scanFloat:&balance] ) {
        if( [str hasPrefix:@"ERROR"] ) {
            NSLog(@"Unable to retrieve balance for wallet: %@", str);
        }
        else {
            NSLog(@"Unknown error when parsing string for float: %@", str);
        }
        return FALSE;
    }
    

    NSLog(@"feteched wallet balance of %@", str);
    
  
    
    //
    // Fetch the DOGE => USD conversion rate
    //
    str = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"https://www.dogeapi.com/wow/?a=get_current_price"] encoding:NSUTF8StringEncoding error:&error];
    
    float doge_to_usd;
    
    if( str == nil) {
        NSLog(@"Failed to fetch USD conversion rate: %@", [error localizedDescription] );
        doge_to_usd = -1;
    }
    else {
        // strip quotes, which suddenly appeared one day
        str = [str stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        scanner = [NSScanner scannerWithString:str];
        
        if( ![scanner scanFloat:&doge_to_usd] ) {

            NSLog(@"Unknown error when parsing string for float: %@", str);

            doge_to_usd = -1;
        }
        
        if( doge_to_usd == 0 ) {
            NSLog(@"Doge to USD is 0, dogeapi is probably having issues");
            doge_to_usd = -1;
        }
    }

    
    NSLog(@"feteched usd conversion rate of %@", str);
    
    //
    // Update our fields with the fetched data
    //
    self.balance    = [NSNumber numberWithFloat: balance];
    self.balanceUSD = [NSNumber numberWithFloat: balance * doge_to_usd];

    self.lastUpdate = [NSDate date];
    
    
    [self saveDataToUserDefaults];
    
    return TRUE;
}

@end
