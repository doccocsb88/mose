//
//  RemViewCell.h
//  SmartHome
//
//  Created by Apple on 3/30/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewCell.h"
#import "Device.h"
#import "SceneDetail.h"
@interface RemViewCell : BaseViewCell
@property(strong, nonatomic) UIVisualEffectView *visualEffectView;

@property (weak, nonatomic) IBOutlet UIView *containerCurtainView;

@property (weak, nonatomic) IBOutlet UIView *_backgroundView;

@property (weak, nonatomic) IBOutlet UIImageView *thumbnail;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UIButton *aButton;//close
@property (weak, nonatomic) IBOutlet UIButton *bButton;//top
@property (weak, nonatomic) IBOutlet UIButton *cButton;//open
//@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
-(void)setContentView:(SceneDetail *)device;

-(void)setContentView:(Device *)device type:(NSInteger)type;
-(void)setContentView:(Device *)device type:(NSInteger)type selected:(BOOL)selected;

@end
