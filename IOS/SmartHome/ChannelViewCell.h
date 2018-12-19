//
//  ChannelViewCell.h
//  SmartHome
//
//  Created by Apple on 3/6/18.
//  Copyright © 2018 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChannelViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *onOffButton;
@property (weak, nonatomic) IBOutlet UIButton *controlButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIView *chanelBackgroundView;
-(void)setChanelSelected:(BOOL)selected;
@end
