//
//  ScenceViewController.h
//  SmartHome
//
//  Created by Apple on 3/30/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "ListDeviceViewController.h"
#import "SceneDetailViewController.h"
#import "FirebaseHelper.h"
@interface ScenceViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
