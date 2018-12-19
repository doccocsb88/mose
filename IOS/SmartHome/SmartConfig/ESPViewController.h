//
//  ESPViewController.h
//  EspTouchDemo
//
//  Created by 白 桦 on 3/23/15.
//  Copyright (c) 2015 白 桦. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Helper.h"
#import "BaseViewController.h"
#import "AccountViewController.h"
#import "MemberListViewController.h"
@interface ESPViewController : BaseViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *ssidLabel;
@property (strong, nonatomic) NSString *bssid;
@property (weak, nonatomic) IBOutlet UIView *memberView;

@end
