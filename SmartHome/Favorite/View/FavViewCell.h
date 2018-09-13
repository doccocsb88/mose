//
//  FavViewCell.h
//  SmartHome
//
//  Created by Apple on 3/12/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *favThumb;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;

@end
