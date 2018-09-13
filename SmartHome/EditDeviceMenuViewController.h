//
//  EditDeviceMenuViewController.h
//  SmartHome
//
//  Created by Apple on 3/26/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Device.h"
#import "User.h"
@protocol EditDeviceDelegate <NSObject>
-(void)selectMenuAtIndex:(NSInteger)index;
@end
@interface EditDeviceMenuViewController : UIViewController
@property (weak, nonatomic) id<EditDeviceDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *marginTop;
@property (strong, nonatomic) Device *device;
@property (assign, nonatomic) NSInteger chanel;

@end
