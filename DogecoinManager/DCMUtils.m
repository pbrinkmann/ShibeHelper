//
//  DCMUtils.m
//  DogecoinManager
//
//  Created by Paul Brinkmann on 1/21/14.
//  Copyright (c) 2014 Paul Brinkmann. All rights reserved.
//

#import "DCMUtils.h"

@implementation DCMUtils

+(NSString*) lastUpdatedForInterval:(NSTimeInterval) interval
{
    if(interval < 1 ) interval = 1;
    
    if(interval < 2)  {
        return @"last updated 1 second  ago";
    }
    else if( interval < 60 ) {
        return [NSString stringWithFormat:@"last updated %d seconds ago", (int)interval];
    }
    else if ( interval < 120)  {
        return @"last updated 1 minute ago";
    }
    else if ( interval < 3600) {
        return [NSString stringWithFormat:@"last updated %d minutes ago", (int)interval/60];
    }
    else if ( interval < 7200 ) {
        return @"last updated 1 hour ago";
    }
    else {
        return [NSString stringWithFormat:@"last updated %d hours ago", (int)interval/3600];
    }
 
}

+(int) getAvgBlockRewardForBlock:(int)block
{
    /*
     from wikipedia:
     
     1-100,000          0-1,000,000 (random)	8 December, 2013                50,000,000,000	50,000,000,000
     100,001-200,000	0-500,000 (random)      14 February, 2014 (estimated)	25,000,000,000	75,000,000,000
     200,001-300,000	0-250,000 (random)      25 April, 2014 (estimated)      12,500,000,000	87,500,000,000
     300,001-400,000	0-125,000 (random)      3 July, 2014 (estimated)        6,250,000,000	93,750,000,000
     400,001-500,000	0-62,500 (random)       10 September, 2014 (estimated)	3,125,000,000	96,875,000,000
     500,001-600,000	0-31,250 (random)       19 November, 2014 (estimated)	1,562,000,000	98,437,500,000
     600,001+           10,000 (fixed)          27 January, 2015 (estimated)	5,256,000,000 per year	No limit
     */
    
    if( block < 100001) {
        return 1000000/2;
    }
    else if (block < 200001) {
        return 500000/2;
    }
    else if (block < 300001) {
        return 250000/2;
    }
    else if (block < 400001) {
        return 125000/2;
    }
    else if (block < 500001) {
        return 62500/2;
    }
    else if (block < 600001) {
        return 31250/2;
    }
    else {
        return 10000;
    }
}

+ (BOOL)isTallDevice {
    return [[UIScreen mainScreen] bounds].size.height >= 568 ? TRUE : FALSE;
}

+ (void)drawVerticallyCenteredString:(NSString *)s
                            withFont:(UIFont *)font
                              inRect:(CGRect)contextRect
                           withColor:(UIColor *)color {
    

    CGFloat fontHeight  = font.lineHeight;
    CGFloat yOffset     = (contextRect.size.height - fontHeight) / 2.0;

    CGRect textRect                     = CGRectMake(0, yOffset, contextRect.size.width, fontHeight);
    NSMutableParagraphStyle *textStyle  = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    textStyle.lineBreakMode             = NSLineBreakByWordWrapping;
    textStyle.alignment                 = NSTextAlignmentCenter;

    DLog(@"Drawing text %@ in rect %@ with text rect: %@", s, NSStringFromCGRect(contextRect), NSStringFromCGRect(textRect));

    
    [s drawInRect:textRect
        withAttributes:@{
                           NSFontAttributeName : font,
                           NSParagraphStyleAttributeName : textStyle,
                           NSForegroundColorAttributeName : color
                       }];
}

//
// colors from:
// https://developer.apple.com/library/ios/documentation/userexperience/conceptual/mobilehig/ColorImagesText.html#//apple_ref/doc/uid/TP40006556-CH58-SW1
//

+ (UIColor*) lightBlueColor
{
    return [UIColor colorWithRed:75.f/255 green:202.f/255 blue:248.f/255 alpha:1];
}
+ (UIColor*) darkBlueColor
{
    return [UIColor colorWithRed:0.f/255 green:125.f/255 blue:251.f/255 alpha:1];
}
+ (UIColor*) yellowColor
{
    return [UIColor colorWithRed:255.f/255 green:202.f/255 blue:46.f/255 alpha:1];
}
+ (UIColor*) greenColor
{
    return [UIColor colorWithRed:72.f/255 green:217.f/255 blue:107.f/255 alpha:1];
}
+ (UIColor*) orangeColor
{
    return [UIColor colorWithRed:255.f/255 green:146.f/255 blue:35.f/255 alpha:1];
}
+ (UIColor*)redColor
{
    return [UIColor colorWithRed:255.f/255 green:50.f/255 blue:53.f/255 alpha:1];
}
+ (UIColor*)maroonColor
{
    return [UIColor colorWithRed:255.f/255 green:33.f/255 blue:86.f/255 alpha:1];
}
+ (UIColor*)greyColor
{
    return [UIColor colorWithRed:142.f/255 green:142.f/255 blue:147.f/255 alpha:1];
}

@end
