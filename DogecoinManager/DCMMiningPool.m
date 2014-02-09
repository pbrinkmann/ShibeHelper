//
//  DCMMiningPool.m
//  DogecoinManager
//
//  Created by Paul Brinkmann on 1/18/14.
//  Copyright (c) 2014 Paul Brinkmann. All rights reserved.
//

#import "DCMMiningPool.h"

@interface DCMMiningPool ()


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
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"miningpool.websiteURL"])
    {
        
        self.websiteURL = [[NSUserDefaults standardUserDefaults]
                        objectForKey:@"miningpool.websiteURL"];
        
        self.apiKey = [[NSUserDefaults standardUserDefaults]
                        objectForKey:@"miningpool.apiKey"];
    }
}

- (void)saveDataToUserDefaults
{
    [[NSUserDefaults standardUserDefaults]
     setObject:self.websiteURL forKey:@"miningpool.websiteURL"];
    
    [[NSUserDefaults standardUserDefaults]
     setObject:self.apiKey forKey:@"miningpool.apiKey"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)updatePoolInfo
{
    if( self.websiteURL == nil || self.apiKey == nil) { NSLog(@"DCMMiningPool skipping initial load of mining pool"); return; }
    
    
    [self doUserStatusAPICall];
    [self doUserBalanceAPICall];
    [self doPoolStatusAPICall];
    [self doBlocksFoundAPICall];
    [self doPublicAPICall];
    
    self.lastUpdate = [NSDate date];

    // TODO: this should actually happen when apiKey and websiteURL get set
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
    NSString *currentDifficulty         = (NSString*)[data objectForKey:@"networkdiff"];

    
    
    self.poolName                 = poolName;
    self.poolHashrate             = [poolHashrate intValue];
    self.estimatedSecondsPerBlock = [estimatedSecondsPerBlock intValue];
    self.secondsSinceLastBlock    = [secondsSinceLastBlock intValue];
    self.currentDifficulty        = [currentDifficulty intValue];
}

-(void)doBlocksFoundAPICall
{
    NSMutableDictionary *dict = [self callPoolAPIMethod:@"getblocksfound"];
    
    if( dict == nil) {
        NSLog(@"API call failed, cancelling getblocksfound update");
        return;
    }
    
    
    /*
     getblocksfound: {
        version: "1.0.0",
        runtime: 3.115177154541,
        data: [
            {
                id: 706,
                height: 90158,
                blockhash: "df582a7f4e96be6740e88a1dfba8eca1591179a8eae7d66618ee94eb73d5fa03",
                confirmations: 65,
                amount: 580339,
                difficulty: 1361.12751474,
                time: 1391759608,
                accounted: 1,
                account_id: 10795,
                worker_name: "umbra.1",
                shares: 6563345,
                share_id: 331141810,
                finder: "umbra",
                is_anonymous: 0,
                estshares: 5575178
            },
            {
                id: 705,
                height: 90061,
                blockhash: "a239a63b3432fa6c3911192865f722625e9a9771fc7cdcd65226dd0cde0e8cca",
                confirmations: 66,
                amount: 239173.95106218,
                difficulty: 1361.12751474,
                time: 1391754198,
                accounted: 1,
                account_id: 7091,
                worker_name: "Nalix.Jerry",
                shares: 4898159,
                share_id: 330217963,
                finder: "Nalix",
                is_anonymous: 0,
                estshares: 5575178
            },
            ...
     */
    
    NSMutableDictionary *status = [dict objectForKey:@"getblocksfound"];
    
    NSMutableArray *data   = [status objectForKey:@"data"];
    NSMutableDictionary *lastBlock = [data objectAtIndex:0];        // TODO: this won't work on a brand new pool
    NSMutableDictionary *twoBlocksAgo = [data objectAtIndex:1];     // TODO: this won't work on a brand new pool

    
    NSString *lastBlockAmount                   = (NSString*)[lastBlock objectForKey:@"amount"];
    NSString *lastBlockDifficulty               = (NSString*)[lastBlock objectForKey:@"difficulty"];
    NSString *lastBlockFinder                   = (NSString*)[lastBlock objectForKey:@"finder"];
    NSString *expectedSharesUntilLastBlockFound = (NSString*)[lastBlock objectForKey:@"estshares"];
    NSString *actualSharesToFindLastBlock       = (NSString*)[lastBlock objectForKey:@"shares"];

    NSString *lastBlockTimestamp                = (NSString*)[lastBlock objectForKey:@"time"];
    NSString *twoBlocksAgoTimestamp             = (NSString*)[twoBlocksAgo objectForKey:@"time"];

    
    
    self.lastBlockAmount                   = [lastBlockAmount intValue];
    self.lastBlockDifficulty               = [lastBlockDifficulty intValue];

    self.timeToFindLastBlock                     = [lastBlockTimestamp intValue] - [twoBlocksAgoTimestamp intValue];
    self.lastBlockFinder                   = lastBlockFinder;
    self.expectedSharesUntilLastBlockFound = [expectedSharesUntilLastBlockFound intValue];
    self.actualSharesToFindLastBlock       = [actualSharesToFindLastBlock intValue];
}

-(void)doPublicAPICall
{
    NSMutableDictionary *dict = [self callPoolAPIMethod:@"public"];
    
    if( dict == nil) {
        NSLog(@"API call failed, cancelling public update");
        return;
    }
    
    /*
     
     {
     pool_name: "TeamDoge Digging",
     hashrate: 1139421,
     workers: 2545,
     shares_this_round: 2597992,
     last_block: 92922,
     network_hashrate: 100408944027
     }
     */
    
    NSString *poolSharesThisRound  = (NSString*)[dict objectForKey:@"shares_this_round"];

    self.poolSharesThisRound = [poolSharesThisRound intValue];
}


-(NSMutableDictionary*) callPoolAPIMethod: (NSString*)apiMethod {
    
    NSLog(@"Calling api method: %@", apiMethod);
    
    NSURL *url = [NSURL URLWithString:
                  [NSString stringWithFormat:@"%@/index.php?page=api&action=%@&api_key=%@",
                   self.websiteURL,
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
    
    // NSLog(@"dict: %@",dict);
    
    return dict;
}

@end