//
//  LoginViewController.m
//  SmartHome
//
//  Created by Apple on 1/13/18.
//  Copyright © 2018 Apple. All rights reserved.
//

#import "LoginViewController.h"
#import "WellComeViewController.h"
@import SafariServices;

@interface LoginViewController ()<GIDSignInUIDelegate,GIDSignInDelegate,QRCodeReaderDelegate,RequestPopupDelegate,SFSafariViewControllerDelegate>
@property (assign, nonatomic) Boolean isNew;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    GIDSignIn *signIn=[GIDSignIn sharedInstance];
    [signIn setDelegate:self];
    [signIn setUiDelegate:self];
    signIn.shouldFetchBasicProfile = YES;

    if ([FBSDKAccessToken currentAccessToken]) {
        FBSDKLoginManager *manager = [[FBSDKLoginManager alloc] init];
        //    manager.loginBehavior = FBSDKLoginBehaviorNative;
        //
        //
        [manager logOut];
        [FBSDKAccessToken setCurrentAccessToken:nil];
        
    }
  
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@"login viewdidApear");
    if([[FirebaseHelper sharedInstance] isLogin]){
        [self openWellComeScreen];
    }
    [[GIDSignIn sharedInstance] disconnect];
    [[GIDSignIn sharedInstance] signOut];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)updateUI{
    
}
-(void)getFacebookProfileInfos:(FIRAuthCredential *)credential {
     __weak LoginViewController *wself = self;

    [self hideLoadingView];
    [self showLoadingView];
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
                                       parameters:@{@"fields": @"first_name, last_name, picture, email"}]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id userinfo, NSError *error) {
         if (!error) {
             
             
             if ([userinfo objectForKey:@"email"]) {
                 [User sharedInstance].email = [userinfo objectForKey:@"email"];
                 [User sharedInstance].username = [[userinfo objectForKey:@"email"] componentsSeparatedByString:@"@"][0];
                 NSLog(@"facebook email : %@",[User sharedInstance].email);
                 
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
             [[FirebaseHelper sharedInstance] loginWithCredential:credential loginType:LoginTypeFacebook completion:^(FIRUser *user, Boolean isNew) {
                 [wself hideLoadingView];
                 if (user) {
                     wself.isNew = isNew;
                     if (isNew) {
                         [wself updateUI];
                         [wself openWellComeScreen];
                     }else{
                         [[MQTTService sharedInstance] conect];
                         [wself dismissViewControllerAnimated:true completion:nil];

                     }
                 }else{
                     [self showAlert:@"Thông báo lỗi" message:@"Email này đã tồn tại"];
                 }
               
             }] ;
         }
         else{
             [wself hideLoadingView];
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
    __weak LoginViewController *wself = self;
    if (error == nil) {
        [self showLoadingView];
        [self.googleButton setTitle:@"Đăng xuất" forState:UIControlStateNormal];
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
//            [self updateUI];
            [wself hideLoadingView];
            if (user) {
                wself.isNew = isNew;
                if (isNew) {
                    [wself openWellComeScreen];
                    
                }else{
                    [[MQTTService sharedInstance] conect];
                    [wself dismissViewControllerAnimated:true completion:nil];
                }

            }else{
                [self showAlert:@"Thông báo lỗi" message:@"Email này đã tồn tại"];

            }
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
    NSLog(@"didDisconnectWithUser");
}
- (void)signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error {
    //    [ stopAnimating];
}

// Present a view that prompts the user to sign in with Google
- (void)signIn:(GIDSignIn *)signIn
presentViewController:(UIViewController *)viewController {
    NSLog(@"presentViewController");

    [self presentViewController:viewController animated:YES completion:nil];
}

// Dismiss the "Sign in with Google" view
- (void)signIn:(GIDSignIn *)signIn
dismissViewController:(UIViewController *)viewController {
    NSLog(@"dismissViewController");

    [self dismissViewControllerAnimated:YES completion:nil];
}




- (IBAction)pressedSigninGoogle:(id)sender {
    SFSafariViewController *logoutViewController = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:@"https://www.google.com/accounts/Logout"]];
    logoutViewController.delegate = self;
    [self presentViewController:logoutViewController animated:YES completion:nil];

//    [[GIDSignIn sharedInstance] signIn];

}
- (IBAction)pressedSigninFacebook:(id)sender {
    FBSDKLoginManager *manager = [[FBSDKLoginManager alloc] init];

    [manager logInWithReadPermissions:@[@"public_profile",@"email"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
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
-(void)safariViewController:(SFSafariViewController *)controller didCompleteInitialLoad:(BOOL)didLoadSuccessfully {
    [controller dismissViewControllerAnimated:NO completion:^{
        [[GIDSignIn sharedInstance] signIn];
    }];
}
-(void)openWellComeScreen{
    WellComeViewController *popupContent = [WellComeViewController new];
    popupContent.isNew = self.isNew;
    __weak WellComeViewController *weakPop = popupContent;
    __weak LoginViewController *weakSelf = self;
    popupContent.completion = ^(BOOL finished) {
        [weakPop dismissViewControllerAnimated:true completion:nil];
        [weakSelf dismissViewControllerAnimated:true completion:nil];
//        [weakSelf showAlert:@"" message:@"Đăng ký thành viên thành công"];
        [[MQTTService sharedInstance] conect];

    };
    STPopupController *popupController = [[STPopupController alloc] initWithRootViewController:popupContent];
    popupController.containerView.layer.cornerRadius = 4;
    popupController.transitionStyle = STPopupTransitionStyleFade;
    popupController.hidesCloseButton = YES;
    [popupController presentInViewController:self];
}
@end
