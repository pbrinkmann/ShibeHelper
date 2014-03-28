//
//  DCMCGMinerPool.m
//  DogecoinManager
//
//  Created by Paul Brinkmann on 3/28/14.
//  Copyright (c) 2014 Paul Brinkmann. All rights reserved.
//

#import "DCMCGMinerPool.h"

@implementation DCMCGMinerPool

-(instancetype)initWithDictionary:(NSDictionary*)dict
{
    self = [super init];
    if(self) {
        self.poolNumber = [[dict objectForKey:@"POOL"] intValue];
        self.status     = [dict objectForKey:@"Status"];
        self.poolURL    = [dict objectForKey:@"URL"];
        self.workerName = [dict objectForKey:@"User"];
    }
    
    return self;
}

@end
