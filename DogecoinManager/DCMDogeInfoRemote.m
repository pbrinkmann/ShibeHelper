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

    NSDictionary* dict = [self getJSONFromURL:@"https://www.dogeapi.com/wow/v2/?a=get_current_price"];

    if(dict == nil) {
        DLog(@"Unable to fetch doge to USD rate");
        return -1;
    }
    NSDictionary* data = [dict objectForKey: @"data"];
    
    if( data == nil ) {
        DLog(@"No data found in getDogeToUSDRate");
        return -1;
    }
    
    NSString* amount = (NSString*)[data objectForKey:@"amount"];
    
    if( amount == nil ) {
        DLog(@"No amount found in getDogeToUSDRate");
        return -1;
    }
    
    float doge_to_usd = [amount floatValue];
    
    if (doge_to_usd <= 0) {
        DLog(@"Doge to USD is 0 or less, dogeapi is probably having issues");
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

//
// Returns a dict or nil if an error occurred
//
-(NSDictionary*)getJSONFromURL:(NSString*)url
{
    NSURL *url_ = [NSURL URLWithString:url];
    
    
    NSData *rawdata = [NSData dataWithContentsOfURL:url_];
    
    if( rawdata == nil) {
        DLog(@"could not fetch data from from url %@", url);
        return nil;
    }
    
    NSError *error;
    NSMutableDictionary  * dict = [NSJSONSerialization JSONObjectWithData:rawdata options: NSJSONReadingMutableContainers error: &error];
    
    if(error != nil) {
        DLog(@"error parsing JSON: %@", error);
        return nil;
    }
    
    // DLog(@"dict: %@",dict);
    
    return dict;

}

@end
