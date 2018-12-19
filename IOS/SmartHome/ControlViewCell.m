//
//  ControlViewCell.m
//  SmartHome
//
//  Created by Apple on 3/20/18.
//  Copyright © 2018 Apple. All rights reserved.
//

#import "ControlViewCell.h"

@implementation ControlViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.selectButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5 );
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
