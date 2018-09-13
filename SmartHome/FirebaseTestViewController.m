//
//  FirebaseTestViewController.m
//  SmartHome
//
//  Created by Apple on 1/10/18.
//  Copyright © 2018 Apple. All rights reserved.
//

#import "FirebaseTestViewController.h"
#import "FirebaseHelper.h"
@interface FirebaseTestViewController ()

@end

@implementation FirebaseTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)pressedAddDevice:(id)sender {
//    @"B000263D" , @"B0000C03" , @"B00026A1",
    [[FirebaseHelper sharedInstance] addDeviceToSystem:@"B000263D"];
}

@end
