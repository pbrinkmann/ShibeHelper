//
//  DCMFlashDisplayView.h
//  DogecoinManager
//
//  Created by Paul Brinkmann on 2/12/14.
//  Copyright (c) 2014 Paul Brinkmann. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DCMFlashDisplayView : UIView

-(void)initViewWithText:(NSString *)text
           initialDelay:(float)initialDelay
               duration:(float)duration;

-(void)doFlashAnimation;

@end
