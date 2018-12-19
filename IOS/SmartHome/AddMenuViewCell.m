//
//  AddMenuViewCell.m
//  SmartHome
//
//  Created by Apple on 3/23/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import "AddMenuViewCell.h"

@implementation AddMenuViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
//    self.menuBackgroundView.layer.borderColor = [UIColor blackColor].CGColor;
//    self.menuBackgroundView.layer.borderWidth = 1.0;
//    self.menuBackgroundView.layer.cornerRadius = 5.0;
//    self.menuBackgroundView.layer.masksToBounds = true;
    self.menuBackgroundView.backgroundColor = [UIColor blackColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
