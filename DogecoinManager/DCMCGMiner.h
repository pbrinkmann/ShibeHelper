//
//  DCMCGMiner.h
//  DogecoinManager
//
//  Created by Paul Brinkmann on 3/11/14.
//  Copyright (c) 2014 Paul Brinkmann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCMCGMiner : NSObject <NSStreamDelegate>

// In Parameters
@property NSString* ipAddress;
@property int port;

// Out Parameters
@property NSString* cgminerVersion;
@property NSInteger cgminerHashrate;



-(void)fetchyDoShit:(void(^)())updateCompleteCallback;


@end

NSInputStream *_reader;
NSOutputStream *_writer;