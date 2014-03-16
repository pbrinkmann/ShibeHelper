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


- (float)getBalanceForWallet:(NSString *)walletAddress
{
    //
    // Fetch the wallet balance
    //
    NSString *errorString = nil;
    float balance = [self
        getFloatValueFromURL:
            [NSString stringWithFormat:@"http://dogechain.info/chain/Dogecoin/q/addressbalance/%@",
                                       walletAddress]
                        what:@"wallet balance"
                  setOnError:&errorString];

    if (errorString != nil) {
        DLog(@"%@", errorString);
        return -1;
    }

    // there's no crying, errr, negative balance in baseball, err,  dogeball!
    if (balance < 0) balance = 0;

    return balance;
}

- (float)getDogeToUSDRate {
    
    NSString *errorString = nil;
    float doge_to_usd = [self
                     getFloatValueFromURL:
                     @"https://www.dogeapi.com/wow/?a=get_current_price"
                     what:@"doge to USD rate"
                     setOnError:&errorString];

    if(errorString != nil) {
        DLog(@"%@", errorString);
        return -1;
    }
    
    if (doge_to_usd == 0) {
        DLog(@"Doge to USD is 0, dogeapi is probably having issues");
        return -1;
    }
   
    return doge_to_usd;
}

- (int)getLastBlock
{
    NSString *errorString = nil;
    int lastBlock = [self getIntValueFromURL:@"http://dogechain.info/chain/Dogecoin/q/getblockcount"
                                        what:@"last block"
                                  setOnError:&errorString];

    if (errorString != nil) {
        DLog(@"%@", errorString);
        return -1;
    }

    return lastBlock;
}

-(float)getNetworkDifficulty
{
    NSString *errorString = nil;
    float difficulty = [self
                         getFloatValueFromURL:
                         @"http://dogechain.info/chain/Dogecoin/q/getdifficulty"
                         what:@"network difficulty"
                         setOnError:&errorString];
    
    if(errorString != nil) {
        DLog(@"%@", errorString);
        return -1;
    }
    
    return difficulty;
}

- (int)getIntValueFromURL:(NSString *)url
                     what:(NSString *)what
               setOnError:(NSString **)errorString
{
    NSError *error;
    NSString *str = [NSString stringWithContentsOfURL:[NSURL URLWithString:url]
                                             encoding:NSUTF8StringEncoding
                                                error:&error];

    int intVal;

    if (str == nil) {
        *errorString = [NSString
            stringWithFormat:@"Failed to fetch %@: %@", what, [error localizedDescription]];
        return 0;
    } else {
        // strip quotes, in case they suddenly appeare one day
        str = [str stringByReplacingOccurrencesOfString:@"\"" withString:@""];

        NSScanner *scanner = [NSScanner scannerWithString:str];

        if (![scanner scanInt:&intVal]) {
            *errorString = [NSString
                stringWithFormat:@"Unknown error when parsing %@ string for int: %@", what, str];
            return 0;
        }
    }

    return intVal;
}

- (float)getFloatValueFromURL:(NSString *)url
                     what:(NSString *)what
               setOnError:(NSString **)errorString
{
    NSError *error;
    NSString *str = [NSString stringWithContentsOfURL:[NSURL URLWithString:url]
                                             encoding:NSUTF8StringEncoding
                                                error:&error];
    
    float floatVal;
    
    if (str == nil) {
        *errorString = [NSString
                        stringWithFormat:@"Failed to fetch %@: %@", what, [error localizedDescription]];
        return 0;
    } else {
        // strip quotes, in case they suddenly appeare one day
        str = [str stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        NSScanner *scanner = [NSScanner scannerWithString:str];
        
        if (![scanner scanFloat:&floatVal]) {
            *errorString = [NSString
                            stringWithFormat:@"Unknown error when parsing %@ string for float: %@", what, str];
            return 0;
        }
    }
    
    return floatVal;
}

@end
