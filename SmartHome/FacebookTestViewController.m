//
//  FacebookTestViewController.m
//  SmartHome
//
//  Created by Macintosh HD on 9/12/18.
//  Copyright © 2018 Apple. All rights reserved.
//

#import "FacebookTestViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface FacebookTestViewController ()

@end

@implementation FacebookTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if ([FBSDKAccessToken currentAccessToken]) {
        FBSDKLoginManager *manager = [[FBSDKLoginManager alloc] init];
        //    manager.loginBehavior = FBSDKLoginBehaviorNative;
        //
        //
        [manager logOut];
        [FBSDKAccessToken setCurrentAccessToken:nil];
        
    }

    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    loginButton.readPermissions = @[@"public_profile", @"email"];
    loginButton.center =  self.view.center;
    [self.view addSubview:loginButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
