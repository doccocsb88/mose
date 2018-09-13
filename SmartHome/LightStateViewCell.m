//
//  LightStateViewCell.m
//  SmartHome
//
//  Created by Apple on 3/31/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import "LightStateViewCell.h"

@implementation LightStateViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.valueLabel.text = @"100 %";
    self.onOffButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.thumbnail.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self._backgroundView.layer.cornerRadius = 10.0;
    self._backgroundView.layer.masksToBounds = YES;
    UIImageView *bgzView = (UIImageView *)[self viewWithTag:5];
    if (bgzView) {
        UIImage *inputImage = [UIImage imageNamed:@"ic_device_bg"];
        
        UIImage *xx = [Helper createDimImage:inputImage];
        //bgzView.image = xx;
        
    }
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    self.visualEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
    self.visualEffectView.frame = self.cantainerLightView.bounds;
    self.visualEffectView.alpha = 0.5;
    self.visualEffectView.layer.cornerRadius = 5.0;
    self.visualEffectView.layer.masksToBounds = true;


}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
- (IBAction)pressedButton:(id)sender {
    
    
    //    self.onOffButton.selected = !self.onOffButton.selected;
    if (self.isScene) {
        self.onOffButton.selected = !self.onOffButton.selected;
        if (self.delegate && [self.delegate respondsToSelector:@selector(didPressedButton:value:)]) {
            if (self.onOffButton.selected) {
                [self.delegate didPressedButton:self.device.id value:ButtonTypeOpen];
            }else{
                [self.delegate didPressedButton:self.device.id value:ButtonTypeClose];
                
            }
        }
    }else{
        if ([[User sharedInstance] canControlDevice:self.device.requestId]) {

            if (self.delegate && [self.delegate respondsToSelector:@selector(didPressedButton:value:)]) {
                if (self.onOffButton.selected) {
                    [self.delegate didPressedButton:self.device.id value:ButtonTypeOpen];
                }else{
                    [self.delegate didPressedButton:self.device.id value:ButtonTypeClose];
                    
                }
            }
        }
    }
}
- (IBAction)pressedControl:(id)sender {
    NSLog(@"pressedControl");
    if ([[User sharedInstance] canControlDevice:self.device.requestId] ) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didPressedControl:)]) {
            [self.delegate didPressedControl:self.device.id];
        }
    }
   
}

-(void)setContentView:(SceneDetail *)detail{
    self.isScene = true;
    self.device = detail.device;
    self.onOffButton.tag = detail.id;
    
    self.onOffButton.selected = !(detail.status == ButtonTypeClose);
    
    Boolean isSharedDevice = [[User sharedInstance] canControlDevice:self.device.requestId];
    self.onOffButton.userInteractionEnabled = isSharedDevice;
    self.thumbnail.userInteractionEnabled = isSharedDevice;
    
    self.lbDeviceName.text = detail.device.name;
    if (detail.isSelected) {
        self._backgroundView.backgroundColor = [UIColor redColor];
    }else{
        self._backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    }
    if (self.visualEffectView) {
        [self.visualEffectView removeFromSuperview];
    }
    if (self.device.isOnline == NO) {
        self.visualEffectView.frame = CGRectMake(0, 0, self.bounds.size.width - 20, self.bounds.size.height - 10);
        [self.cantainerLightView addSubview:self.visualEffectView];
    }

}
-(void)setContentView:(Device *)device type:(NSInteger)type{
    self.device = device;
    self.onOffButton.tag = device.id;
    self.onOffButton.selected = device.state;
    Boolean isSharedDevice = [[User sharedInstance] canControlDevice:self.device.requestId];
    self.onOffButton.userInteractionEnabled = isSharedDevice ;
    self.thumbnail.userInteractionEnabled = isSharedDevice ;
    if (device.name && device.name.length > 0) {
        self.lbDeviceName.text = device.name;
        
    }else{
        self.lbDeviceName.text = device.requestId;
        
    }
    if (self.visualEffectView) {
        [self.visualEffectView removeFromSuperview];
    }
    if (self.device.isOnline == NO) {
        self.visualEffectView.frame = CGRectMake(0, 0, self.bounds.size.width - 20, self.bounds.size.height - 10);
        [self.cantainerLightView addSubview:self.visualEffectView];
    }

}
-(void)setContentView:(Device *)device type:(NSInteger)type selected:(BOOL)selected{
    [self setContentView:device type:type];
    if (selected) {
        self._backgroundView.backgroundColor = [UIColor redColor];
    }else{
        self._backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    }
    if (self.visualEffectView) {
        [self.visualEffectView removeFromSuperview];
    }
    if (self.device.isOnline == NO) {
        self.visualEffectView.frame = CGRectMake(0, 0, self.bounds.size.width - 20, self.bounds.size.height - 10);
        [self.cantainerLightView addSubview:self.visualEffectView];
    }

}
@end

