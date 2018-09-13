//
//  ControlViewCell.h
//  SmartHome
//
//  Created by Apple on 3/20/18.
//  Copyright © 2018 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ControlViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end
