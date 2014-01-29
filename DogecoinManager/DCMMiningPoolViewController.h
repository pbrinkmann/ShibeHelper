//
//  DCMSecondViewController.h
//  DogecoinManager
//
//  Created by Paul Brinkmann on 1/9/14.
//  Copyright (c) 2014 Paul Brinkmann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCMMiningPool.h"

@interface DCMMiningPoolViewController : UIViewController {
    NSTimer* lastUpdatedTimer;
}

@property DCMMiningPool* miningPool;

@end
