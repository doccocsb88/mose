//
//  ListDeviceViewController.h
//  SmartHome
//
//  Created by Apple on 3/26/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditDeviceMenuViewController.h"
#import "LightStateViewCell.h"
#import "LightValueViewCell.h"
#import "RemViewCell.h"
#import "Device.h"
#import "SceneDetail.h"
#import "BaseViewController.h"
#import "MQTTService.h"
#import "FirebaseHelper.h"
#import "TouchSwitchViewCell.h"
@protocol ListDeviceDelegate <NSObject>
-(void)didSelectedDevce:(Device *)device;
-(void)didSelectedListDevces:(NSArray *)selectedDevices;

@end
@interface ListDeviceViewController : BaseViewController
@property (weak, nonatomic) id<ListDeviceDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *existDevice;

@property (assign,nonatomic) NSInteger type;
@property (assign,nonatomic) BOOL scene;
//@property (assign, nonatomic) BOOL isProcessing;
@property (assign, nonatomic) NSInteger retry;

@end
