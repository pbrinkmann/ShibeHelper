//
//  DCMWallet.m
//  DogecoinManager
//
//  Created by Paul Brinkmann on 1/16/14.
//  Copyright (c) 2014 Paul Brinkmann. All rights reserved.
//

#import <Foundation/NSURLRequest.h>

#import "DCMWallet.h"

@implementation DCMWallet

-(id)init
{
    self = [super init];
    if(self) {
        self.address = @"DLFXSX5e258mjURmEB7hZDVL5W5bCTerui";
    }
    
    return self;
}

-(void)updateBalance
{
    NSString* serverAddress = [NSString stringWithFormat: @"http://dogechain.info/chain/Dogecoin/q/addressbalance/%@", self.address];
    
    NSString* str = [NSString stringWithContentsOfURL:[NSURL URLWithString:serverAddress]];
    NSLog(@"%@", str);
    
    self.balance = [NSNumber numberWithInt:[str intValue]];
    self.lastUpdate = [NSDate date];
}

@end
