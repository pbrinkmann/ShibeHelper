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


@end
