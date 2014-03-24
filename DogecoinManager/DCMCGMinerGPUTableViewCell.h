//
//  DCMCGMinerGPUTableViewCell.h
//  DogecoinManager
//
//  Created by Paul Brinkmann on 3/23/14.
//  Copyright (c) 2014 Paul Brinkmann. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DCMCGMinerGPUTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *gpuName;
@property (nonatomic, weak) IBOutlet UILabel *hashrate;
@property (nonatomic, weak) IBOutlet UILabel *temperature;
@property (weak, nonatomic) IBOutlet UILabel *gpuClock;
@property (weak, nonatomic) IBOutlet UILabel *memoryClock;
@property (weak, nonatomic) IBOutlet UILabel *intensity;

@end
