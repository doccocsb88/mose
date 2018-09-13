//
//  LightValueViewCell.h
//  SmartHome
//
//  Created by Apple on 3/31/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Device.h"
#import "BaseViewCell.h"
@interface LightValueViewCell : BaseViewCell

@property (weak, nonatomic) IBOutlet UIView *_backgroundView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *thumbnail;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
-(void)setContentView:(Device *)device type:(NSInteger)type;
-(void)setContentView:(Device *)device type:(NSInteger)type selected:(BOOL)selected;
@end
