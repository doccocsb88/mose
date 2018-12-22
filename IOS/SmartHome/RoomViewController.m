//
//  RoomViewController.m
//  SmartHome
//
//  Created by Apple on 3/20/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import "RoomViewController.h"
#import "FavViewCell.h"
#import "BaseViewCell.h"
#import "UIImage+Color.h"
#import <QRCodeReader.h>
#import <QRCodeReaderViewController.h>
#import <QRCodeReaderDelegate.h>
#import "KLCPopup.h"
#import "ListControlViewController.h"
//#import "SCSkypeActivityIndicatorView.h"
@interface RoomViewController ()<UITableViewDataSource, UITableViewDelegate,UIGestureRecognizerDelegate,EditDeviceDelegate,DeviceCellDelegate,MQTTServiceDelegate,QRCodeReaderDelegate>
{
    NSMutableArray *typeArr;
    NSMutableArray *dataArray;
    NSMutableArray *displayArray;
    
    CGSize screenSize;
    QRCodeReader *reader;
    
    // Instantiate the view controller
    QRCodeReaderViewController *vc;
}
@property (assign, nonatomic) NSInteger selectedDeviceId;
@property (assign, nonatomic) NSInteger curType;
@property (assign, nonatomic) NSInteger retry;
@property (assign, nonatomic) BOOL firstTime;
//@property (strong, nonatomic) Device *addDevice;
@property (strong, nonatomic) Device *delDevice;
@property (assign, nonatomic) NSInteger chanel;

@property (strong, nonatomic) NSString *lastQRCode;
//@property (nonatomic, strong)  SCSkypeActivityIndicatorView *activityIndicatorView;

//@property (strong, nonatomic) MQTTSession *session;
@property (strong, nonatomic) KLCPopup *controlPopup;
@property (strong, nonatomic) ListControlViewController *popupContent;
@property (strong, nonatomic) SmartConfigViewController *smartconfigViewController;
@end

@implementation RoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupControlPopup];
    [self loadData];
    [self setupUI];
    self.activityIndicatorView = [[SCSkypeActivityIndicatorView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - LOADING_SIZE)/2, (self.view.frame.size.height - LOADING_SIZE)/2 - 64, LOADING_SIZE, LOADING_SIZE)];
    self.activityIndicatorView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    self.activityIndicatorView.layer.cornerRadius = LOADING_SIZE * 0.5;
    self.activityIndicatorView.layer.masksToBounds = true;
    self.activityIndicatorView.hidden = YES;
    [self.view addSubview:self.activityIndicatorView];
    // [MQTTService sharedInstance].delegate = self;
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(mqttBecomeActive) name:@"mqttapplicationDidBecomeActive" object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(loadData) name:@"kFirebaseRemoveDevice" object:nil];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MQTTService sharedInstance].delegate = self;
    
    
}

-(void)dealloc{
    [NSNotificationCenter.defaultCenter removeObserver:self name:@"mqttapplicationDidBecomeActive" object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:@"kFirebaseRemoveDevice" object:nil];
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@"viewDidAppear");
    if ( [[MQTTService sharedInstance] isConnected] == false) {
        [self showLoadingView];
        
        [[MQTTService sharedInstance] conect];
    }else{
        [self requestStatusDevices ];
    }
    self.firstTime = true;
    [self setTitle:self.room.name connected:[MQTTService sharedInstance].isConnect];
    __weak RoomViewController *wSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        wSelf.isProcessing = false;
        [wSelf hideLoadingView];
    });
    [MQTTService sharedInstance].curroomId = self.room.id;
}

-(void)loadData{
    _curType = 0;
    _retry = 0;
    dataArray = [NSMutableArray new];
    
    NSSortDescriptor *imageSort = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:NO];
    NSArray *allDevices =  [[[self.room.devices allObjects] sortedArrayUsingDescriptors:@[imageSort]] mutableCopy];
    if ([[User sharedInstance] isAdmin]) {
        dataArray = [allDevices mutableCopy];
    }else{
        if ([[User sharedInstance] isShared]) {
            NSLog(@"sharedDevices : %@",[User sharedInstance].devices);
            for(Device *dv in allDevices){
                if (dv.type == DeviceTypeTouchSwitch) {
                    for (int i = 0; i < [dv numberOfSwitchChannel]; i++) {
                        int chanelIndex = i + 1;
                        NSString *requestId = [NSString stringWithFormat:@"%@/%d",dv.requestId,chanelIndex];
                        BOOL isOnLine = dv.isOnline;
                        NSLog(@"cc %d",isOnLine);
                        if ([[User sharedInstance].devices containsObject:requestId] ) {
                            [dataArray addObject:dv];
                            break;
                        }
                    }
                }else{
                    if ([[User sharedInstance].devices containsObject:dv.requestId] ) {
                        [dataArray addObject:dv];
                    }
                }
            }
        }
    }
    
    displayArray = [dataArray mutableCopy];
    screenSize = [UIScreen mainScreen].bounds.size;
    typeArr = [[NSMutableArray alloc] init];
    
}
-(void)setupUI{
    self.tableView.separatorStyle = UITableViewCellSelectionStyleDefault;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                               initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [self.tableView addGestureRecognizer:longPress];
    [self setupNavigator];
    //
    //    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
    //                                          initWithTarget:self action:@selector(handleLongPress:)];
    //    lpgr.minimumPressDuration = 1.0; //seconds
    //    lpgr.delegate = self;
    //    [self.tableView addGestureRecognizer:lpgr];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"LightOnOffViewCell" bundle:nil] forCellReuseIdentifier:@"lightOnOffViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"RemViewCell" bundle:nil] forCellReuseIdentifier:@"remViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TouchSwitchViewCell" bundle:nil] forCellReuseIdentifier:@"TouchSwitchViewCell"];
    
    [self initFilterView];
    
    reader = [QRCodeReader readerWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    // Instantiate the view controller
    vc = [QRCodeReaderViewController readerWithCancelButtonTitle:@"Cancel" codeReader:reader startScanningAtLoad:YES showSwitchCameraButton:YES showTorchButton:YES];
}

-(void)initFilterView{
    NSMutableArray *types = [[NSMutableArray alloc] init];
    [types addObject:@"0"];//all
    
    for (Device *device in dataArray) {
        NSString *type = [NSString stringWithFormat:@"%ld",device.type];
        if ([types containsObject:type] == false) {
            [types addObject:type];
        }
    }
    if (types.count == typeArr.count) {
        return;
    }
    typeArr = [[NSMutableArray alloc] initWithArray:types];
    for (int i = 0; i < 10; i++) {
        NSInteger tag = i + 10;
        UIButton *btn = [self.filterView viewWithTag:tag];
        if ( btn != nil) {
            [btn removeFromSuperview];
        }
    }
    CGFloat width = screenSize.width / typeArr.count;
    CGFloat height = self.filterView.frame.size.height;
    
    for (int i = 0; i < typeArr.count; i++) {
        UIView *fillterView = [UIView new];
        //fillterView.backgroundColor = [UIColor redColor];
        fillterView.frame = CGRectMake(i * width , 0, width, height);
        fillterView.tag = [[typeArr objectAtIndex:i] integerValue] + 10;
        fillterView.backgroundColor = [UIColor clearColor];
        UIButton *btn  = [[UIButton alloc] initWithFrame:CGRectMake(5+ (width - height)/2 , 0, height - 10 , height - 15)];
        //        [btn setTitle:@"a" forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"ic_type_%@",[typeArr objectAtIndex:i]]] forState:UIControlStateNormal];
        btn.imageEdgeInsets = UIEdgeInsetsMake(5, 10, 10, 10);
        btn.tag = fillterView.tag;
        btn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [btn addTarget:self action:@selector(pressedFillter:) forControlEvents:UIControlEventTouchUpInside];
        [btn setBackgroundImage:[Helper imageFromColor:[[UIColor clearColor] colorWithAlphaComponent:0.3]]  forState:UIControlStateSelected];
        NSInteger index = [[typeArr objectAtIndex:i] integerValue];
        if (index == _curType) {
            btn.selected = true;
        }else{
            btn.selected = false;
        }
        UILabel *nameLabel = [UILabel new];
        nameLabel.frame = CGRectMake(0, height - 15, width, 13);
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.font = [UIFont systemFontOfSize:12];
        nameLabel.tag = [[typeArr objectAtIndex:i] integerValue] + 20;
        if (index == _curType) {
            nameLabel.textColor = [Helper colorFromHexString:@"#cc9933"];
        }else{
            nameLabel.textColor = [UIColor whiteColor];
            
        }
        if (index == 0) {
            nameLabel.text = @"Tất cả thiết bị";
        }else if(index == DeviceTypeCurtain){
            nameLabel.text = @"Rèm";
        }else if(index == DeviceTypeLightOnOff){
            nameLabel.text = @"Đèn";
        }else if(index == DeviceTypeTouchSwitch){
            nameLabel.text = @"Công tắc";
            
        }
        [fillterView addSubview:btn];
        [fillterView addSubview:nameLabel];
        [self.filterView addSubview:fillterView];
    }
    if ([self.filterView viewWithTag:99] == nil) {
        UIView *separate = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
        separate.tag = 99;
        separate.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        [self.filterView addSubview:separate];
        
    }
    self.filterView.backgroundColor = [UIColor whiteColor];
    [self.tableView reloadData];
}
-(void)setupNavigator{
    self.rightButton = [[UIButton alloc] init];
    self.rightButton.frame = CGRectMake(0, 0, 40, 40);
    self.rightButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.rightButton setImage:[UIImage imageNamed:@"ic_add_device"] forState:UIControlStateNormal];
    [self.rightButton addTarget:self action:@selector(pressedRight:) forControlEvents:UIControlEventTouchUpInside];
    self.rightButton.backgroundColor = [UIColor clearColor];
    self.rightButton.layer.cornerRadius = 3;
    self.rightButton.layer.masksToBounds = YES;
    self.rightButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    //
    
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
    self.navigationItem.title = self.room.name;
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
}

-(void)setTitle:(NSString *)title connected:(BOOL)connected{
    self.navigationItem.title = title;
    
    if (connected) {
        [self.navigationController.navigationBar setTitleTextAttributes:
         @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    }else{
        [self.navigationController.navigationBar setTitleTextAttributes:
         @{NSForegroundColorAttributeName:[UIColor grayColor]}];
        //        [Helper colorFromHexString:@"D3D3D3"]
    }
}
-(void)setupControlPopup{
    screenSize = [UIScreen mainScreen].bounds.size;
    self.popupContent = [[ListControlViewController alloc] initWithNibName:@"ListControlViewController" bundle:nil];
    CGRect frame = self.popupContent.view.frame;
    CGFloat heigth = [[CoredataHelper sharedInstance] countController:DeviceTypeLightOnOff] * 40 + 140;
    frame.size = CGSizeMake(screenSize.width - 100, heigth);
    self.popupContent.view.frame = frame;
    self.controlPopup = [KLCPopup popupWithContentView:self.popupContent.view showType:KLCPopupShowTypeGrowIn dismissType:KLCPopupDismissTypeGrowOut maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    
}
-(void)mqttBecomeActive{
    NSLog(@"becomeActive 1");
    
}

-(void)requestStatusDevices{
    if (dataArray && dataArray.count > 0) {
        if([self willShowLoadingView]){
            [self showLoadingView];
        }
        [[MQTTService sharedInstance] subcribeDevices:dataArray];
    }
}

-(Boolean)willShowLoadingView{
    if (dataArray && dataArray.count > 0) {
        for (Device *device in dataArray){
            if (device.isGetStatus == false){
                return true;
            }
        }
    }
    return false;
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
-(CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    Device *device = [displayArray objectAtIndex:indexPath.row];
    if (device.type == DeviceTypeLightOnOff) {
        return 100.0;
    }else if (device.type == DeviceTypeCurtain){
        return 130.0;
    }else if (device.type == DeviceTypeTouchSwitch){
        return 110 * [device numberofSharedChanel] + 30;
    }
    return 100;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (displayArray == nil){
        return 0;
    }
    return [displayArray count];
    //    return 2;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    Device *device = [displayArray objectAtIndex:indexPath.row];
    if(device.type  == DeviceTypeLightAdjust){
        LightValueViewCell *cell = (LightValueViewCell *)[tableView dequeueReusableCellWithIdentifier:@"lightViewCell" forIndexPath:indexPath];
        UIView *bg = [cell viewWithTag:1];
        bg.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewRowActionStyleDefault;
        [cell setContentView:device type:0];
        cell.delegate = self;
        
        return cell;
    }else if (device.type == DeviceTypeLightOnOff){
        LightStateViewCell *cell = (LightStateViewCell *)[tableView dequeueReusableCellWithIdentifier:@"lightOnOffViewCell" forIndexPath:indexPath];
        UIView *bg = [cell viewWithTag:1];
        bg.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewRowActionStyleDefault;
        [cell setContentView:device type:0];
        cell.delegate = self;
        return cell;
        
    }else if (device.type == DeviceTypeCurtain){
        RemViewCell *cell = (RemViewCell *)[tableView dequeueReusableCellWithIdentifier:@"remViewCell" forIndexPath:indexPath];
        UIView *bg = [cell viewWithTag:1];
        bg.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewRowActionStyleDefault;
        [cell setContentView:device type:0];
        cell.delegate = self;
        return cell;
        
    }else if (device.type == DeviceTypeTouchSwitch){
        TouchSwitchViewCell *cell = (TouchSwitchViewCell *)[tableView dequeueReusableCellWithIdentifier:@"TouchSwitchViewCell" forIndexPath:indexPath];
        [cell setContentValue:device];
        __weak RoomViewController *wself = self;
        __weak TouchSwitchViewCell *wCell = cell;
        cell.isLoading = self.isProcessing;
        cell.completionHandler = ^(NSString *value, NSInteger chanel) {
            wself.chanel = chanel;
            [wself didPressedControl:device.id];
        };
        cell.controlHandler = ^{
            [wself showLoadingView];
            wself.isProcessing = true;
            wCell.isLoading = true;
        };
        cell.selectionStyle = UITableViewRowActionStyleDefault;
        
        return cell;
    }
    
    return [UITableViewCell new];
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    //    if (typeArr.count == 1) {
    return [UIView new];
    //    }
    //    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40);
    //
    //    UIView *header =  [[UIView alloc] initWithFrame:frame];
    //    header.backgroundColor = [UIColor blackColor];
    //    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, frame.size.width - 30 * 2, 40)];
    //    titleLable.textColor = [UIColor whiteColor];
    //    [header addSubview:titleLable];
    //    NSInteger index = section + 1;
    //    NSInteger type = [[typeArr objectAtIndex:index] integerValue];
    //    if(type == DeviceTypeLightOnOff){
    //        titleLable.text = @"Đèn";
    //
    //    }else if (type == DeviceTypeCurtain){
    //        titleLable.text = @"Rèm";
    //
    //    }else{
    //        titleLable.text = @"CC gi day";
    //
    //    }
    //    return header;
}
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    Device *from = [dataArray objectAtIndex:sourceIndexPath.row];
    NSInteger order = from.order;
    
    Device *to = [dataArray objectAtIndex:destinationIndexPath.row];
    from.order = to.order;
    to.order = order;
    [[CoredataHelper sharedInstance] save];
    
    [dataArray exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
    //    NSSortDescriptor *imageSort = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:NO];
    //    NSArray *sortedImages = [[self.room.devices allObjects] sortedArrayUsingDescriptors:@[imageSort]];
    //
    //    //    [[[CoredataHelper sharedInstance] getListDevice] mutableCopy];
    displayArray = [dataArray mutableCopy];
    NSLog(@"kdjkfjdkfjk ");
}
#
#pragma mark
//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//    return typeArr.count;
//}
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    CGFloat width = (screenSize.width - 10 * typeArr.count)/ typeArr.count;
//    CGFloat height = 50;
//    return CGSizeMake(width, height);
//}
//
//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
//    static NSString *identifier = @"xxCell";
//
//    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
//
//    return cell;
//}
//
//-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//
//}

#pragma mark

-(void)pressedLeft:(UIButton *)button{
    [self hideLoadingView];
    [self.navigationController popViewControllerAnimated:true];
}

-(void)pressedRight:(UIButton *)button{
    if ([User sharedInstance].accountType == 2) {
        [self showAlert:@"" message:@"Bạn không có quyền thực hiện chức năng này"];
    }else{
        [self showQRCodeReaderScreen:QRCodeTypeDevice];
        
    }
}

-(void)pressedSetup:(UIButton *)sender{
    
}
-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    if (indexPath == nil) {
        NSLog(@"long press on table view but not on a row");
    } else if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"long press on table view at row %ld", indexPath.row);
        self.selectedDeviceId = indexPath.row;
        [self showEditDeviceMenu];
    } else {
        NSLog(@"gestureRecognizer.state = %ld", gestureRecognizer.state);
    }
}

-(void)pressedFillter:(UIButton *)sender{
    NSInteger tag = sender.tag - 10;
    _curType = tag;
    [self filterWithTag:tag];
    [self setSelectedFiler];
}
-(void)filterWithTag:(NSInteger )tag{
    [displayArray removeAllObjects];
    if (tag == 0) {
        [displayArray addObjectsFromArray:dataArray];
    }else{
        for (int i = 0; i < dataArray.count; i++) {
            Device *dv = [dataArray objectAtIndex:i];
            if (dv.type == tag) {
                [displayArray addObject:dv];
            }
        }
    }
    if (displayArray.count == 0) {
        _curType = 0;
    }
    [self.tableView reloadData];
}

-(void)setSelectedFiler{
    for (int i = 0 ; i < typeArr.count; i++) {
        NSInteger index = [[typeArr objectAtIndex:i] integerValue];
        
        NSInteger tag = index + 10;
        UIView *view = [self.filterView viewWithTag:tag];
        for (UIView *sub in view.subviews) {
            if ([sub isKindOfClass:[UIButton class]]) {
                UIButton *btn  =  (UIButton *)sub;
                if (btn) {
                    if (index == _curType) {
                        btn.selected = true;
                    }else{
                        btn.selected = false;
                    }
                }
                
            }
        }
        UILabel *label = [view viewWithTag:tag + 10];
        if (label) {
            if (index == _curType) {
                label.textColor = [UIColor yellowColor];
            }else{
                label.textColor = [UIColor whiteColor];
            }
        }
        
    }
}

-(void)setStateValueForDevice:(NSString *)topic value:(float)value{
    for (Device *device in displayArray) {
        if ([topic containsString:device.requestId]) {
            device.value = value;
            [[CoredataHelper sharedInstance] save];
            [self.tableView reloadData];
            break;
            
        }
    }
}
-(void)setStateValueForLight:(NSString *)message{
    if ([message containsString:@"value"]) {
        NSArray *tmp = [message componentsSeparatedByString:@"'"];
        for (Device *device in displayArray) {
            //            device.value = value;
            NSString *_id = tmp[1];
            if ([_id containsString:@"/"]){
                _id = [_id componentsSeparatedByString:@"/"][0];
            }
            if (_id && [_id isEqualToString:device.requestId]) {
                
                NSString *value = tmp[5];
                if (value && value.length == @"1,2,1".length) {
                    if ([value isEqualToString:@"1,2,1"]) {
                        device.state = NO;
                    }else if([value isEqualToString:@"1,2,0"]){
                        device.state = YES;
                        
                    }
                    [[CoredataHelper sharedInstance] save];
                    [self.tableView reloadData];
                    
                    break;
                }else if([value containsString:@"W"]){
                    //touch switch
                    //                    NSString *chanel = @"";
                    //                    if([tmp[1] containsString:@"/"]){
                    //                        chanel = [tmp[1] componentsSeparatedByString:@"/"][1];
                    //                    }
                    //                    if (chanel.length > 0 && [chanel isNumber]) {
                    //                        int numberIndex = [chanel intValue];
                    //                        [device updateStatusForChanel:numberIndex value:value];
                    //
                    //                    }
                    //                    [[CoredataHelper sharedInstance] save];
                    //                    [self.tableView reloadData];
                    //
                    //                    break;
                }else if([value isNumber]){
                    //rem
                    
                    device.value = [value floatValue];
                    [[CoredataHelper sharedInstance] save];
                    [self.tableView reloadData];
                    break;
                    
                    
                }
                
            }
            
            
            
        }
        
    }
}
#pragma mark
-(void)didChangeCellState:(NSInteger)deviceId value:(BOOL)value{
    for (int i = 0; i < displayArray.count; i++) {
        Device *device = [displayArray objectAtIndex:i];
        if (device.id == deviceId) {
            device.state = value;
            break;
        }
    }
    [[CoredataHelper sharedInstance] save];
}
-(void)didChangeCell:(NSInteger)deviceId value:(CGFloat)value{
    for (int i = 0; i < displayArray.count; i++) {
        Device *device = [displayArray objectAtIndex:i];
        if (device.id == deviceId) {
            device.value = value;
            [self showLoadingView];
            NSString *msg = [NSString stringWithFormat:@"id='%@' cmd='OPEN' value='%d'",device.requestId,(NSInteger)value];
            [[MQTTService sharedInstance] publishControl:device.requestId topic:device.topic  message:msg type:device.type count:1 complete:^(BOOL finished) {
                
            }];
            break;
        }
    }
    [[CoredataHelper sharedInstance] save];
    //    [self.tableView reloadData];
}

-(void)didPressedButton:(NSInteger)deviceId value:(ButtonType)value{
    if (self.isProcessing) {
        return;
    }
    for (int i = 0; i < displayArray.count; i++) {
        Device *device = [displayArray objectAtIndex:i];
        if (device.id == deviceId) {
            if (value == ButtonTypeClose) {
                [self showLoadingView];
                self.isProcessing = true;
                
                [[MQTTService sharedInstance] publishControl:device.requestId topic:device.topic message:@"CLOSE" type:device.type count:1 complete:^(BOOL finished) {
                    
                }];
            }else if (value == ButtonTypeStop){
                [self showLoadingView];
                self.isProcessing = true;
                
                
                [[MQTTService sharedInstance] publishControl:device.requestId topic:device.topic message:@"STOP" type:device.type count:1 complete:^(BOOL finished) {
                    
                }];
                
            }else if (value == ButtonTypeOpen){
                [self showLoadingView];
                self.isProcessing = true;
                
                [[MQTTService sharedInstance] publishControl:device.requestId topic:device.topic message:@"OPEN" type:device.type count:1 complete:^(BOOL finished) {
                    
                }];
                
            }
            break;
        }
    }
    
}

-(void)didPressedControl:(NSInteger)deviceId{
    self.selectedDeviceId = deviceId;
    
    [self showEditDeviceMenu];
    
}

-(Device *)deviceById:(NSInteger)deviceId{
    for (Device *device in displayArray) {
        if (device.id == deviceId) {
            return device;
        }
    }
    return nil;
}
#pragma mark
#pragma mark - EditMenuDelegate
-(void)selectMenuAtIndex:(NSInteger)index{
    Device *device = nil;
    for (Device *dv in displayArray) {
        if (dv.id == self.selectedDeviceId) {
            device = dv;
            break;
        }
    }
    if (device == nil) {
        return;
    }
    
    switch (index) {
        case 0:
            //heng io
            //            UIStoryboard *storyboard = [UIStoryboard st]
            [self showAddTimeViewController];
            break;
        case 1:
            //khoa thiet bi
            device.control = !device.control;
            if([device numberOfSwitchChannel] > 0){
                [device updateAutoControlForChanel:self.chanel status:false];
            }
            [[CoredataHelper sharedInstance] save];
            [[FirebaseHelper sharedInstance] updateDevice:device roomId:self.room.id];
            break;
        case 2:
            //doi ten thiet bi
            
            if (device != nil) {
                [self showChangeDeviceNameAlert:device];
            }
            
            break;
        case 3:
            //thay bieu tuong
            
            break;
        case 4:
            //thong tin thiet bi
            if (device != nil) {
                self.delDevice = device;
            }
            
            break;
        case 5:
            //xoa thiet bi
            if (device != nil) {
                [self showConfirmDialog:@"" message:@"Bạn có muốn xoá thiết bị này không?" complete:^(NSInteger index) {
                    if(index == 1){
                        self.delDevice = device;
                        if(self.delDevice.type == DeviceTypeCurtain || self.delDevice.type == DeviceTypeTouchSwitch){
                            [self mqttDelSuccess];
                        }else{
                            [[MQTTService sharedInstance] delMQTTDevice:device];
                        }
                    }
                }];
                
            }
            
            break;
        default:
            break;
    }
}


-(void)removeDevieWithId:(NSInteger )_id{
    NSInteger index = NSNotFound;
    for (int i = 0 ; i < displayArray.count; i++) {
        Device *dv = [displayArray objectAtIndex:i];
        if (dv.id == _id) {
            index =  i;
            break;
        }
    }
    if (index != NSNotFound) {
        [displayArray removeObjectAtIndex:index];
    }
    
}

-(Device *)getSelectedDevice{
    for (Device *device in displayArray) {
        if (device.id == self.selectedDeviceId) {
            return device;
        }
    }
    return nil;
}

-(void)showAddTimeViewController{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ListTimerViewController *_vc = [storyboard instantiateViewControllerWithIdentifier:@"ListTimerViewController"];
    _vc.device = [self getSelectedDevice];
    _vc.chanel = self.chanel;
    [self.navigationController pushViewController:_vc animated:YES];
}
-(void)showEditDeviceMenu{
    EditDeviceMenuViewController *_vc = [self.storyboard instantiateViewControllerWithIdentifier:@"EditDeviceMenuViewController"];
    _vc.delegate = self;
    _vc.device = [self deviceById:self.selectedDeviceId];
    _vc.chanel = self.chanel ;
    [self presentViewController:_vc animated:true completion:nil];
}


-(void)mqttConnected{
    [self.activityIndicatorView stopAnimating];
    self.activityIndicatorView.hidden = YES;
    [self setTitle:self.room.name connected:YES];
    [[MQTTService sharedInstance]requestStatus:dataArray];
    NSLog(@"mqttConnected : %ld",dataArray.count);
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //        [self showLoadingView];
    //        [[MQTTService sharedInstance] setListDevices:dataArray];
    //
    //    });
}

-(void)mqttDisConnect{
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state == UIApplicationStateActive) {
        if (_retry == 0 ) {
            
            _retry = 1;
            [[MQTTService sharedInstance] conect];
        }else{
            [[MQTTService sharedInstance] removeListDevices:dataArray];
            [self setTitle:self.room.name connected:NO];
            [self hideLoadingView];
            [self showMessageView:@"" message:@"Không có kết nối mạng" autoHide:false complete:^(NSInteger index) {
                if (index == 1) {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
        }
        
    }
}
-(void)mqttAddSuccess{
    //    self.lastQRCode =  nil;
    
    //    if (self.addDevice) {
    //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    ////            if (self.lastQRCode != nil) {
    //                NSLog(@"showInputNameAlert a");
    //                [self showInputNameAlert:self.addDevice];
    //
    ////            }
    //
    //        });
    //    }
}
-(void)mqttDelSuccess{
    if (self.delDevice) {
        [[FirebaseHelper sharedInstance] delleteDeviceInSystem:self.delDevice.requestId];
        [[FirebaseHelper sharedInstance] delleteDevice:self.delDevice.key];
        [[FirebaseHelper sharedInstance] deleteSceneDetailByDeviceId:self.delDevice.id];
        
        [[CoredataHelper sharedInstance] deleteTimerByDeviceId:self.delDevice.requestId];
        [[CoredataHelper sharedInstance] deleteDetailByDeviceId:self.delDevice.id];
        [[CoredataHelper sharedInstance] deleteDevice:self.delDevice];
        
        [self.room removeDevicesObject:self.delDevice];
        [dataArray removeObject:self.delDevice];
        [displayArray removeObject:self.delDevice];
        [self removeDevieWithId:self.delDevice.id];
        [self initFilterView];
        [self filterWithTag:_curType];
        self.delDevice  =  nil;
    }
}
-(void)mqttFinishedProcess{
    [self hideLoadingView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}
-(void)mqttRequested:(NSString *)mqttId{
    [self hideLoadingView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}
-(void)mqttPublishFail:(NSString *)mqttId{
    
    [self hideLoadingView];
    if (mqttId != NULL && mqttId.length > 0) {
        [self showMessageView:nil message:@"Thiết bị không phản hồi" autoHide:YES complete:nil];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    
}
-(void)mqttSetStateValueForDevice:(NSString *)topic value:(float)value{
    [self hideLoadingView];
    
    self.isProcessing = false;
    
    
    [self setStateValueForDevice:topic value:value];
    
}
-(void)mqttSetStateValueForLight:(NSString *)message{
    [self hideLoadingView];
    
    //    self.isProcessing = false;
    [self.tableView reloadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.isProcessing = false;
        [self.tableView reloadData];
    });
    
}


#pragma mark
#pragma mark - QRCode

-(void)showQRCodeReaderScreen:(QRCodeType)type{
    
    __weak RoomViewController *weakSelf = self;
    
    vc.modalPresentationStyle = UIModalPresentationFormSheet;
    
    // Define the delegate receiver
    vc.delegate = self;
    vc.qrType = type;
    // Or use blocks
    [reader setCompletionWithBlock:^(NSString *resultAsString) {
        NSLog(@"%@", resultAsString);
        [weakSelf dismissViewControllerAnimated:true completion:nil];
        if (vc.qrType == QRCodeTypeDevice) {
            if (self.lastQRCode== nil) {
                [weakSelf showQRResult:resultAsString];
                
            }
        }else if(vc.qrType == QRCodeTypeTopic){
            [weakSelf readTopicFromQRcode:resultAsString];
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
-(void)readTopicFromQRcode:(NSString *)qrcode{
    NSArray *info = [qrcode componentsSeparatedByString:@";"];
    __weak RoomViewController *wSelf = self;
    
    if (info && info.count == 2 && [info[0] isEqualToString:@"controller"]){
        //    [Utils setTopic:qrcode];
        [self showSmartConfig:qrcode];
        
        
    }else{
        wSelf.lastQRCode = nil;
        
        [wSelf showMessageView:@"" message:@"QRCode không hợp lệ" autoHide:YES complete:^(NSInteger index) {
            
        }];
    }
    
}
-(void)showQRResult:(NSString *)message{
    NSArray * result =  [message componentsSeparatedByString:@";"];
    __weak RoomViewController *wSelf = self;
    if (result && result.count >= 1) {
        if ([result[0] isNumber]) {
            self.lastQRCode =  message;
            
            NSInteger type = [result[0] integerValue];
            NSString *topic = [result[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            if (type == DeviceTypeLightOnOff) {
                //                if (![Utils hasTopic]) {
                //                    self.lastQRCode =  nil;
                //
                //                    [self showMessageView:@"Thông báo" message:@"Bạn chưa nhập bộ điều khiển! Vui lòng nhập bộ điều khiển" autoHide:NO complete:^(NSInteger index) {
                //                        if (index == 1) {
                //                            //[self showQRCodeReaderScreen:QRCodeTypeTopic];
                //                            [wSelf showListTopicPopup];
                //                        }
                //                    }];
                //                    return;
                //
                //                }
                
                [wSelf showListTopicPopup:topic type:type];
                
            }else if (type == DeviceTypeTouchSwitch){
                //                [self addNewDevice:topic topic:topic type:type];
                [self showSmartConfig:message];
                
                
            }else if (type == DeviceTypeCurtain){
                //                NSString *mqttId = [topic componentsSeparatedByString:@"-"][1];
                //                [self addNewDevice:mqttId topic:topic type:type];
                [self showSmartConfig:message];
            }
            //end if (type == DeviceTypeLightOnOff) {
            
        }
    }
}

-(void)showInputNameAlert:(Device *)device{
    self.lastQRCode = nil;
    NSLog(@"showInputNameAlert");
    NSString *title = @"Thêm thành công" ;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Nhập tên thiết bị";
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Đồng ý" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //        <#code#>
        UITextField *tf = alert.textFields.firstObject;
        NSString *roomName = tf.text;
        if (roomName && roomName.length > 0) {
            //            Device *newDevice = [[CoredataHelper sharedInstance] getDeviceBycode:device.requestId];
            //
            device.name = roomName;
            [[FirebaseHelper sharedInstance] updateDevice:device roomId:self.room.id];
            [[CoredataHelper sharedInstance] save];
            NSSortDescriptor *imageSort = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:NO];
            NSArray *allDevices =  [[[self.room.devices allObjects] sortedArrayUsingDescriptors:@[imageSort]] mutableCopy];
            dataArray = [NSMutableArray new];
            
            if ([[User sharedInstance] isAdmin]) {
                dataArray = [allDevices mutableCopy];
            }else{
                if ([[User sharedInstance] isShared]) {
                    for(Device *dv in allDevices){
                        if ([[User sharedInstance].devices containsObject:dv.requestId] ) {
                            [dataArray addObject:dv];
                        }
                    }
                }else{
                }
            }
            displayArray = [dataArray mutableCopy];
            //            self.addDevice = nil;
            [[MQTTService sharedInstance] subscribeToTopic:device];
            if(device.type != DeviceTypeLightOnOff){
                [self.tableView reloadData];
            }
            
        }
        
    }];
    //    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    //        //        <#code#>
    //        self.selectedIndex = NSNotFound;
    //
    //    }];
    [alert addAction:okAction];
    //    [alert addAction:cancelAction];
    [self presentViewController:alert animated:true completion:nil];
}
-(void)showChangeDeviceNameAlert:(Device *)device{
    
    NSString *title = @"Đổi tên thiết bị" ;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Nhập tên thiết bị";
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Đồng ý" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //        <#code#>
        UITextField *tf = alert.textFields.firstObject;
        NSString *roomName = tf.text;
        if(roomName && roomName.length > 0){
            if ([device numberOfSwitchChannel] > 0) {
                NSString *nameKey = [NSString stringWithFormat:@"name%ld",self.chanel];
                NSMutableDictionary *info  = [NSMutableDictionary new];
                NSString *jsonString = device.chanelInfo;
                NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                for (int i = 1; i <= [device numberOfSwitchChannel]; i++) {
                    NSString *key = [NSString stringWithFormat:@"name%d",i];
                    NSString *controlKey = [NSString stringWithFormat:@"control%d",i];
                    if([json objectForKey:key]){
                        [info setObject:[json objectForKey:key] forKey:key];
                    }
                    if([json objectForKey:controlKey]){
                        [info setObject:[json objectForKey:controlKey] forKey:controlKey];
                    }
                    
                }
                [info setObject:roomName forKey:nameKey];
                NSError *error;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:info
                                                                   options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                                     error:&error];
                
                if (! jsonData) {
                    NSLog(@"Got an error: %@", error);
                } else {
                    device.chanelInfo = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                }
                //                device.chanelInfo = [NSString stringWithFormat:@"%@",info];
                
                
            }else{
                device.name = roomName;
            }
            
            [[CoredataHelper sharedInstance] save];
            [[FirebaseHelper sharedInstance] updateDevice:device roomId:self.room.id];
            [self.tableView reloadData];
        }
    }];
    [alert addAction:okAction];
    //    [alert addAction:cancelAction];
    [self presentViewController:alert animated:true completion:nil];
}


-(void)showSmartConfig:(NSString *)qrcodeString{
    __weak RoomViewController *wSelf = self;
    if(!self.smartconfigViewController){
        self.smartconfigViewController = [[SmartConfigViewController alloc] initWithNibName:@"SmartConfigViewController" bundle:nil];
    }
    self.smartconfigViewController.qrCodeString = qrcodeString;
    self.smartconfigViewController.handleAddControl = ^(NSString *qrcode) {
        NSArray *info = [qrcode componentsSeparatedByString:@";"];
        if ([info[0] isEqualToString:@"controller"]) {
            NSString *topic = info[1];
            Controller *controller = [[CoredataHelper sharedInstance] getControllerById:topic];
            
            if (!controller) {
                [[CoredataHelper sharedInstance] addNewController:topic name:topic order:0 type:DeviceTypeLightOnOff code:@"" key:@"" complete:^(BOOL complete, Controller *newController) {
                    if (newController) {
                        [[FirebaseHelper sharedInstance] addController:newController];
                    }
                    wSelf.lastQRCode = nil;
                    [wSelf showMessageView:@"" message:@"Đã thêm bộ điều khiển" autoHide:YES complete:^(NSInteger index) {
                        
                    }];
                }];
            }else{
                wSelf.lastQRCode = nil;
                
                [wSelf showMessageView:@"" message:@"Đã thêm bộ điều khiển" autoHide:YES complete:nil];
                
            }
        }else if([info[0] isNumber]){
            NSInteger type = [info[0] integerValue];
            NSString *topic = [info[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (type == DeviceTypeTouchSwitch){
                [wSelf addNewDevice:topic topic:topic type:type];
                
            }else if (type == DeviceTypeCurtain){
                NSString *mqttId = [topic componentsSeparatedByString:@"-"][1];
                [wSelf addNewDevice:mqttId topic:topic type:type];
            }
            
        }
        
    };
    [self.navigationController pushViewController:self.smartconfigViewController                                                                                                                                    animated:YES];
}
- (IBAction)longPressGestureRecognized:(id)sender {
    
    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
    UIGestureRecognizerState state = longPress.state;
    
    CGPoint location = [longPress locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    // More coming soon...
    static UIView       *snapshot = nil;        ///< A snapshot of the row user is moving.
    static NSIndexPath  *sourceIndexPath = nil; ///< Initial index path, where gesture begins.
    
    switch (state) {
        case UIGestureRecognizerStateBegan: {
            if (indexPath) {
                sourceIndexPath = indexPath;
                
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                
                // Take a snapshot of the selected row using helper method.
                snapshot = [self customSnapshotFromView:cell];
                
                // Add the snapshot as subview, centered at cell's center...
                __block CGPoint center = cell.center;
                snapshot.center = center;
                snapshot.alpha = 0.0;
                [self.tableView addSubview:snapshot];
                [UIView animateWithDuration:0.25 animations:^{
                    
                    // Offset for gesture location.
                    center.y = location.y;
                    snapshot.center = center;
                    snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
                    snapshot.alpha = 0.98;
                    
                    // Fade out.
                    cell.alpha = 0.0;
                    
                } completion:^(BOOL finished) {
                    
                    cell.hidden = YES;
                    
                }];
            }
            break;
        }
            // More coming soon...
        case UIGestureRecognizerStateChanged: {
            CGPoint center = snapshot.center;
            center.y = location.y;
            snapshot.center = center;
            
            // Is destination valid and is it different from source?
            if (indexPath && ![indexPath isEqual:sourceIndexPath]) {
                
                // ... update data source.
                //                [dataArray exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                Device *from = [dataArray objectAtIndex:sourceIndexPath.row];
                NSInteger order = from.order;
                
                Device *to = [dataArray objectAtIndex:indexPath.row];
                from.order = to.order;
                to.order = order;
                [[CoredataHelper sharedInstance] save];
                
                [dataArray exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:indexPath.row];
                
                displayArray = [dataArray mutableCopy];
                // ... move the rows.
                [self.tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:indexPath];
                
                // ... and update source so it is in sync with UI changes.
                sourceIndexPath = indexPath;
            }
            break;
        }
            // More coming soon...
        default: {
            // Clean up.
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:sourceIndexPath];
            cell.hidden = NO;
            cell.alpha = 0.0;
            [UIView animateWithDuration:0.25 animations:^{
                
                snapshot.center = cell.center;
                snapshot.transform = CGAffineTransformIdentity;
                snapshot.alpha = 0.0;
                
                // Undo fade out.
                cell.alpha = 1.0;
                
            } completion:^(BOOL finished) {
                
                sourceIndexPath = nil;
                [snapshot removeFromSuperview];
                snapshot = nil;
                
            }];
            break;
        }
    }
}
- (UIView *)customSnapshotFromView:(UIView *)inputView {
    
    // Make an image from the input view.
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Create an image view.
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    
    return snapshot;
}


-(void)showListTopicPopup:(NSString *)mqttId type:(NSInteger)type{
    //    [self.controlPopup showWithDuration:delaInSecond];
    CGRect frame = self.popupContent.view.frame;
    CGFloat heigth = [[CoredataHelper sharedInstance] countController:DeviceTypeLightOnOff] * 50 + 140;
    frame.size = CGSizeMake(screenSize.width - 100, heigth);
    self.popupContent.view.frame = frame;
    [self.popupContent reloadData];
    __weak RoomViewController *wSelf = self;
    [self.controlPopup showAtCenter:CGPointMake(self.view.center.x, self.view.center.y - 150) inView:self.view];
    [self.controlPopup show];
    
    self.popupContent.handleAddControl = ^{
        [wSelf showQRCodeReaderScreen:QRCodeTypeTopic];
        [wSelf.controlPopup dismiss:YES];
        
    };
    self.popupContent.handleSelectControl = ^(Controller * controller) {
        [wSelf addNewDevice:mqttId topic:controller.id type:type];
        [wSelf.controlPopup dismiss:YES];
    };
}
-(void)addNewDevice:(NSString *)mqttID topic:(NSString *)topic type:(NSInteger)type{
    __weak RoomViewController *wSelf = self;
    
    Device *device = [[CoredataHelper sharedInstance] getDeviceByTopic:mqttID type:type];
    if (device) {
        //                [self.room addDevicesObject:device];
        
        [self showAlert:@"" message:@"Thiết bị này đã tồn tại."];
        
    }else{
        [[FirebaseHelper sharedInstance] hasDeviceInSystem:mqttID completion:^(BOOL exist) {
            self.lastQRCode =  nil;
            
            if (exist) {
                [wSelf showAlert:@"Thông báo" message:@"Thiết bị này đã được người khác xử dụng"];
            }else{
                NSInteger deviceId = [[CoredataHelper sharedInstance] countDevice] ;
                //                Device *newDevice = [[CoredataHelper sharedInstance] addNewDevice:@"abc" name:mqttID deviceId:deviceId state:NO value:0 topic:mqttID type:type complete:^(Device *device) {
                //                    if (device) {
                //                        [[FirebaseHelper sharedInstance] addDeviceToSystem:device.requestId];
                //                        [[FirebaseHelper sharedInstance] addDevice:device roomId:self.room.id];
                //                        [[MQTTService sharedInstance] publicRequestStatus:device.requestId];
                //                    }
                //                }];
                Controller *controller = [[CoredataHelper sharedInstance] getControllerById:topic];
                if(!controller){
                    [[CoredataHelper sharedInstance] addNewController:topic name:topic order:0 type:type code:@"" key:@"" complete:^(BOOL complete, Controller *newController) {
                        if (newController) {
                            [[FirebaseHelper sharedInstance] addController:newController];
                        }
                    }];
                }
                Device *newDevice = [[CoredataHelper sharedInstance] addNewDevice:@"" name:@"" deviceId:deviceId topic:topic control:false state:false value:0 mqttId:mqttID type:type order:deviceId complete:^(Device *device) {
                    if (device) {
                        [[FirebaseHelper sharedInstance] addDeviceToSystem:device.requestId];
                        [[FirebaseHelper sharedInstance] addDevice:device roomId:self.room.id];
                        
                    }
                }];
                [wSelf.room addDevicesObject:newDevice];
                [[CoredataHelper sharedInstance] save];
                
                
                //                wSelf.addDevice =  newDevice;
                if (type == DeviceTypeLightOnOff) {
                    [[MQTTService sharedInstance] addMQTTDevice:newDevice];
                    
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    NSLog(@"showInputNameAlert b");
                    [wSelf showInputNameAlert:newDevice];
                    
                    
                    
                });
                
                
                
            }
        }];
    }//end if device is not exist
}

@end

