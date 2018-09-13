//
//  AccountViewController.m
//  SmartHome
//
//  Created by Apple on 1/7/18.
//  Copyright © 2018 Apple. All rights reserved.
//

#import "AccountViewController.h"
#import <QRCodeReader.h>
#import <QRCodeReaderViewController.h>
#import <QRCodeReaderDelegate.h>
#import <STPopup/STPopup.h>
#import "RequestPopupViewController.h"
@import GoogleSignIn;

@interface AccountViewController ()<GIDSignInUIDelegate,GIDSignInDelegate,FBSDKLoginButtonDelegate,QRCodeReaderDelegate,RequestPopupDelegate>
{
    QRCodeReader *reader;
    
    // Instantiate the view controller
    QRCodeReaderViewController *vc;
}
@property (strong, nonatomic) STPopupController *popupController;
@property (strong, nonatomic) RequestPopupViewController *popupContent;
@end

@implementation AccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    //
    [GIDSignIn sharedInstance].uiDelegate = self;
    [GIDSignIn sharedInstance].delegate = self;
//    [[FirebaseHelper sharedInstance] logout];
//    GoogleSignInOptions gso = new GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
//    .requestEmail()
//    .build();
//
//    final GoogleSignInClient mGoogleSignInClient = GoogleSignIn.getClient(this, gso);
    [self initQRCode];
    [self setupUI];
    [self logoutFacebook];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updateUI];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)initQRCode{
    reader = [QRCodeReader readerWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    // Instantiate the view controller
    vc = [QRCodeReaderViewController readerWithCancelButtonTitle:@"Cancel" codeReader:reader startScanningAtLoad:YES showSwitchCameraButton:YES showTorchButton:YES];
}

    -(void)setupUI{
        self.leftButton = [[UIButton alloc] init];
        self.leftButton.frame = CGRectMake(0, 0, 40, 40);
        self.leftButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.leftButton setImage:[UIImage imageNamed:@"ic_back"] forState:UIControlStateNormal];
        [self.leftButton addTarget:self action:@selector(pressedLeft:) forControlEvents:UIControlEventTouchUpInside];
        self.leftButton.backgroundColor = [UIColor clearColor];
        self.leftButton.layer.cornerRadius = 3;
        self.leftButton.layer.masksToBounds = YES;
        self.leftButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:self.leftButton];
        self.navigationItem.leftBarButtonItem = leftItem;
        self.navigationItem.title = @"Chia sẻ dữ liệu";
        [self.navigationController.navigationBar setTitleTextAttributes:
         @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    }

-(void)updateUI{
    self.shareButton.hidden = ![[FirebaseHelper sharedInstance] isAdmin];
//    self.memberButton.hidden = ![[FirebaseHelper sharedInstance] isAdmin];
//    self.googleButton.hidden = [[FirebaseHelper sharedInstance] isLogin];
//    self.facebookButton.hidden = [[FirebaseHelper sharedInstance] isLogin];
//    self.demoButton.hidden = [[FirebaseHelper sharedInstance] isLogin];
    self.logoutButton.hidden = ![[FirebaseHelper sharedInstance] isLogin];

    if ([FBSDKAccessToken currentAccessToken]) {
        // User is logged in, do work such as go to next view controller.
        NSLog(@"FBSDKAccessToken");
    }
    if ([[FirebaseHelper sharedInstance] isLogin]) {
        self.profileView.hidden = NO;
        //
        self.displayNameLabel.text = [User sharedInstance].displayName;
        self.emailLabel.text = [User sharedInstance].email;
    }else{
        self.profileView.hidden = YES;
    }
}
-(void)getFacebookProfileInfos:(FIRAuthCredential *)credential {
    
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
                                       parameters:@{@"fields": @"first_name, last_name, picture, email"}]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id userinfo, NSError *error) {
         if (!error) {
             
             
             if ([userinfo objectForKey:@"email"]) {
                 [User sharedInstance].email = [userinfo objectForKey:@"email"];
                 [User sharedInstance].username = [[userinfo objectForKey:@"email"] componentsSeparatedByString:@"@"][0];
                 
                 
             }
             NSString *lastName = @"";
             if ([userinfo objectForKey:@"last_name"]) {
                 lastName = [userinfo objectForKey:@"last_name"];
             }
             if ([userinfo objectForKey:@"first_name"]) {
                 
                 [User sharedInstance].displayName = [NSString stringWithFormat:@"%@ %@",[userinfo objectForKey:@"first_name"],lastName];
                 
             }
             if ([userinfo objectForKey:@"id"])
             {
                 
                 NSLog(@"User id : %@",[userinfo objectForKey:@"id"]);
                 
             }
             [User sharedInstance].active = true;
             [User sharedInstance].accountType = AccountTypeAdmin;
             [[FirebaseHelper sharedInstance] loginWithCredential:credential loginType:LoginTypeFacebook completion:^(FIRUser *user,Boolean isNew) {
                 [self updateUI];
             }] ;
         }
         else{
             
             NSLog(@"%@", [error localizedDescription]);
         }
     }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    // Perform any operations on signed in user here.
    if (error == nil) {
//        [self.googleButton setTitle:@"Log out" forState:UIControlStateNormal];
        GIDAuthentication *authentication = user.authentication;
        FIRAuthCredential *credential =
        [FIRGoogleAuthProvider credentialWithIDToken:authentication.idToken
                                         accessToken:authentication.accessToken];
        NSLog(@"didSignInForUser : %@",authentication.accessToken);
        NSString *userId = user.userID;                  // For client-side use only!
        NSString *fullName = user.profile.name;
        NSString *email = user.profile.email;
        [User sharedInstance].active = true;
        [User sharedInstance].email = email;
        [User sharedInstance].displayName = fullName;
        [User sharedInstance].username = [email componentsSeparatedByString:@"@"][0];
        [User sharedInstance].accountType = AccountTypeAdmin;
        
        [[FirebaseHelper sharedInstance] loginWithCredential:credential loginType:LoginTypeGoogle completion:^(FIRUser *user, Boolean isNew) {
            [self updateUI];
        }];
        // ...
    } else {
        // ...
    }
    // ...
}
- (void)signIn:(GIDSignIn *)signIn
didDisconnectWithUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    // Perform any operations when the user disconnects from app here.
    // ...
}
- (void)signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error {
//    [ stopAnimating];
}

// Present a view that prompts the user to sign in with Google
- (void)signIn:(GIDSignIn *)signIn
presentViewController:(UIViewController *)viewController {
    [self presentViewController:viewController animated:YES completion:nil];
}

// Dismiss the "Sign in with Google" view
- (void)signIn:(GIDSignIn *)signIn
dismissViewController:(UIViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)loginButton:(FBSDKLoginButton *)loginButton
didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result
              error:(NSError *)error{
    NSLog(@"faebook loginButton");
    if (result) {
        FIRAuthCredential *credential = [FIRFacebookAuthProvider
                                         credentialWithAccessToken:[FBSDKAccessToken currentAccessToken].tokenString];
        [self getFacebookProfileInfos:credential];


    }
}

/**
 Sent to the delegate when the button was used to logout.
 - Parameter loginButton: The button that was clicked.
 */
- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{
    NSLog(@"faebook loginButton logout");

}

/**
 Sent to the delegate when the button is about to login.
 - Parameter loginButton: the sender
 - Returns: YES if the login should be allowed to proceed, NO otherwise
 */
- (BOOL) loginButtonWillLogin:(FBSDKLoginButton *)loginButton{
    return YES;
}
#pragma mark
#pragma mark - QRCode
-(void)showQRCodeReaderScreen{
    
    __weak AccountViewController *weakSelf = self;
    
    vc.modalPresentationStyle = UIModalPresentationFormSheet;
    
    // Define the delegate receiver
    vc.delegate = self;
    // Or use blocks
    [reader setCompletionWithBlock:^(NSString *resultAsString) {
        NSLog(@"%@", resultAsString);
        [weakSelf dismissViewControllerAnimated:true completion:nil];
        if ([resultAsString containsString:@":"]) {
            NSArray *qrArr =[resultAsString componentsSeparatedByString:@":"];
            NSString *typeString = qrArr[0];
            NSString *adminUid = qrArr[1];
            if ([typeString isEqualToString:@"share"]) {
                [[FirebaseHelper sharedInstance] isMemberOf:adminUid completion:^(BOOL exist) {
                    if (exist) {
                        [weakSelf showAlert:@"Thông báo" message:@"Yêu cầu xin làm thành viên của bạn đã được gửi đến tài khoản admin"];
                    }else{
                        [[FirebaseHelper sharedInstance]requestMember:adminUid completion:^(BOOL exist) {
                            if (exist) {
                                //                        [weakSelf showAlert:@"" message:@"Đăng ký thành viên thành công"];
                                [weakSelf showMessageView:@"Đã đăng ký thành công" message:@"Vui lòng chọn thiết bị cần chia sẽ trong danh sách thành viên trên tài khoản chính." autoHide:false complete:^(NSInteger index) {
                                    
                                }];
                                
                            }
                        }];

                    }
                }];
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
- (IBAction)pressedFacebookLogin:(id)sender {
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login
     logInWithReadPermissions: @[@"public_profile", @"email"]
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error)
         {
             NSLog(@"Error");
         }
         else if (result.isCancelled)
         {
             NSLog(@"Cancell");
         }
         else
         {
             NSLog(@"Login Sucessfull");
             // Share link text on face book
             FIRAuthCredential *credential = [FIRFacebookAuthProvider
                                              credentialWithAccessToken:[FBSDKAccessToken currentAccessToken].tokenString];
             [self getFacebookProfileInfos:credential];

          
         }
     }];
}

- (IBAction)pressedGoogleSignIn:(id)sender {
    [[GIDSignIn sharedInstance] signIn];
}
- (IBAction)pressedSigninDemo:(id)sender {
    [self showLoadingView];
    [[FirebaseHelper sharedInstance] loginDemo:^(FIRUser *user,Boolean isNew) {
        [self hideLoadingView];
        if(user){
            NSLog(@"signInDemo : %@",[user uid]);
            [[FirebaseHelper sharedInstance] getProfileInfo:^(FIRUser *user, Boolean isNew) {
                
            }];
        }else{
            NSLog(@"signInDemo : ");

        }
    }];
}
- (IBAction)pressedSignout:(id)sender {
    if ([FirebaseHelper sharedInstance].loginType == LoginTypeGoogle) {
        [[GIDSignIn sharedInstance] disconnect];

        [[GIDSignIn sharedInstance] signOut];

    }else if ([FirebaseHelper sharedInstance].loginType == LoginTypeFacebook){
    }
    [self logoutFacebook];
    [[FirebaseHelper sharedInstance] logout];
    [[MQTTService sharedInstance] disconect];
    [[User sharedInstance] clearData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationbackToHome" object:nil userInfo:nil];
        [self updateUI];
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    });
}
- (IBAction)pressedShare:(id)sender {

    ShareViewController *vc = [[ShareViewController alloc] initWithNibName:@"ShareViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)pressedFirebase:(id)sender {
    FirebaseTestViewController *vc = [[FirebaseTestViewController alloc] initWithNibName:@"FirebaseTestViewController" bundle:nil];
    
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)pressedRequestMember:(id)sender {
    self.popupContent = [RequestPopupViewController new];
    self.popupContent.delegate = self;
          self.popupController = [[STPopupController alloc] initWithRootViewController:self.popupContent];
    self.popupController.containerView.layer.cornerRadius = 4;
    self.popupController.transitionStyle = STPopupTransitionStyleFade;
    [self.popupController presentInViewController:self];

}
-(void)pressedLeft:(UIButton *)button{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)didSelectNext{
    [self.popupController popViewControllerAnimated:YES]; // Popup will be dismissed if there is only one view controller in the popup view controller stack
    [self.popupController dismiss];

}

-(void)logoutFacebook{
    FBSDKLoginManager *manager = [[FBSDKLoginManager alloc] init];
    manager.loginBehavior = FBSDKLoginBehaviorNative;
    
    
    [manager logOut];
    [FBSDKAccessToken setCurrentAccessToken:nil];
    [FBSDKProfile setCurrentProfile:nil];
    

}
@end

