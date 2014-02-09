//
//  DCMUtils.m
//  DogecoinManager
//
//  Created by Paul Brinkmann on 1/21/14.
//  Copyright (c) 2014 Paul Brinkmann. All rights reserved.
//

#import "DCMUtils.h"

@implementation DCMUtils

+(NSString*) lastUpdatedForInterval:(NSTimeInterval) interval
{
    if(interval < 1 ) interval = 1;
    
    if(interval < 2)  {
        return @"last updated 1 second  ago";
    }
    else if( interval < 60 ) {
        return [NSString stringWithFormat:@"last updated %d seconds ago", (int)interval];
    }
    else if ( interval < 120)  {
        return @"last updated 1 minute ago";
    }
    else if ( interval < 3600) {
        return [NSString stringWithFormat:@"last updated %d minutes ago", (int)interval/60];
    }
    else if ( interval < 7200 ) {
        return @"last updated 1 hour ago";
    }
    else {
        return [NSString stringWithFormat:@"last updated %d hours ago", (int)interval/3600];
    }
 
}

+(int) getAvgBlockRewardForBlock:(int)block
{
    /*
     from wikipedia:
     
     1-100,000          0-1,000,000 (random)	8 December, 2013                50,000,000,000	50,000,000,000
     100,001-200,000	0-500,000 (random)      14 February, 2014 (estimated)	25,000,000,000	75,000,000,000
     200,001-300,000	0-250,000 (random)      25 April, 2014 (estimated)      12,500,000,000	87,500,000,000
     300,001-400,000	0-125,000 (random)      3 July, 2014 (estimated)        6,250,000,000	93,750,000,000
     400,001-500,000	0-62,500 (random)       10 September, 2014 (estimated)	3,125,000,000	96,875,000,000
     500,001-600,000	0-31,250 (random)       19 November, 2014 (estimated)	1,562,000,000	98,437,500,000
     600,001+           10,000 (fixed)          27 January, 2015 (estimated)	5,256,000,000 per year	No limit
     */
    
    if( block < 100001) {
        return 1000000/2;
    }
    else if (block < 200001) {
        return 500000/2;
    }
    else if (block < 300001) {
        return 250000/2;
    }
    else if (block < 400001) {
        return 125000/2;
    }
    else if (block < 500001) {
        return 62500/2;
    }
    else if (block < 600001) {
        return 31250/2;
    }
    else {
        return 10000;
    }
}


@end
