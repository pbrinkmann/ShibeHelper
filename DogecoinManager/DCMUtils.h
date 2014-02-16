//
//  DCMUtils.h
//  DogecoinManager
//
//  Created by Paul Brinkmann on 1/21/14.
//  Copyright (c) 2014 Paul Brinkmann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCMUtils : NSObject

+(NSString*) lastUpdatedForInterval:(NSTimeInterval) interval;
+(int) getAvgBlockRewardForBlock:(int)block;
+(BOOL) isTallDevice;
+(void) drawVerticallyCenteredString:(NSString *)s withFont:(UIFont *)font inRect:(CGRect)contextRect withColor:(UIColor*)color;


+(UIColor*) lightBlueColor;
+(UIColor*) darkBlueColor;
+(UIColor*) yellowColor;
+(UIColor*) greenColor;
+(UIColor*) orangeColor;
+(UIColor*) redColor;
+(UIColor*) maroonColor;
+(UIColor*) greyColor;


@end

