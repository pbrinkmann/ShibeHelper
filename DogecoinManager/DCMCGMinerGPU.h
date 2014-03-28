//
//  DCMCGMinerGPU.h
//  DogecoinManager
//
//  Created by Paul Brinkmann on 3/23/14.
//  Copyright (c) 2014 Paul Brinkmann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCMCGMinerGPU : NSObject

@property int gpuNumber;
@property BOOL enabled;
@property NSString* status; // hopefully "Alive"
@property float temperature;
@property int fanSpeed;
@property int fanPercent;  // 0 - 100
@property int gpuClock;
@property int memoryClock;
@property float voltage;
@property int powertune;
@property int intensity;
@property int hashrate; // in KH/s
@property int sharesAccepted;
@property int sharedRejected;
@property int hardwareErrors;
@property int lastPoolSubmittedTo;  // index of last pool shares were submitted to, or -1 if none

-(instancetype)initWithDictionary:(NSDictionary*)dict;

@end
