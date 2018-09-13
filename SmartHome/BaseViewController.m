//
//  BaseViewController.m
//  SmartHome
//
//  Created by Apple on 3/12/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    // Do any additional setup after loading the view.
    [self.navigationController.navigationBar setBackgroundImage:[[Utils imageFromColor:[UIColor blackColor]]
                                                                 resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0) resizingMode:UIImageResizingModeStretch] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setTranslucent:YES];
    UINavigationBar *bar = [self.navigationController navigationBar];
    [bar setTintColor:[UIColor blackColor]];
    [[UINavigationBar appearance] setTintColor:[[UIColor blackColor] colorWithAlphaComponent:0.7]];
    [self initLoadingView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)setupNavigator{

}

-(void)pressedLeft:(UIButton *)button{

}
-(void)pressedRight:(UIButton *)button{

}
-(void)initLoadingView{
    if (!self.activityIndicatorView) {
        self.activityIndicatorView = [[SCSkypeActivityIndicatorView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - LOADING_SIZE)/2, (self.view.frame.size.height - LOADING_SIZE)/2 - 32, LOADING_SIZE, LOADING_SIZE)];
        self.activityIndicatorView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        self.activityIndicatorView.hidden = YES;
        self.activityIndicatorView.layer.cornerRadius = LOADING_SIZE * 0.5;
        self.activityIndicatorView.layer.masksToBounds = true;
        [self.view addSubview:self.activityIndicatorView];
    }
    

}
-(void)showLoadingView{
    self.isProcessing = YES;

    if (self.activityIndicatorView) {
        self.activityIndicatorView.hidden = NO;
        
        [self.activityIndicatorView startAnimating];

    }
}

-(void)hideLoadingView{
    self.isProcessing = NO;//

    if (self.activityIndicatorView) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, LOADING_TIME * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //code to be executed on the main queue after delay
            self.isProcessing = false;

            [self.activityIndicatorView stopAnimating];
            self.activityIndicatorView.hidden = YES;
        });

        
    }
}
-(void)showConfirmDialog:(NSString *)title message:(NSString *)message complete:(void (^)(NSInteger))block{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Đồng Ý" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (block) {
            block(1);
        }
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Bỏ qua" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (block) {
            block(0);
        }
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}
-(void)showMessageView:(NSString *)title message:(NSString *)message autoHide:(BOOL)hide complete:(void (^)(NSInteger index))block{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    if (hide) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [alert dismissViewControllerAnimated:YES completion:nil];
        });

    }else{
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Đồng Ý" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if (block) {
                block(1);
            }
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        [alert addAction:okAction];
    }
    [self presentViewController:alert animated:YES completion:nil];
}
-(void)showAlert:(NSString *)title message:(NSString *)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"QRCODE" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Đồng Ý" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //        <#code#>
    }];
    [alert addAction:okAction];
    [self presentViewController:alert animated:true completion:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
