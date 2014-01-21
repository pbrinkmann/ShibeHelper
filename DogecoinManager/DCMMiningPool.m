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

        NSLog(@"TODO: load saved mining pool URL/APIkey");
        
        [self loadDataFromUserDefaults];
    }
    
    return self;
}

- (void)loadDataFromUserDefaults
{
    // TODO: namespace these default keys

    // TODO: namespace these default keys

    // TODO: namespace these default keys

    // TODO: namespace these default keys
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"apiURL"])
    {
        
        self.apiURL = [[NSUserDefaults standardUserDefaults]
                        objectForKey:@"apiURL"];
        
        self.apiKey = [[NSUserDefaults standardUserDefaults]
                        objectForKey:@"apiKey"];
    }
}

- (void)saveDataToUserDefaults
{
    [[NSUserDefaults standardUserDefaults]
     setObject:self.apiURL forKey:@"apiURL"];
    
    [[NSUserDefaults standardUserDefaults]
     setObject:self.apiKey forKey:@"apiKey"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)updatePoolInfo
{
    if( self.apiURL == nil || self.apiKey == nil) { NSLog(@"DCMMiningPool skipping initial load of mining pool"); return; }
    
    NSString* apiMethod = @"getuserstatus";
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
        return;
    }
    
    NSError *error;
    
    NSMutableDictionary  * dict = [NSJSONSerialization JSONObjectWithData:rawdata options: NSJSONReadingMutableContainers error: &error];
    
    NSLog(@"dict: %@",dict);
    NSLog(@"error: %@", error);
    
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
    
    NSMutableDictionary *data = [status objectForKey:@"data"];
    NSMutableDictionary *shares = [data objectForKey:@"shares"];
   
    NSString *hashRate = (NSString*)[data objectForKey:@"hashrate"];
    NSString *validShares = (NSString*)[shares objectForKey:@"valid"];
    NSString *invalidShares = (NSString*)[shares objectForKey:@"invalid"];

    
    NSLog(@"hashRate: %@", hashRate);
    
    self.hashrateKHPS = [NSNumber numberWithInt:[hashRate intValue]];
    self.validSharesThisRound = [NSNumber numberWithInt:[validShares intValue]];
    self.invalidSharesThisRound = [NSNumber numberWithInt:[invalidShares intValue]];

    
    //////// GET USER BALANCE ////////
    

    
    apiMethod = @"getuserbalance";
    url = [NSURL URLWithString:
                  [NSString stringWithFormat:@"%@&action=%@&api_key=%@",
                   self.apiURL,
                   apiMethod,
                   self.apiKey
                   ]
                  ];
    
    rawdata = [NSData dataWithContentsOfURL:url];
    
    if( rawdata == nil) {
        NSLog(@"could not fetch data from pool API");
        return;
    }
    

    
    dict = [NSJSONSerialization JSONObjectWithData:rawdata options: NSJSONReadingMutableContainers error: &error];
    
    NSLog(@"dict: %@",dict);
    NSLog(@"error: %@", error);
    
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
    
    data = [balance objectForKey:@"data"];
    
    NSString *confirmed = (NSString*)[data objectForKey:@"confirmed"];
    NSString *unconfrmed = (NSString*)[data objectForKey:@"unconfirmed"];
    
    
   
    self.confirmedBalance = [NSNumber numberWithInt:[confirmed intValue]];
    self.unconfirmedBalance = [NSNumber numberWithInt:[unconfrmed intValue]];
    
    
    // TODO: this should actually happen when apiKey and apiURL get set
    [self saveDataToUserDefaults ];
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

@end