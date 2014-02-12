//
//  DCMMiningPool.m
//  DogecoinManager
//
//  Created by Paul Brinkmann on 1/18/14.
//  Copyright (c) 2014 Paul Brinkmann. All rights reserved.
//

#import "DCMMiningPool.h"

@interface DCMMiningPool ()

@property BOOL stillOnSameBlock;

@end

@implementation DCMMiningPool

-(id)init
{
    self = [super init];
    
    // TODO: ... make these steps more dynamic, this current setup is pretty fragile
    self.numUpdateSteps = 5;
    
    if(self) {


        [self loadDataFromUserDefaults];
    }
    
    return self;
}

- (void)loadDataFromUserDefaults
{
    NSUserDefaults* stdDefaults =[NSUserDefaults standardUserDefaults];

    if ([stdDefaults objectForKey:@"miningpool.websiteURL"])
    {
        self.websiteURL                     = [stdDefaults objectForKey:@"miningpool.websiteURL"];
        self.apiKey                         = [stdDefaults objectForKey:@"miningpool.apiKey"];
        self.lastUpdate                     = [stdDefaults objectForKey:@"miningpool.lastUpdate"];
        
        self.confirmedBalance               = [[stdDefaults objectForKey:@"miningpool.confirmedBalance"] floatValue];
        self.unconfirmedBalance             = [[stdDefaults objectForKey:@"miningpool.unconfirmedBalance"] floatValue];
        
        self.poolName                       = [stdDefaults objectForKey:@"miningpool.poolName"];
        self.poolHashrate                   = [[stdDefaults objectForKey:@"miningpool.poolHashrate"] intValue];
        self.secondsSinceLastBlock          = [[stdDefaults objectForKey:@"miningpool.secondsSinceLastBlock"] intValue];
        self.estimatedSecondsPerBlock       = [[stdDefaults objectForKey:@"miningpool.estimatedSecondsPerBlock"] intValue];
        self.currentDifficulty              = [[stdDefaults objectForKey:@"miningpool.currentDifficulty"] intValue];
        self.currentNetworkBlock            = [[stdDefaults objectForKey:@"miningpool.currentNetworkBlock"] intValue];
        self.lastBlockFound                 = [[stdDefaults objectForKey:@"miningpool.lastBlockFound"] intValue];
        
        self.poolSharesThisRound            = [[stdDefaults objectForKey:@"miningpool.poolSharesThisRound"] intValue];
        
        self.hashrate                       = [[stdDefaults objectForKey:@"miningpool.hashrate"] intValue];
        self.validSharesThisRound           = [[stdDefaults objectForKey:@"miningpool.validSharesThisRound"] intValue];
        self.invalidSharesThisRound         = [[stdDefaults objectForKey:@"miningpool.invalidSharesThisRound"] intValue];
        
        self.lastBlockAmount                    = [[stdDefaults objectForKey:@"miningpool.lastBlockAmount"] intValue];
        self.lastBlockDifficulty                = [[stdDefaults objectForKey:@"miningpool.lastBlockDifficulty"] intValue];
        self.timeToFindLastBlock                = [[stdDefaults objectForKey:@"miningpool.timeToFindLastBlock"] intValue];
        self.expectedSharesUntilLastBlockFound  = [[stdDefaults objectForKey:@"miningpool.expectedSharesUntilLastBlockFound"] intValue];
        self.actualSharesToFindLastBlock        = [[stdDefaults objectForKey:@"miningpool.actualSharesToFindLastBlock"] intValue];
        self.lastBlockFinder                    = [stdDefaults objectForKey:@"miningpool.lastBlockFinder"];
    }
    else {
        // This is the only value (other than URL and key) that's accessed when loading info, so it needs a default value
        // I actually don't know if Objective-C sets default values for members or not, so maybe this is unneccesary
        self.lastBlockFound = 0;
        
        // quick hacks to prevent NaNs from displayinh
        self.validSharesThisRound = 1;
        self.estimatedSecondsPerBlock = 1;
        self.expectedSharesUntilLastBlockFound = 1;
        self.poolSharesThisRound = 1;
    }
}

- (void)saveDataToUserDefaults {
    NSUserDefaults *stdDefaults = [NSUserDefaults standardUserDefaults];

    [stdDefaults setObject:self.websiteURL forKey:@"miningpool.websiteURL"];
    [stdDefaults setObject:self.apiKey forKey:@"miningpool.apiKey"];
    [stdDefaults setObject:self.lastUpdate forKey:@"miningpool.lastUpdate"];

    [stdDefaults setObject:[NSNumber numberWithFloat:self.confirmedBalance]
                    forKey:@"miningpool.confirmedBalance"];
    [stdDefaults setObject:[NSNumber numberWithFloat:self.unconfirmedBalance]
                    forKey:@"miningpool.unconfirmedBalance"];

    [stdDefaults setObject:self.poolName forKey:@"miningpool.poolName"];
    [stdDefaults setObject:[NSNumber numberWithInt:self.poolHashrate]
                    forKey:@"miningpool.poolHashrate"];
    [stdDefaults setObject:[NSNumber numberWithInt:self.secondsSinceLastBlock]
                    forKey:@"miningpool.secondsSinceLastBlock"];
    [stdDefaults setObject:[NSNumber numberWithInt:self.estimatedSecondsPerBlock]
                    forKey:@"miningpool.estimatedSecondsPerBlock"];
    [stdDefaults setObject:[NSNumber numberWithInt:self.currentDifficulty]
                    forKey:@"miningpool.currentDifficulty"];
    [stdDefaults setObject:[NSNumber numberWithInt:self.currentNetworkBlock]
                    forKey:@"miningpool.currentNetworkBlock"];
    [stdDefaults setObject:[NSNumber numberWithInt:self.lastBlockFound]
                    forKey:@"lastBlockFound"];

    [stdDefaults setObject:[NSNumber numberWithInt:self.poolSharesThisRound]
                    forKey:@"miningpool.poolSharesThisRound"];

    [stdDefaults setObject:[NSNumber numberWithInt:self.hashrate] forKey:@"miningpool.hashrate"];
    [stdDefaults setObject:[NSNumber numberWithInt:self.validSharesThisRound]
                    forKey:@"miningpool.validSharesThisRound"];
    [stdDefaults setObject:[NSNumber numberWithInt:self.invalidSharesThisRound]
                    forKey:@"miningpool.invalidSharesThisRound"];

    [stdDefaults setObject:[NSNumber numberWithInt:self.lastBlockAmount]
                    forKey:@"miningpool.lastBlockAmount"];
    [stdDefaults setObject:[NSNumber numberWithInt:self.lastBlockDifficulty]
                    forKey:@"miningpool.lastBlockDifficulty"];
    [stdDefaults setObject:[NSNumber numberWithInt:self.timeToFindLastBlock]
                    forKey:@"miningpool.timeToFindLastBlock"];
    [stdDefaults setObject:[NSNumber numberWithInt:self.expectedSharesUntilLastBlockFound]
                    forKey:@"miningpool.expectedSharesUntilLastBlockFound"];
    [stdDefaults setObject:[NSNumber numberWithInt:self.actualSharesToFindLastBlock]
                    forKey:@"miningpool.actualSharesToFindLastBlock"];
    [stdDefaults setObject:self.lastBlockFinder forKey:@"miningpool.lastBlockFinder"];

    [stdDefaults synchronize];
}

-(NSString*)getStepName:(int)step
{
    switch (step) {
        case 0:
            return @"user status";
        case 1:
            return @"user balance";
        case 2:
            return @"pool status";
        case 3:
            return @"last block info";
        case 4:
            return @"current round progress";
        default:
            NSLog(@"Invalid getStepName step %d", step);
            return @"";
    }
}


-(BOOL)updatePoolInfoForStep:(int) step
{
    if( self.websiteURL == nil || self.apiKey == nil) { NSLog(@"DCMMiningPool skipping initial load of mining pool"); return FALSE; }
    
    switch (step) {
        case 0:
            return [self doUserStatusAPICall];
        case 1:
            return [self doUserBalanceAPICall];
        case 2:
            return [self doPoolStatusAPICall];
        case 3:
            return [self doBlocksFoundAPICall];
        case 4:
            if( [self doPublicAPICall] == FALSE ) return FALSE;

            self.lastUpdate = [NSDate date];
            
            // TODO: this should actually happen when apiKey and websiteURL get set
            [self saveDataToUserDefaults ];
            
            return TRUE;
            
        default:
            NSLog(@"Invalid updatePoolInfoForStep step %d", step);
            return FALSE;
    }
   
}

-(BOOL)doUserStatusAPICall
{
    NSMutableDictionary *dict = [self callPoolAPIMethod:@"getuserstatus"];
    
    if( dict == nil) {
        NSLog(@"API call failed, cancelling getuserstatus update");
        return FALSE;
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

    return TRUE;
}


-(BOOL)doUserBalanceAPICall
{
    NSMutableDictionary *dict = [self callPoolAPIMethod:@"getuserbalance"];
    
    if( dict == nil) {
        NSLog(@"API call failed, cancelling getuserbalance update");
        return FALSE;
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
    
    return TRUE;
}

-(BOOL)doPoolStatusAPICall
{
    NSMutableDictionary *dict = [self callPoolAPIMethod:@"getpoolstatus"];
    
    if( dict == nil) {
        NSLog(@"API call failed, cancelling getpoolstatus update");
        return FALSE;
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
    NSString *currentNetworkBlock       = (NSString*)[data objectForKey:@"currentnetworkblock"];
    NSString *lastBlockFound            = (NSString*)[data objectForKey:@"lastblock"];

    
    self.poolName                 = poolName;
    self.poolHashrate             = [poolHashrate intValue];
    self.estimatedSecondsPerBlock = [estimatedSecondsPerBlock intValue];
    self.secondsSinceLastBlock    = [secondsSinceLastBlock intValue];
    self.currentDifficulty        = [currentDifficulty intValue];
    self.currentNetworkBlock      = [currentNetworkBlock intValue];
    
    if( self.lastBlockFound == [lastBlockFound intValue] ) {
        self.stillOnSameBlock = TRUE;
    }
    else {
        self.stillOnSameBlock = FALSE;
    }
    
    self.lastBlockFound           = [lastBlockFound intValue];

    
    return TRUE;
}

-(BOOL)doBlocksFoundAPICall
{
    NSMutableDictionary *dict = [self callPoolAPIMethod:@"getblocksfound"];
    
    if( dict == nil) {
        NSLog(@"API call failed, cancelling getblocksfound update");
        return FALSE;
    }
    if( self.stillOnSameBlock ) {
        NSLog(@"Skipping getblocksfound API call since no new blocks have been found since last time we checked");
        return TRUE;
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

    self.timeToFindLastBlock               = [lastBlockTimestamp intValue] - [twoBlocksAgoTimestamp intValue];
    self.lastBlockFinder                   = lastBlockFinder;
    self.expectedSharesUntilLastBlockFound = [expectedSharesUntilLastBlockFound intValue];
    self.actualSharesToFindLastBlock       = [actualSharesToFindLastBlock intValue];
    
    return TRUE;
}

-(BOOL)doPublicAPICall
{
    NSMutableDictionary *dict = [self callPoolAPIMethod:@"public"];
    
    if( dict == nil) {
        NSLog(@"API call failed, cancelling public update");
        return FALSE;
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
    
    return TRUE;
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
        NSLog(@"could not fetch data from pool API for method %@", apiMethod);
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
