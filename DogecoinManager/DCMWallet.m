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


- (void)loadDataFromUserDefaults
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"address"])
    {
        
        self.address = [[NSUserDefaults standardUserDefaults]
                        objectForKey:@"wallet.address"];
        
        self.balance = [[NSUserDefaults standardUserDefaults]
                        objectForKey:@"wallet.balance"];

        self.balanceUSD = [[NSUserDefaults standardUserDefaults]
                           objectForKey:@"wallet.balanceUSD"];
        
        if( self.balanceUSD == nil ) {
            self.balanceUSD = [NSNumber numberWithInt:0];
        }

        
        self.lastUpdate = [[NSUserDefaults standardUserDefaults]
                           objectForKey:@"wallet.lastUpdate"];
    }
    else {
        NSLog(@"no defaults found, setting balance to 0");
        self.balance = [NSNumber numberWithInt:0];
    }
    
}

- (void)saveDataToUserDefaults
{
    [[NSUserDefaults standardUserDefaults]
     setObject:self.address forKey:@"wallet.address"];
    
    [[NSUserDefaults standardUserDefaults]
      setObject:self.balance forKey:@"wallet.balance"];
    
    [[NSUserDefaults standardUserDefaults]
     setObject:self.balanceUSD forKey:@"wallet.balanceUSD"];
    
    [[NSUserDefaults standardUserDefaults]
     setObject:self.lastUpdate forKey:@"wallet.lastUpdate"];
    
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)updateBalance
{
    if(self.address == nil) {
        NSLog(@"No address found, wallet skipping update");
        return;
    }
    
    NSString* serverAddress = [NSString stringWithFormat: @"http://dogechain.info/chain/Dogecoin/q/addressbalance/%@", self.address];
    
    NSString* str = [NSString stringWithContentsOfURL:[NSURL URLWithString:serverAddress]];
    NSLog(@"feteched wallet balance of %@", str);
    
    self.balance = [NSNumber numberWithFloat:[str floatValue]];
    
    str = [NSString stringWithContentsOfURL: [NSURL URLWithString:@"https://www.dogeapi.com/wow/?a=get_current_price"]];
    
    // strip quotes, which suddenly appeared one day
    str = [str stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    NSLog(@"feteched usd conversion rate of %@", str);
    self.balanceUSD = [NSNumber numberWithFloat: [self.balance floatValue] * [str floatValue]];

    self.lastUpdate = [NSDate date];
    
    
    [self saveDataToUserDefaults];
}

@end
