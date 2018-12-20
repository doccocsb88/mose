//
//  PageContentViewController.m
//  SmartHome
//
//  Created by Apple on 3/19/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import "PageContentViewController.h"
#import <QRCodeReader.h>
#import <QRCodeReaderViewController.h>
#import <QRCodeReaderDelegate.h>
#import "MQTTService.h"
#import "NSString+Utils.h"
#import "FirebaseHelper.h"
#import "LoginViewController.h"
#import <SVProgressHUD.h>
#import "FacebookTestViewController.h"
@interface PageContentViewController () <AddMenuDelegate,QRCodeReaderDelegate,SortRoomDelegate,UIScrollViewDelegate>
{
    NSMutableArray *dataArray;
    CGSize screenSize;
//    QRCodeReader *reader;
//
//    // Instantiate the view controller
//    QRCodeReaderViewController *vc;
    NSMutableArray *vcs;
 
}
//@property (strong, nonatomic) UIPageViewController *pageController;
@property (strong, nonatomic) UIButton *rightButton;
@property (strong, nonatomic) UIImageView *backgroundView;
@property (assign, nonatomic) NSInteger selectedIndex;
@property (assign, nonatomic) NSInteger nuberOfPage;
@property (assign, nonatomic) NSInteger curIndex;
@property (assign, nonatomic) BOOL firstTime;
@property (strong, nonatomic) NSMutableArray *timerArray;


@end

@implementation PageContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];


    [self initNotification];
    [self initData];
    [self setupUI];
    [self initPageViewController];
    [self setupPageControl];
    //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];


}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if([[FirebaseHelper sharedInstance] isLogin] == false){
//        LoginViewController *vc = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
//        [self presentViewController:vc animated:true completion:nil];
//
        LoginViewController *vc = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self presentViewController:vc animated:true completion:nil];

    }
    self.navigationController.navigationBarHidden = NO;
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [MQTTService sharedInstance].curroomId = NSNotFound;
    if (self.firstTime) {
        self.firstTime = false;
        [self.view bringSubviewToFront:self.stageView];

        [MQTTService sharedInstance];
        [[FirebaseHelper sharedInstance] getProfileInfo:^(FIRUser *user, Boolean isNew) {
            
        }];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(mqttBecomeActive) name:@"mqttapplicationDidBecomeActive" object:nil];
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
        [SVProgressHUD showWithStatus:@"Đang xử lý"];
        [SVProgressHUD dismissWithDelay:3];
//        [self requestAllDeviceStatus];

    }
    self.navigationController.navigationBarHidden = NO;
    NSLog(@"Home viewDidAppear");
}
-(void)initNotification{
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(handleMqttConnectEvent:) name:@"kMqttConnectToServer" object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(didfinishSynRoom:) name:@"kFirebaseLogout" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didfinishSynRoom:) name:@"kFirebasedidFinishSynRoom" object:nil];

}
-(void)initData{
//    dataArray = [[NSMutableArray alloc] init];
    self.timerArray = [[NSMutableArray alloc] init];
    self.firstTime = true;
    self.selectedIndex = NSNotFound;
    vcs = [[NSMutableArray alloc] init];
    [self loadRoomFromDB];
    
    [[User sharedInstance] loadObjectFromLocal];
    
//    reader = [QRCodeReader readerWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
//
//    // Instantiate the view controller
//    vc = [QRCodeReaderViewController readerWithCancelButtonTitle:@"Cancel" codeReader:reader startScanningAtLoad:YES showSwitchCameraButton:YES showTorchButton:YES];
//    - (void)saveCustomObject:(MyObject *)object key:(NSString *)key {
//        NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:object];
//        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//        [defaults setObject:encodedObject forKey:key];
//        [defaults synchronize];
//
//    }
    

}

-(void)loadRoomFromDB{
    
    if (dataArray != nil) {
        NSLog(@"before %ld",dataArray .count);

    }else{
        NSLog(@"before %ld",0);

    }
//    if (_roomname == 0){
//        dataArray = [[[CoredataHelper sharedInstance] getListRoom] mutableCopy];
//        //        NSLog(@"numberOfRoom: %d",data.count);
//
//    }else if (_roomtype == 1){
        dataArray = [[[CoredataHelper sharedInstance] getListRoom] mutableCopy];
//    }
    self.nuberOfPage = [self getNumberOfPage];
    NSLog(@"after %ld",dataArray .count);

}

-(void)requestAllDeviceStatus{
    int index  = 0;
    if (_timerArray) {
        for (NSTimer *timer in _timerArray) {
            [timer invalidate];
        }
        [_timerArray removeAllObjects];

    }else{
        _timerArray = [NSMutableArray new];
    }
    for (Room *room in dataArray) {
        
        NSArray *devices = [room getSharedDevices];
        if (devices != NULL && devices.count > 0 && [MQTTService sharedInstance].curroomId != room.id) {
           NSTimer *timer =  [NSTimer scheduledTimerWithTimeInterval:index target:self selector:@selector(requestStatusDeviceInRoom:) userInfo:devices repeats:false];
            index += devices.count;
            [_timerArray addObject:timer];
        }
    }

}

-(void)requestStatusDeviceInRoom:(NSTimer *)timer{
    NSArray *devices = timer.userInfo;
    long currentTime = (long)(NSTimeInterval)([[NSDate date] timeIntervalSince1970]);
    long second = currentTime ;
    NSLog(@"requestStatusDeviceInRoom : %ld -- %ld",devices.count,second);

    [[MQTTService sharedInstance] subcribeDevices:devices];
    
    
}
-(void)setupUI{
    screenSize = [UIScreen mainScreen].bounds.size;
    if (_roomtype == 0){
//        self.navigationController.title = @"Room";
//        self.navigationItem.title = @"Room";
        self.rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
//        [self.rightButton setTitle:@"Add" forState:UIControlStateNormal];
        self.rightButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        [self.rightButton setImage:[UIImage imageNamed:@"ic_add_fav"] forState:UIControlStateNormal];
        self.rightButton.backgroundColor = [UIColor clearColor];
        [self.rightButton addTarget:self action:@selector(pressedAdd:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
        self.navigationItem.rightBarButtonItem = rightItem;
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.text = @"HOME";
        titleLabel.textColor = [UIColor whiteColor];//[Helper colorFromHexString:@"3fb2b5"];
        titleLabel.font = [UIFont systemFontOfSize:25];
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:titleLabel];
        self.navigationItem.leftBarButtonItem = leftItem;
    }else if (_roomtype == 1){
        self.navigationItem.title = _roomname;

    }
    
    self.backgroundView= [[UIImageView alloc] initWithFrame:CGRectMake(screenSize.width, 0,screenSize.width , screenSize.height)];
    self.backgroundView.image = [UIImage imageNamed:@"ic_background"];
//    [self.view addSubview:self.backgroundView];
//
    //
    
}
-(void)initPageViewController{
    
    //
    UINavigationBar *bar = [self.navigationController navigationBar];
    [bar setTintColor:[Helper colorFromHexString:@"181819"]];

    //
    for (APPChildViewController *vc in vcs) {
        [vc.view removeFromSuperview];
    }
    //
    self.pageControl.numberOfPages = [self getNumberOfPage];
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * [self getNumberOfPage], 0);
    CGFloat width = self.scrollView.bounds.size.width;
    CGFloat height = self.scrollView.bounds.size.height;
    for (int i = 0; i < [self getNumberOfPage]; i++) {
        APPChildViewController *initialViewController = [self viewControllerAtIndex:i];

        initialViewController.view.frame = CGRectMake(i * width, 0, width, height);
        [initialViewController reloadData];

        [self.scrollView addSubview:initialViewController.view];

    }
    self.scrollView.backgroundColor = [UIColor clearColor];
//    self.containerView.backgroundColor = [UIColor clearColor];
    self.scrollView.delegate = self;
}
- (void)setupPageControl
{
    [[UIPageControl appearance] setPageIndicatorTintColor:[UIColor grayColor]];
    [[UIPageControl appearance] setCurrentPageIndicatorTintColor:[UIColor redColor]];
    [[UIPageControl appearance] setBackgroundColor:[UIColor clearColor]];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(APPChildViewController *)viewController index];
    if (index == 0) {
        return nil;
    }
    
    index--;
    _curIndex = index;
    NSLog(@"curIndex: %ld",_curIndex);
    return [self viewControllerAtIndex:index];
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(APPChildViewController *)viewController index];

    
    index++;
    _curIndex = index;
    NSLog(@"curIndex: %ld",_curIndex);

    NSLog(@"numberOfpage : %ld",self.nuberOfPage);
    if (index == self.nuberOfPage) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
    
}

- (APPChildViewController *)viewControllerAtIndex:(NSUInteger)index {
    APPChildViewController *childViewController = nil;
 
    if (index < vcs.count) {
        if ([vcs objectAtIndex:index ] == nil) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            childViewController =  [storyboard instantiateViewControllerWithIdentifier:@"APPChildViewController"];
            [vcs addObject:childViewController];

        }else{
            childViewController = [vcs objectAtIndex:index];
        }
    }else{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        childViewController =  [storyboard instantiateViewControllerWithIdentifier:@"APPChildViewController"];
        [vcs addObject:childViewController];
    }
    childViewController.navController = self.navigationController;

    childViewController.index = index;
    childViewController.roomtype = _roomtype;
    childViewController.dataArray = [self getDataWithPage:index];
    return childViewController;
    
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    // The number of items reflected in the page indicator.
    if (dataArray .count > 0){
        
        NSInteger page =  dataArray.count / 12 ;
        if (dataArray.count % 12 == 1){
            page += 1;
        }
        return page;
    }
    return 1;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    // The selected item reflected in the page indicator.
    return 0;
}
#pragma mark - Additions

- (NSUInteger)currentControllerIndex
{
    int page = self.scrollView.contentOffset.x / self.scrollView.frame.size.width;
    return page;
}

- (UIViewController *)currentController
{
//    if ([self.pageController.viewControllers count])
//    {
//        return self.pageController.viewControllers[0];
//    }
    
    return nil;
}

-(NSInteger)getNumberOfPage{
    if (dataArray .count > 0){
        
        NSInteger page =  dataArray.count / 12;
        if (dataArray.count % 12 != 0){
            page += 1;
        }
        return page;
    }
    return 1;
}

-(NSMutableArray *)getDataWithPage:(NSInteger)page{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (NSInteger i = page * 12; i <  (page + 1) * 12; i++) {
        if (i < dataArray.count){
            [arr addObject:[dataArray objectAtIndex:i]];
        }
    }
    return arr;
}
#pragma addMenuDelegate
-(void)didShowAddDevice{
    if([[User sharedInstance]  isAdmin] == false){
        [self showAlert:@"" message:@"Bạn không có quyền thực hiện chức năng này"];
        
    }else{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Tạo phòng" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Nhập tên phòng";
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //        <#code#>
        UITextField *tf = alert.textFields.firstObject;
        NSString *roomName = tf.text;
        [[CoredataHelper sharedInstance] addNewRoom:[NSString stringWithFormat:@"%ld",dataArray.count + 1] name:roomName parentId:nil complete:^(BOOL complete,Room *room) {
            if (complete && room) {
                [[FirebaseHelper sharedInstance] addRoom:room];
            }
        }];
        NSInteger lastNumberOfPage = [self getNumberOfPage];
        [self loadRoomFromDB];
        NSInteger  newNumberOfPage = [self getNumberOfPage];
        if (newNumberOfPage > lastNumberOfPage) {
            [self initPageViewController];

        }
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //        <#code#>
    }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:true completion:nil];
    }
}
//-(void)didShowQRCode{
//    __weak PageContentViewController *weakSelf = self;
//
//    vc.modalPresentationStyle = UIModalPresentationFormSheet;
//
//    // Define the delegate receiver
//    vc.delegate = self;
//
//    // Or use blocks
//    [reader setCompletionWithBlock:^(NSString *resultAsString) {
//        NSLog(@"%@", resultAsString);
//        [weakSelf dismissViewControllerAnimated:true completion:nil];
//        [weakSelf showQRResult:resultAsString];
//    }];
//    [self presentViewController:vc animated:YES completion:NULL];
//}
-(void)didReadQRCode:(NSString *)message{
    [self showQRResult:message];
}
-(void)openSortRoom{
    HTKSampleCollectionViewController *_vc = [[HTKSampleCollectionViewController alloc] init];
    
    _vc.dataArray = [self getDataWithPage:[self currentControllerIndex]];
    _vc.delegate = self;
    [self.navigationController pushViewController:_vc animated:YES];
//    [self.view addSubview:_vc.view];
}
#pragma mark - Button Actions

-(void)pressedAdd:(UIButton *)sender{
   
        [self showMenuView];
    
}

-(void)showMenuView{
    AddMenuViewController *vcz = [self.storyboard instantiateViewControllerWithIdentifier:@"AddMenuViewController"];
    vcz.delegate = self;
    [self presentViewController:vcz animated:YES completion:nil];
}
-(void)showQRResult:(NSString *)message{
//    NSArray * result =  [message componentsSeparatedByString:@";"];
//    if (result && result.count >= 1) {
//        if ([result[0] isNumber]) {
//            NSInteger type = [result[0] integerValue];
//            NSString *topic = [result[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//            Device *device = [[CoredataHelper sharedInstance] getDeviceByTopic:topic type:type];
//            if (device) {
//                [self showAlert:@"" message:@"Thiết bị này đã tồn tại."];
//            }else{
//                NSInteger deviceId = [[CoredataHelper sharedInstance] countDevice] + 1;
//                [[CoredataHelper sharedInstance] addNewDevice:@"abc" name:topic deviceId:deviceId state:NO value:0 topic:topic type:type complete:^(Device *device) {
//                    if (device) {
//                        
//                    }
//                }];
//                [self showAlert:@"" message:@"Thêm thành công."];
//
//            }
//        }
//    }
}

-(void)showAlert:(NSString *)title message:(NSString *)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"QRCODE" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //        <#code#>
    }];
    [alert addAction:okAction];
    [self presentViewController:alert animated:true completion:nil];
}
#pragma mark
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    self.pageControl.currentPage = [self currentControllerIndex];
}
#pragma mark - SortRoomDelegate

-(void)mqttBecomeActive{
    NSLog(@"becomeActive 2");
    if ([[FirebaseHelper sharedInstance] isLogin]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            if ([MQTTService sharedInstance].isConnect == false && [MQTTService sharedInstance].isConnecting == false) {
                [[MQTTService sharedInstance] conect];
            }
        });
        [self requestAllDeviceStatus];

    }
}
-(void)handleMqttConnectEvent:(NSNotification *)notification{
    NSDictionary *info = notification.userInfo;
    if (info) {
        if ([info objectForKey:@"result"]) {
            NSInteger result = [[info objectForKey:@"result"] integerValue];
            NSLog(@"handleMqttConnectEvent %ld",result);

            switch (result) {
                case 0:
                    //start connect
                    self.stageView.hidden = NO;
                    self.connectionMessageLabel.text = @"Đang kết nối";
                    [self.connectionLoading startAnimating];
                    break;
                case 1:
                    //success
                    self.stageView.hidden = YES;
                    self.connectionMessageLabel.text = @"Kết nối thành công";

                    break;
                default:
                    //failed
                    self.stageView.hidden = NO;
                    self.connectionMessageLabel.text = @"Kết nối thất bại";

                    break;
            }
        }
    }else{
        //start to connect
        self.stageView.hidden = NO;
    }
}
-(void)mqttConnected{
    self.stageView.hidden = YES;
    self.connectionMessageLabel.text = @"Kết nối thành công";
}

-(void)didSortRoom{
    [self loadRoomFromDB];
    _curIndex = [self currentControllerIndex];
    APPChildViewController *curVC = [self viewControllerAtIndex:_curIndex];
    NSArray *dataArray = [self getDataWithPage:_curIndex];
    [curVC reloadData:dataArray];
    for (Room *room in dataArray) {
        [[FirebaseHelper sharedInstance] updateRoom:room];
    }

}

-(void)didfinishSynRoom:(NSNotification *)notification{

    NSInteger lastNumberOfPage = [self getNumberOfPage];
    [self loadRoomFromDB];
    NSInteger  newNumberOfPage = [self getNumberOfPage];
    if (newNumberOfPage > lastNumberOfPage) {
        [self initPageViewController];
        
    }else{
        _curIndex = [self currentControllerIndex];
        APPChildViewController *curVC = [self viewControllerAtIndex:_curIndex];
        [curVC reloadData:[self getDataWithPage:_curIndex]];
    }

}

-(void)appWillResignActive:(NSNotification*)note
{
    NSLog(@"appWillResignActive");
    for (NSTimer *timer in _timerArray) {
        [timer invalidate];
    }
    [_timerArray removeAllObjects];
    [[MQTTService sharedInstance] disconect];
}
-(void)appWillTerminate:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
}

@end
