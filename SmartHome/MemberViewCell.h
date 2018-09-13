//
//  MemberViewCell.h
//  SmartHome
//
//  Created by Apple on 1/8/18.
//  Copyright © 2018 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHMember.h"
@interface MemberViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *displayNameLabel;
@property (weak, nonatomic) IBOutlet UISwitch *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *removeButton;
@property(strong, nonatomic) SHMember *user;
@property (strong, nonatomic) void (^simpleBlock)(NSInteger);
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleMarginLeft;
-(void)updateContent:(SHMember *)user edit:(BOOL)edit;
@end
