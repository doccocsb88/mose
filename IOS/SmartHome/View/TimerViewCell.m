//
//  TimerViewCell.m
//  SmartHome
//
//  Created by Apple on 12/22/18.
//  Copyright © 2018 Apple. All rights reserved.
//

#import "TimerViewCell.h"
@interface TimerViewCell()
@property (strong, nonatomic) SHTimer *timer;
@end
@implementation TimerViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)updateContent:(SHTimer *)timer{
    self.timer = timer;
    self.onOffButton.selected = !timer.enable;
    
    if (timer.type == DeviceTypeCurtain) {
        self.timeLabel.text = [NSString stringWithFormat:@"%@ : %@",timer.timer,timer.status ? @"Mở" : @"Đóng"];
    }else{
        self.timeLabel.text = [NSString stringWithFormat:@"%@ : %@",timer.timer,timer.status ? @"On" : @"Off"];
    }
    
    UIColor *activeColor = [Helper colorFromHexString:@"#008744"];
    _t2Label.backgroundColor = timer.t2 ? activeColor : [UIColor grayColor];
    _t2Label.textColor = timer.t2 ?  [UIColor whiteColor] : [UIColor darkGrayColor];
    
    _t3Label.backgroundColor = timer.t3 ? activeColor : [UIColor grayColor];
    _t3Label.textColor = timer.t3 ?  [UIColor whiteColor] : [UIColor darkGrayColor];

    _t4Label.backgroundColor = timer.t4 ? activeColor : [UIColor grayColor];
    _t4Label.textColor = timer.t4 ?  [UIColor whiteColor] : [UIColor darkGrayColor];

    _t5Label.backgroundColor = timer.t5 ? activeColor : [UIColor grayColor];
    _t5Label.textColor = timer.t5 ?  [UIColor whiteColor] : [UIColor darkGrayColor];

    _t6Label.backgroundColor = timer.t6 ? activeColor : [UIColor grayColor];
    _t6Label.textColor = timer.t6 ?  [UIColor whiteColor] : [UIColor darkGrayColor];

    _t7Label.backgroundColor = timer.t7 ? activeColor : [UIColor grayColor];
    _t7Label.textColor = timer.t7 ?  [UIColor whiteColor] : [UIColor darkGrayColor];

    
    _cnLabel.backgroundColor = timer.t8 ? activeColor : [UIColor grayColor];
    _cnLabel.textColor = timer.t8 ?  [UIColor whiteColor] : [UIColor darkGrayColor];

}
- (IBAction)pressedEnableButton:(id)sender {
    if (self.pressedEnableHandle) {
        self.pressedEnableHandle();

    }
}
@end
