//
//  DCMCGMinerPoolTableViewCell.h
//  DogecoinManager
//
//  Created by Paul Brinkmann on 3/28/14.
//  Copyright (c) 2014 Paul Brinkmann. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DCMCGMinerPoolTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *number;
@property (nonatomic, weak) IBOutlet UILabel *url;
@property (nonatomic, weak) IBOutlet UILabel *status;
@property (weak, nonatomic) IBOutlet UILabel *worker;


@end
