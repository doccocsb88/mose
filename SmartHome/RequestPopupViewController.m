//
//  RequestPopupViewController.m
//  SmartHome
//
//  Created by Apple on 1/13/18.
//  Copyright © 2018 Apple. All rights reserved.
//

#import "RequestPopupViewController.h"
#import <QRCodeReader.h>
#import <QRCodeReaderViewController.h>
#import <QRCodeReaderDelegate.h>
#import <STPopup/STPopup.h>
#import "FirebaseHelper.h"
#import "User.h"
@interface RequestPopupViewController ()<QRCodeReaderDelegate>
{
    QRCodeReader *reader;
    
    // Instantiate the view controller
    QRCodeReaderViewController *vc;
}
@property (strong, nonatomic) UILabel *introLabel;
@property (strong, nonatomic) UIButton *okButton;
@property (strong, nonatomic) UIButton *cancelButton;
@property (assign, nonatomic) BOOL proccessing;


@end

@implementation RequestPopupViewController
- (instancetype)init
{
    if (self = [super init]) {
        self.title = [NSString stringWithFormat:@"Xin Chào %@",[User sharedInstance].displayName];
        self.contentSizeInPopup = CGSizeMake(300, 250);
        self.landscapeContentSizeInPopup = CGSizeMake(400, 200);
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(nextBtnDidTap)];
    self.introLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, self.contentSizeInPopup.width - 20, 150)];
    [self.introLabel setText:@"- Chọn Đồng ý để đăng ký quyền kết nối vào hệ thống đã được cài đặt bởi thành viên khác.\n- Tất cả dữ liệu hiện tại của bạn sẽ bị xoá."];
    [self.introLabel setTextColor:[UIColor blackColor]];
    [self.introLabel setNumberOfLines:0];
    [self.view addSubview:self.introLabel];
    NSInteger buttonWidth = 60;
    self.okButton = [[UIButton alloc] initWithFrame:CGRectMake(20, self.contentSizeInPopup.height - 40, buttonWidth, 30)];
    [self.okButton setTitle:@"Đồng ý" forState:UIControlStateNormal];
    [self.okButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.okButton addTarget:self action:@selector(nextBtnDidTap) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.okButton];
    //
    self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(self.contentSizeInPopup.width - 20 - buttonWidth, self.contentSizeInPopup.height - 40, buttonWidth, 30)];
    [self.cancelButton setTitle:@"Bỏ qua" forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(cancelDidTap) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.cancelButton];

    [self initQRCode];
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
-(void)initQRCode{
    reader = [QRCodeReader readerWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    // Instantiate the view controller
    vc = [QRCodeReaderViewController readerWithCancelButtonTitle:@"Cancel" codeReader:reader startScanningAtLoad:YES showSwitchCameraButton:YES showTorchButton:YES];
}

-(void)showQRCodeReaderScreen{
    
    __weak RequestPopupViewController *weakSelf = self;
    
    vc.modalPresentationStyle = UIModalPresentationFormSheet;
    
    // Define the delegate receiver
    vc.delegate = self;
    // Or use blocks
    self.proccessing = false;
    [reader setCompletionWithBlock:^(NSString *resultAsString) {
        NSLog(@"%@", resultAsString);
        [weakSelf dismissViewControllerAnimated:true completion:nil];
        if ([resultAsString containsString:@":"]  && self.proccessing == false) {
            weakSelf.proccessing = true;
            NSArray *qrArr =[resultAsString componentsSeparatedByString:@":"];
            NSString *cpmmand = qrArr[0];
            NSString *adminUid = qrArr[1];
            NSLog(@"request 1");
            if ([cpmmand isEqualToString:@"share"]) {
                NSLog(@"request 2");

                [[FirebaseHelper sharedInstance] isMemberOf:adminUid completion:^(BOOL exist) {
                    NSLog(@"request 3 %d",exist);

                    if (exist) {
                        [weakSelf showMessageView:@"Thông báo" message:@"Yêu cầu xin làm thành viên của bạn đã được gửi đến tài khoản admin" autoHide:false complete:^(NSInteger index) {
                            weakSelf.proccessing = false;
                            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(didSelectNext)]) {
                                [weakSelf.delegate didSelectNext];
                            }

                        }];
                    }else{
                        [[FirebaseHelper sharedInstance]requestMember:adminUid completion:^(BOOL exist) {
                            if (exist) {
                                //                        [weakSelf showAlert:@"" message:@"Đăng ký thành viên thành công"];
                                [weakSelf showMessageView:@"Đã đăng ký thành công" message:@"Vui lòng chọn thiết bị cần chia sẽ trong danh sách thành viên trên tài khoản chính." autoHide:false complete:^(NSInteger index) {
                                    weakSelf.proccessing = false;
                                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(didSelectNext)]) {
                                        [weakSelf.delegate didSelectNext];
                                    }

                                }];
                                
                            }else{
                                [weakSelf showAlert:@"" message:@"dkm no"];
                            }
                        }];
                        
                    }
                }];

//                [[FirebaseHelper sharedInstance]requestMember:requestUid completion:^(BOOL exist) {
//                    if (exist) {
//                        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(didSelectNext)]) {
//                            [weakSelf.delegate didSelectNext];
//                        }
//
//                    }
//                }];
            }
        }
        
    }];
    [self presentViewController:vc animated:YES completion:NULL];
    
}
- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result{
    if (vc) {
        [vc dismissViewControllerAnimated:YES completion:nil];
    }
}
- (void)readerDidCancel:(QRCodeReaderViewController *)reader{
    if (vc) {
        [vc dismissViewControllerAnimated:YES completion:nil];
    }
}
- (void)nextBtnDidTap
{
    [[FirebaseHelper sharedInstance] clearData:^(BOOL exist) {

    }];
    [[CoredataHelper sharedInstance] clearData];
    [[User sharedInstance] clearData];
    [self showQRCodeReaderScreen];

}

-(void)cancelDidTap{
    [self dismissViewControllerAnimated:true completion:^{
        
    }];
}
@end
