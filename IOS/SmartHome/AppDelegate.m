//
//  AppDelegate.m
//  SmartHome
//
//  Created by Apple on 3/12/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import "AppDelegate.h"
#import "Helper.h"
#import "CoredataHelper.h"
#import "ESPViewController.h"
#import "ESP_NetUtil.h"
//#import "BaseService.h"
#import <Reachability.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
@import GoogleSignIn;

//tug885495
@import Firebase;
@interface AppDelegate ()<UIApplicationDelegate, GIDSignInDelegate>
{
    Reachability* internetReachable;
    Reachability* hostReachable;
    NSTimer *timer;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [FIRApp configure];
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    pageControl.backgroundColor = [UIColor clearColor];
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    if ([pref boolForKey:@"init"] == false){
        [self initData];
    }
    if ([pref boolForKey:@"init_device"] == false){
        NSArray *topics = [[NSMutableArray alloc] init];//[NSArray arrayWithObjects:/*@"1/9/8/CURTAIN",@"2/9/8/CURTAIN", @"B000263D" , @"B0000C03" , @"B00026A1",*/, nil];
        for (int i = 0; i < topics.count; i ++) {
//            [[CoredataHelper sharedInstance] addNewDevice:@"xxx" name:[NSString stringWithFormat:@"device %d",i] deviceId:i + 1 state:i % 2 value:i * 10 topic:topics[i] type:DeviceTypeLightOnOff complete:^(Device *device) {
//                
//            }];
        }
        [pref setBool:true forKey:@"init_device"];
    }
//
    //[[UINavigationBar appearance] setBarTintColor:[[UIColor blackColor] colorWithAlphaComponent:0.9]];
//    [[UINavigationBar appearance] setBackgroundImage:[[UIImage imageNamed:@"nav-image-portrait"]
//                                                      resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0) resizingMode:UIImageResizingModeStretch] forBarMetrics:UIBarMetricsCompact];
//    [[BaseService sharedInstance] getToken];
    UIImage *img  = [Utils imageWithImage:[[UIImage imageNamed:@"nav-image-portrait"]                                                                 resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0) resizingMode:UIImageResizingModeStretch] convertToSize:CGSizeMake( [UIScreen mainScreen ].bounds.size.width,50)];
    [[UITabBar appearance] setBackgroundImage:img ];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName :[Helper colorFromHexString:@"#d3a644"]} forState:UIControlStateSelected];

    [self setStatusBarBackgroundColor:[Helper colorFromHexString:@"000000"]];

    // Here you can set the converted color form image, make sure the imageSize fit.
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    //


    [GIDSignIn sharedInstance].clientID = @"96636159345-9b3he2fe5pq1e3av9vu8sfmvti23edkp.apps.googleusercontent.com";
    

    [GIDSignIn sharedInstance].delegate = self;
    //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];

    internetReachable = [Reachability reachabilityForInternetConnection];
    [internetReachable startNotifier];
    
    // check if a pathway to a random host exists
    hostReachable = [Reachability reachabilityWithHostName:@"www.apple.com"];
    [hostReachable startNotifier];
//    [FBSDKLoginButton class];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    NSLog(@"abc applicationWillResignActive");
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//    timer =  [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(disconnectMQTT) userInfo:nil repeats:false];
//    [self disconnectMQTT];
    NSLog(@"abc applicationDidEnterBackground");

}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    NSLog(@"abc applicationWillEnterForeground");

}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if (timer != NULL) {
        [timer invalidate];
        timer = NULL;
    }
    [NSNotificationCenter.defaultCenter postNotificationName:@"mqttapplicationDidBecomeActive" object:nil userInfo:nil];
    if ([[FirebaseHelper sharedInstance] isLogin]) {
        [[MQTTService sharedInstance] conect];
    }
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    NSLog(@"abc applicationWillTerminate");

    [self saveContext];
}

- (void)setStatusBarBackgroundColor:(UIColor *)color {
    
//    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
//    
//    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
//        statusBar.backgroundColor = color;
//    }
    
}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    if ( [[GIDSignIn sharedInstance] handleURL:url
                             sourceApplication:sourceApplication
                                    annotation:annotation]){
        NSLog(@"application google 2");

        return [[GIDSignIn sharedInstance] handleURL:url
                                   sourceApplication:sourceApplication
                                          annotation:annotation];
    }else if ([[FBSDKApplicationDelegate sharedInstance] application:application
                                                             openURL:url
                                                   sourceApplication:sourceApplication
                                                          annotation:annotation
               ]){
        
        NSLog(@"application facebook 2");
        BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                      openURL:url
                                                            sourceApplication:sourceApplication
                                                                   annotation:annotation
                        ];
        // Add any custom logic here.
        return handled;
    }
    
    // Add any custom logic here.
    return NO;
}
- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary *)options {
    NSLog(@"appdelegate  : %@",url.absoluteString);
   

    if ([[GIDSignIn sharedInstance] handleURL:url
                            sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                   annotation:options[UIApplicationOpenURLOptionsAnnotationKey]]) {
        NSLog(@"appdelegate  : google");

        return [[GIDSignIn sharedInstance] handleURL:url
                                   sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                          annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
        // For Facebook SDK
    }else if ( [[FBSDKApplicationDelegate sharedInstance] application:app
                                                              openURL:url
                                                    sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                                           annotation:options[UIApplicationOpenURLOptionsAnnotationKey]]){
        NSLog(@"application facebook");

        BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:app
                                                                      openURL:url
                                                            sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                                                   annotation:options[UIApplicationOpenURLOptionsAnnotationKey]
                        ];
        // Add any custom logic here.
        return handled;
        //For Google plus SDK
    }
    
    return NO;
}
- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    // Perform any operations on signed in user here.
//    if (error == nil) {
//        GIDAuthentication *authentication = user.authentication;
//        FIRAuthCredential *credential =
//        [FIRGoogleAuthProvider credentialWithIDToken:authentication.idToken
//                                         accessToken:authentication.accessToken];
//        // ...
//    } else {
//        // ...
//    }
    // ...
}
- (void)signIn:(GIDSignIn *)signIn
didDisconnectWithUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    // Perform any operations when the user disconnects from app here.
    // ...
    NSError *signOutError;
    
    BOOL status = [[FIRAuth auth] signOut:&signOutError];
    
    if (!status) {
        
        NSLog(@"Error signing out: %@", signOutError);
        
        return;
        
    }
}
#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"SmartHome"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}
#pragma mark
- (NSString *)fetchSsid
{
    NSDictionary *ssidInfo = [self fetchNetInfo];
    
    return [ssidInfo objectForKey:@"SSID"];
}

- (NSString *)fetchBssid
{
    NSDictionary *bssidInfo = [self fetchNetInfo];
    
    return [bssidInfo objectForKey:@"BSSID"];
}

// refer to http://stackoverflow.com/questions/5198716/iphone-get-ssid-without-private-library
- (NSDictionary *)fetchNetInfo
{
    NSArray *interfaceNames = CFBridgingRelease(CNCopySupportedInterfaces());
    //    NSLog(@"%s: Supported interfaces: %@", __func__, interfaceNames);
    
    NSDictionary *SSIDInfo;
    for (NSString *interfaceName in interfaceNames) {
        SSIDInfo = CFBridgingRelease(
                                     CNCopyCurrentNetworkInfo((__bridge CFStringRef)interfaceName));
        //        NSLog(@"%s: %@ => %@", __func__, interfaceName, SSIDInfo);
        
        BOOL isNotEmpty = (SSIDInfo.count > 0);
        if (isNotEmpty) {
            break;
        }
    }
    return SSIDInfo;
}
#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

-(void)initData{
//    NSError* err = nil;
//    NSString* dataPath = [[NSBundle mainBundle] pathForResource:@"SmartHome" ofType:@"json"];
//    NSArray* rooms = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:dataPath]
//                                                     options:kNilOptions
//                                                       error:&err];
//    NSManagedObjectContext *context = self.persistentContainer.viewContext;
//
//    [rooms enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        [[CoredataHelper sharedInstance] addNewRoom:[NSString stringWithFormat:@"%ld",idx + 1] name:[obj objectForKey:@"name"] parentId:[obj objectForKey:@"parentid"] complete:^(BOOL complete,Room *room) {
//            
//        }];
//        NSError *error;
//        if (![context save:&error]) {
//            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
//        }
//    }];
//    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
//    [pref setBool:true forKey:@"init"];
}
-(void) checkNetworkStatus:(NSNotification *)notice{
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus)
    {
        case NotReachable:
        {
            NSLog(@"The internet is down.");
            self.internetActive = NO;
            
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"The internet is working via WIFI.");
            self.internetActive = YES;
            
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"The internet is working via WWAN.");
            self.internetActive = YES;
            
            break;
        }
    }
    NSLog(@"checkNetworkStatus %d",self.internetActive);
    NetworkStatus hostStatus = [hostReachable currentReachabilityStatus];
    switch (hostStatus)
    {
        case NotReachable:
        {
            NSLog(@"A gateway to the host server is down.");
            self.hostActive = NO;

            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"A gateway to the host server is working via WIFI.");
            self.hostActive = YES;

            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"A gateway to the host server is working via WWAN.");
            self.hostActive = YES;

            break;
        }
    }
}

-(void)disconnectMQTT{
//    NSLog(@"disconnectMQTT");
//    [[MQTTService sharedInstance] disconect];

}
@end
