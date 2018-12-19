//
//  MemberDetailViewCell.h
//  SmartHome
//
//  Created by Apple on 1/8/18.
//  Copyright © 2018 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MemberDetailDelegate <NSObject>
-(void)didValueChange:(id)sender value:(BOOL)value;
@end
@interface MemberDetailViewCell : UITableViewCell
@property (weak, nonatomic) id<MemberDetailDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UISwitch *sharebutton;

@end
