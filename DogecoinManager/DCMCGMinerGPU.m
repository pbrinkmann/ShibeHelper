//
//  DCMCGMinerGPU.m
//  DogecoinManager
//
//  Created by Paul Brinkmann on 3/23/14.
//  Copyright (c) 2014 Paul Brinkmann. All rights reserved.
//

#import "DCMCGMinerGPU.h"

@implementation DCMCGMinerGPU


-(instancetype)initWithDictionary:(NSDictionary*)dict
{
    self = [super init];
    if(self) {

        self.gpuNumber      = [[dict objectForKey:@"GPU"] intValue];
        self.enabled        = [[dict objectForKey:@"Enabled"] isEqualToString:@"Y"] ? TRUE : FALSE;
        self.status         = [dict objectForKey:@"Status"];
        self.temperature    = [[dict objectForKey:@"Temperature"] floatValue];
        self.fanSpeed       = [[dict objectForKey:@"Fan Speed"] intValue];
        self.fanPercent     = [[dict objectForKey:@"Fan Percent"] intValue];
        self.gpuClock       = [[dict objectForKey:@"GPU Clock"] intValue];
        self.memoryClock    = [[dict objectForKey:@"Memory Clock"] intValue];
        self.voltage        = [[dict objectForKey:@"GPU Voltage"] floatValue];
        self.powertune      = [[dict objectForKey:@"Powertune"] intValue];
        self.intensity      = [[dict objectForKey:@"Intensity"] intValue];
        self.hashrate       = (int) ([[dict objectForKey:@"MHS 5s"] floatValue] * 1000); // in KH/s
        self.sharesAccepted = [[dict objectForKey:@"Accepted"] intValue];
        self.sharedRejected = [[dict objectForKey:@"Rejected"] intValue];
        self.hardwareErrors = [[dict objectForKey:@"Hardware Errors"] intValue];
    }
    
    return self;
}

@end
