//
//  TimerViewCell.h
//  SmartHome
//
//  Created by Apple on 12/22/18.
//  Copyright © 2018 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHTimer+CoreDataClass.h"
#import "Helper.h"
NS_ASSUME_NONNULL_BEGIN

@interface TimerViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *repeatLabel;
@property (weak, nonatomic) IBOutlet UIButton *onOffButton;
@property (weak, nonatomic) IBOutlet UILabel *t2Label;
@property (weak, nonatomic) IBOutlet UILabel *t3Label;
@property (weak, nonatomic) IBOutlet UILabel *t4Label;
@property (weak, nonatomic) IBOutlet UILabel *t5Label;
@property (weak, nonatomic) IBOutlet UILabel *t6Label;
@property (weak, nonatomic) IBOutlet UILabel *t7Label;
@property (weak, nonatomic) IBOutlet UILabel *cnLabel;
@property (strong, nonatomic)  void(^pressedEnableHandle)(void);

-(void)updateContent:(SHTimer *)timer;
-(void)updateContent:(SHTimer *)timer deviceType:(DeviceType)type;

@end

NS_ASSUME_NONNULL_END
