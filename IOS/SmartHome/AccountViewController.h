//
//  AccountViewController.h
//  SmartHome
//
//  Created by Apple on 1/7/18.
//  Copyright © 2018 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "ShareViewController.h"
#import "FirebaseHelper.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "FirebaseTestViewController.h"
@interface AccountViewController : BaseViewController
//@property (weak, nonatomic) IBOutlet UIButton *googleButton;
////@property (weak, nonatomic) IBOutlet FBSDKLoginButton *facebookButton;
//@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
//
//@property (weak, nonatomic) IBOutlet UIButton *demoButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *memberButton;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;


@property (weak, nonatomic) IBOutlet UIView *profileView;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *displayNameLabel;

@end
