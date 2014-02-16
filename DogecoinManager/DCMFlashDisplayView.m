//
//  DCMFlashDisplayView.m
//  DogecoinManager
//
//  Created by Paul Brinkmann on 2/12/14.
//  Copyright (c) 2014 Paul Brinkmann. All rights reserved.
//

#import "DCMFlashDisplayView.h"
#import "DCMUtils.h"

@interface DCMFlashDisplayView ()

// @property CGRect initialFrame;
// @property CGRect zeroFrame;

@property(strong, nonatomic) NSString *text;
@property float initialDelay;
@property float duration;


@end

@implementation DCMFlashDisplayView

- (void)initViewWithText:(NSString *)text
            initialDelay:(float)initialDelay
                duration:(float)duration
{
    self.text = text;
    self.initialDelay = initialDelay;
    self.duration = duration;

 

     // Sadly, setting the self.frame to the zeroFrame value does fuckall, so the first
     // animation will just be the alpha fade in :(
     //
     // The frame also doesn't animated when in scrollview and the user scrolls
     //
     // So to avoid inconsistent behavior, I'm ditching the grow/shrink effect for now
     //
     
/*
    CGRect frame = self.frame;

 
     self.initialFrame =
        CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
     self.zeroFrame = CGRectMake(frame.origin.x + frame.size.width / 2,
                                frame.origin.y + frame.size.height / 2, 0.0, 0.0);


     [self setFrame: self.zeroFrame];
*/
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGRect frame = self.frame;

    UIBezierPath *path = [UIBezierPath
        bezierPathWithRoundedRect:CGRectMake(2, 2, frame.size.width - 4, frame.size.height - 4)
                     cornerRadius:10];
    path.lineWidth = 1;
    
    [[DCMUtils greenColor] setFill];
    [path fill];

    UIFont *textFont = [UIFont systemFontOfSize:12];

    [DCMUtils drawVerticallyCenteredString:self.text
            withFont:textFont
              inRect:CGRectMake(0, 0, frame.size.width - 4, frame.size.height - 4)
           withColor:[UIColor whiteColor]];
}



- (void)doFlashAnimation {
    [UIView animateWithDuration:0.7
                          delay:self.initialDelay
                        options:UIViewAnimationOptionCurveEaseInOut
                        animations:^{
                                // [self setFrame: self.initialFrame];
                                self.alpha = 1.0;
                        }
                        completion:^(BOOL finished) {
                                [self doShrinkAnimation];
                        }
    ];
}

- (void)doShrinkAnimation {
    [UIView animateWithDuration:0.5
                          delay:self.duration
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                                    // [self setFrame: self.zeroFrame];
                                    self.alpha = 0.0;
                                }
                     completion:^(BOOL finished) {}
     ];
}

@end
