//
//  DCMFirstViewController.h
//  DogecoinManager
//
//  Created by Paul Brinkmann on 1/9/14.
//  Copyright (c) 2014 Paul Brinkmann. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DCMWallet.h"

@interface DCMWalletViewController : UIViewController {
    NSTimer* aTimer;
}

@property (weak, nonatomic) IBOutlet UITextField *walletAddressTextfield;

@property (weak, nonatomic) IBOutlet UILabel *balance;

@property DCMWallet* wallet;

@end
