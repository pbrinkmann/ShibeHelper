//
//  DCMMiningPool.m
//  DogecoinManager
//
//  Created by Paul Brinkmann on 1/18/14.
//  Copyright (c) 2014 Paul Brinkmann. All rights reserved.
//

#import "DCMMiningPool.h"

@interface DCMMiningPool ()

// private stuff here I guess

@end

@implementation DCMMiningPool

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
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"apiURL"])
    {
        
        self.apiURL = [[NSUserDefaults standardUserDefaults]
                        objectForKey:@"miningpool.apiURL"];
        
        self.apiKey = [[NSUserDefaults standardUserDefaults]
                        objectForKey:@"miningpool.apiKey"];
    }
}

- (void)saveDataToUserDefaults
{
    [[NSUserDefaults standardUserDefaults]
     setObject:self.apiURL forKey:@"miningpool.apiURL"];
    
    [[NSUserDefaults standardUserDefaults]
     setObject:self.apiKey forKey:@"miningpool.apiKey"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)updatePoolInfo
{
    if( self.apiURL == nil || self.apiKey == nil) { NSLog(@"DCMMiningPool skipping initial load of mining pool"); return; }
    
    
    [self doUserStatusAPICall];
    [self doUserBalanceAPICall];
    [self doPoolStatusAPICall];
    
    self.lastUpdate = [NSDate date];

    // TODO: this should actually happen when apiKey and apiURL get set
    [self saveDataToUserDefaults ];
}

/*  ok, since this is what multipool.us looks like:
 
 for DCM VERSION 2.0 !!!!
{
    "currency": {
 
        "doge": {
            "confirmed_rewards": "351.4674396",
            "hashrate": "1167",
            "estimated_rewards": "28.7412",
            "payout_history": "10963.4614339",
            "pool_hashrate": 16485314,
            "round_shares": "704",
            "block_shares": "671132783"
        },
    },
    "workers": {
        "doge": {
            "paulb.1": {
                "hashrate": "1167"
            }
        },    
    }
}
*/

-(void)doUserStatusAPICall
{
    NSMutableDictionary *dict = [self callPoolAPIMethod:@"getuserstatus"];
    
    if( dict == nil) {
        NSLog(@"API call failed, cancelling getuserstatus update");
        return;
    }


    /*
     {
         "getuserstatus": {
            "version": "1.0.0",
            "runtime": 322.16811180115,
            "data": {
                "username": "paulb",
                "shares": {
                    "valid": 544,
                    "invalid": 0
                },
                "hashrate": 1482,
                "sharerate": "0.0883"
             }
         }
     }
     */
    
    NSMutableDictionary *status = [dict objectForKey:@"getuserstatus"];
    
    NSMutableDictionary *data   = [status objectForKey:@"data"];
    NSMutableDictionary *shares = [data objectForKey:@"shares"];
   
    NSString *hashRate      = (NSString*)[data objectForKey:@"hashrate"];
    NSString *validShares   = (NSString*)[shares objectForKey:@"valid"];
    NSString *invalidShares = (NSString*)[shares objectForKey:@"invalid"];

    
    NSLog(@"hashRate: %@", hashRate);
    
    self.hashrate           = [hashRate intValue];
    self.validSharesThisRound   = [validShares intValue];
    self.invalidSharesThisRound = [invalidShares intValue];

}


-(void)doUserBalanceAPICall
{
    NSMutableDictionary *dict = [self callPoolAPIMethod:@"getuserbalance"];
    
    if( dict == nil) {
        NSLog(@"API call failed, cancelling getuserbalance update");
        return;
    }
    
    /*
     {
         "getuserbalance": {
             "version": "1.0.0",
             "runtime": 11.191129684448,
             "data": {
                 "confirmed": 517.21680185,
                 "unconfirmed": 1538.61649413,
                 "orphaned": 90.79280431
             }
         }
     }
     */
    
    NSMutableDictionary *balance = [dict objectForKey:@"getuserbalance"];
    
    NSMutableDictionary *data = [balance objectForKey:@"data"];
    
    NSString *confirmed  = (NSString*)[data objectForKey:@"confirmed"];
    NSString *unconfrmed = (NSString*)[data objectForKey:@"unconfirmed"];
    
    
    self.confirmedBalance   = [confirmed floatValue];
    self.unconfirmedBalance = [unconfrmed floatValue];
    

}

-(void)doPoolStatusAPICall
{
    NSMutableDictionary *dict = [self callPoolAPIMethod:@"getpoolstatus"];
    
    if( dict == nil) {
        NSLog(@"API call failed, cancelling getpoolstatus update");
        return;
    }
/*
 {
     "getpoolstatus": {
         "version": "1.0.0",
         "runtime": 25.833129882812,
         "data": {
             "pool_name": "suchcoins.com",
             "hashrate": 4145161,
             "efficiency": 98.03,
             "workers": 3905,
             "currentnetworkblock": 65415,
             "nextnetworkblock": 65416,
             "lastblock": 65399,
             "networkdiff": 896.337924,
             "esttime": 928.73161494681,
             "estshares": 3671400.136704,
             "timesincelast": 1020,
             "nethashrate": 62159452148
         }
     }
 }
 */
    
    NSMutableDictionary *status = [dict objectForKey:@"getpoolstatus"];
    
    NSMutableDictionary *data = [status objectForKey:@"data"];
    
    NSString *poolName                  = (NSString*)[data objectForKey:@"pool_name"];
    NSString *poolHashrate              = (NSString*)[data objectForKey:@"hashrate"];
    NSString *estimatedSecondsPerBlock  = (NSString*)[data objectForKey:@"esttime"];
    NSString *secondsSinceLastBlock     = (NSString*)[data objectForKey:@"timesincelast"];

    
    
    self.poolName                 = poolName;
    self.poolHashrate             = [poolHashrate intValue];
    self.estimatedSecondsPerBlock = [estimatedSecondsPerBlock intValue];
    self.secondsSinceLastBlock    = [secondsSinceLastBlock intValue];
}



-(NSMutableDictionary*) callPoolAPIMethod: (NSString*)apiMethod {
    
    NSLog(@"Calling api method: %@", apiMethod);
    
    NSURL *url = [NSURL URLWithString:
                  [NSString stringWithFormat:@"%@&action=%@&api_key=%@",
                   self.apiURL,
                   apiMethod,
                   self.apiKey
                   ]
                  ];
    
    NSData *rawdata = [NSData dataWithContentsOfURL:url];
    
    if( rawdata == nil) {
        NSLog(@"could not fetch data from pool API");
        return nil;
    }
    
    NSError *error;
    NSMutableDictionary  * dict = [NSJSONSerialization JSONObjectWithData:rawdata options: NSJSONReadingMutableContainers error: &error];
    
    if(error != nil) {
        NSLog(@"error: %@", error);
        return nil;
    }
    
    NSLog(@"dict: %@",dict);
    
    return dict;
}

@end