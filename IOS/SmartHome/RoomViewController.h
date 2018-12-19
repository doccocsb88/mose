//
//  RoomViewController.h
//  SmartHome
//
//  Created by Apple on 3/20/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "EditDeviceMenuViewController.h"
#import "Device.h"
#import "CoredataHelper.h"
#import "LightStateViewCell.h"
#import "LightValueViewCell.h"
#import "TouchSwitchViewCell.h"
#import "RemViewCell.h"
#import "Utils.h"
#import "MQTTService.h"
#import "Room+CoreDataClass.h"
#import "Room+CoreDataProperties.h"
#import "ListTimerViewController.h"
#import "FirebaseHelper.h"
#import "User.h"
#import "SmartConfigViewController.h"
@interface RoomViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIScrollView *filterView;
@property (strong, nonatomic) UIButton *btnSetup;
@property (strong, nonatomic) Room *room;
//@property (assign, nonatomic) BOOL isProcessing;

@end
