//
//  DCMCGMinerPool.h
//  DogecoinManager
//
//  Created by Paul Brinkmann on 3/28/14.
//  Copyright (c) 2014 Paul Brinkmann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCMCGMinerPool : NSObject

@property int poolNumber;
// @property NSString* poolName;  maybe sgminer has this?
@property NSString* poolURL;
@property NSString* workerName;
@property NSString* status;  // hopefully "Alive"

-(instancetype)initWithDictionary:(NSDictionary*)dict;


@end
