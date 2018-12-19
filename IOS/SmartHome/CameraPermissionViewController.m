//
//  CameraPermissionViewController.m
//  SmartHome
//
//  Created by Macintosh HD on 9/14/18.
//  Copyright © 2018 Apple. All rights reserved.
//

#import "CameraPermissionViewController.h"
#import "Helper.h"
#import <AVFoundation/AVFoundation.h>
@interface CameraPermissionViewController ()
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;

@end

@implementation CameraPermissionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.acceptButton.layer.borderColor = [Helper colorFromHexString:@"#d3a644"].CGColor;
    self.acceptButton.layer.borderWidth = 1.0;
    self.acceptButton.layer.masksToBounds= true;
    self.acceptButton.layer.cornerRadius = 4;

    //
    self.containerView.layer.cornerRadius = 10;
    self.containerView.layer.borderColor = [UIColor clearColor].CGColor;
    self.containerView.layer.borderWidth = 1.0;
    self.containerView.layer.masksToBounds= true;
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
- (IBAction)tappedAcceptButton:(id)sender {
    if (self.isDenie) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];

    }else{
        __weak CameraPermissionViewController *wself = self;
        [self dismissViewControllerAnimated:true completion:^{
            if (wself.completion) {
                wself.completion(true);
            }

        }];
    }
}



@end
