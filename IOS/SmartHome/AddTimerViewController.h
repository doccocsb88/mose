//
//  AddTimerViewController.h
//  SmartHome
//
//  Created by Ngoc Truong on 7/27/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "CoredataHelper.h"
#import "SHTimer+CoreDataClass.h"
#import "Device.h"
#import "MQTTService.h"
#import "FirebaseHelper.h"
@interface AddTimerViewController : BaseViewController
@property (strong, nonatomic) Device *device;
@property (strong, nonatomic) SHTimer *timer;
@property (assign, nonatomic) NSInteger order;
@property (assign, nonatomic) NSInteger isSlide;
@property (assign, nonatomic) NSInteger chanel;

@property (weak, nonatomic) IBOutlet UIView *lightStatusView;
@property (weak, nonatomic) IBOutlet UIView *curtainStatusView;
@property (weak, nonatomic) IBOutlet UIButton *curtainCloseButton;
@property (weak, nonatomic) IBOutlet UIButton *curtainOpenButton;
@property (weak, nonatomic) IBOutlet UISlider *curtainValueSlider;

@end
