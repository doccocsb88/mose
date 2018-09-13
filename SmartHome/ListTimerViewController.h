//
//  ListTimerViewController.h
//  SmartHome
//
//  Created by Ngoc Truong on 7/27/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "AddTimerViewController.h"
#import "CoredataHelper.h"
#import "Device.h"
#import "MQTTService.h"
@interface ListTimerViewController : BaseViewController <MQTTServiceDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) Device *device;
@property (assign, nonatomic) NSInteger chanel;
@end
