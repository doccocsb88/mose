//
//  MemberViewCell.m
//  SmartHome
//
//  Created by Apple on 1/8/18.
//  Copyright © 2018 Apple. All rights reserved.
//

#import "MemberViewCell.h"
#import "FirebaseHelper.h"
@implementation MemberViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)updateContent:(SHMember *)user edit:(BOOL)edit{
    self.user = user;
    if (edit) {
        [_removeButton setHidden:false];
        _titleMarginLeft.constant = 50;

    }else{
        _titleMarginLeft.constant = 10;
        [_removeButton setHidden:true];

    }
    [self updateConstraintsIfNeeded];
}
- (IBAction)didPressedShare:(id)sender {
    UISwitch *sharebutton = (UISwitch *)sender;
    NSInteger tag = sharebutton.tag;
    if(_simpleBlock){
        _simpleBlock(tag);
    }
    
}
- (IBAction)didPressedRemove:(id)sender {
    [[FirebaseHelper sharedInstance] deleteMember:self.user];
}

@end
