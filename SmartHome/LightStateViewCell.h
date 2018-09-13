//
//  LightStateViewCell.h
//  SmartHome
//
//  Created by Apple on 3/31/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Device.h"
#import "SceneDetail.h"
#import "BaseViewCell.h"
#import "User.h"
@interface LightStateViewCell : BaseViewCell
@property(strong, nonatomic) UIVisualEffectView *visualEffectView;
@property (weak, nonatomic) IBOutlet UIView *cantainerLightView;

@property (weak, nonatomic) IBOutlet UIView *_backgroundView;
@property (weak, nonatomic) IBOutlet UIButton *onOffButton;
@property (weak, nonatomic) IBOutlet UIButton *thumbnail;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UILabel *lbDeviceName;
-(void)setContentView:(SceneDetail *)detail;
-(void)setContentView:(Device *)device type:(NSInteger)type;
-(void)setContentView:(Device *)device type:(NSInteger)type selected:(BOOL)selected;
@end
