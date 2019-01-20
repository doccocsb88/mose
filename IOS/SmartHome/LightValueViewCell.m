//
//  LightValueViewCell.m
//  SmartHome
//
//  Created by Apple on 3/31/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import "LightValueViewCell.h"

@implementation LightValueViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.slider setThumbImage:[[UIImage imageNamed: @"ic_slider_thumb"] stretchableImageWithLeftCapWidth: 5 topCapHeight: 10] forState:UIControlStateNormal];
    _slider.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 2.0);
    NSInteger value = self.slider.value;
    self.valueLabel.text = [NSString stringWithFormat:@"%ld %@",value,@"%"];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)sliderChanged:(id)sender {
    [self setupValue];
    if ([self.delegate respondsToSelector:@selector(didChangeValueForKey:)]){
        int value = self.slider.value;
        if (value <= 10) {
            value = 0;
        }else if (value >= 90){
            value = 100;
        }else{
            int tmpInt = value / 10;
            value = tmpInt * 10;
        }
        self.slider.value = value;
        [self.delegate didChangeCell:self.slider.tag value:value];
    }
}
-(void)setContentView:(Device *)device type:(NSInteger)type{
    self.device = device;
    self.slider.value = device.value;
    self.slider.tag = device.id;
    self.slider.userInteractionEnabled = type == 0;
    [self setupValue];
}
-(void)setContentView:(Device *)device type:(NSInteger)type selected:(BOOL)selected{
    self.device = device;
    self.slider.value = device.value;
    self.slider.tag = device.id;
    self.slider.userInteractionEnabled = type == 0;
    [self setupValue];
    if (selected) {
        self._backgroundView.backgroundColor = [UIColor redColor];
    }else{
        self._backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    }
}
-(void)setupValue{
    NSInteger value = self.slider.value;
    self.valueLabel.text = [NSString stringWithFormat:@"%ld %@",value,@"%"];

}
@end
