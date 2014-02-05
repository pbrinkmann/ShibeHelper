//
//  DCMEditMiningPoolViewController.h
//  DogecoinManager
//
//  Created by Paul Brinkmann on 1/19/14.
//  Copyright (c) 2014 Paul Brinkmann. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DCMEditMiningPoolViewController : UIViewController

@property NSString* miningPoolWebsiteURL;
@property NSString* miningPoolAPIKey;

-(void) updateDefaultMiningPoolAdress:(NSString*)defaultAPIUrl andKey:(NSString*)defaultAPIKey;


@end
