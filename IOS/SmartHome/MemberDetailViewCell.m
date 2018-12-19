//
//  MemberDetailViewCell.m
//  SmartHome
//
//  Created by Apple on 1/8/18.
//  Copyright © 2018 Apple. All rights reserved.
//

#import "MemberDetailViewCell.h"

@implementation MemberDetailViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}
- (IBAction)didPressedShare:(UISwitch *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didValueChange:value:)]) {
        [self.delegate didValueChange:self value:sender.isOn];
    }
}

@end
