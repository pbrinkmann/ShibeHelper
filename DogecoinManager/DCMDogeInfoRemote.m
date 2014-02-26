//
//  DCMDogeInfoRemote.m
//  DogecoinManager
//
//  Created by Paul Brinkmann on 2/26/14.
//  Copyright (c) 2014 Paul Brinkmann. All rights reserved.
//

#import "DCMDogeInfoRemote.h"

@implementation DCMDogeInfoRemote

+(DCMDogeInfoRemote*)sharedInstance
{
    static DCMDogeInfoRemote* instance = nil;
    
    @synchronized(self)
    {
        if(instance == nil) {
            instance = [[DCMDogeInfoRemote alloc] init];
        }
    }
    
    return instance;
}


-(float)getBalanceForWallet:(NSString*)walletAddress
{
    //
    // Fetch the wallet balance
    //
    NSString* serverAddress = [NSString stringWithFormat: @"http://dogechain.info/chain/Dogecoin/q/addressbalance/%@", walletAddress];
    
    NSError *error;
    NSString *str = [NSString stringWithContentsOfURL:[NSURL URLWithString:serverAddress] encoding:NSUTF8StringEncoding error:&error];
    
    if (str == nil) {
        DLog(@"Failed to fetch wallet balance: %@", [error localizedDescription]);
        return -1;
    }
    
    float balance;
    NSScanner* scanner = [NSScanner scannerWithString:str];
    
    if( ![scanner scanFloat:&balance] ) {
        if( [str hasPrefix:@"ERROR"] ) {
            DLog(@"Unable to retrieve balance for wallet: %@", str);
        }
        else {
            DLog(@"Unknown error when parsing string for float: %@", str);
        }
        return -1;
    }
    
    // there's no crying, errr, negative balance in baseball, err,  dogeball!
    if(balance < 0) balance = 0;
    
    return balance;
}

- (float)getDogeToUSDRate {
    NSError *error;
    NSString *str = [NSString stringWithContentsOfURL:
                         [NSURL URLWithString:@"https://www.dogeapi.com/wow/?a=get_current_price"]
                                             encoding:NSUTF8StringEncoding
                                                error:&error];

    float doge_to_usd;

    if (str == nil) {
        DLog(@"Failed to fetch USD conversion rate: %@", [error localizedDescription]);
        return -1;
    } else {
        // strip quotes, which suddenly appeared one day
        str = [str stringByReplacingOccurrencesOfString:@"\"" withString:@""];

        NSScanner *scanner = [NSScanner scannerWithString:str];

        if (![scanner scanFloat:&doge_to_usd]) {
            DLog(@"Unknown error when parsing string for float: %@", str);

            return -1;
        }

        if (doge_to_usd == 0) {
            DLog(@"Doge to USD is 0, dogeapi is probably having issues");
            return -1;
        }
    }

    return doge_to_usd;
}

@end
