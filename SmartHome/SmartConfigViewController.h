//
//  SmartConfigViewController.h
//  SmartHome
//
//  Created by Apple on 3/27/18.
//  Copyright © 2018 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Helper.h"
#import "BaseViewController.h"
#import "AccountViewController.h"
#import "MemberListViewController.h"

@interface SmartConfigViewController : UIViewController<UITextFieldDelegate>
@property (strong, nonatomic)  void(^handleAddControl)(NSString *);
@property (weak, nonatomic) IBOutlet UILabel *ssidLabel;
@property (strong, nonatomic) NSString *bssid;
@property (weak, nonatomic) IBOutlet UIView *memberView;
@property (strong, nonatomic) UIButton *leftButton;
@property (strong, nonatomic) NSString *qrCodeString;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmBottomConstrain;

@end
