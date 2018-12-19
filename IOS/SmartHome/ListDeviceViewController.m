//
//  ListDeviceViewController.m
//  SmartHome
//
//  Created by Apple on 3/26/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import "ListDeviceViewController.h"
#import "CoredataHelper.h"
#import "Device.h"
#import "BaseViewCell.h"
@interface ListDeviceViewController ()<UITableViewDataSource, UITableViewDelegate,UIGestureRecognizerDelegate,DeviceCellDelegate,EditDeviceDelegate,MQTTServiceDelegate>
{
    NSMutableArray *typeArr;
    NSMutableArray *dataArray;
    NSMutableArray *roomArray;

    CGSize screenSize;
    NSMutableArray *selectedArray;
}
@property (strong, nonatomic) UIButton *saveButton;
@property (assign, nonatomic) NSInteger selectedIndex;
@property (assign, nonatomic) NSInteger numberOfType;

@property (assign, nonatomic) NSInteger chanel;
@property (strong, nonatomic) NSMutableArray *timerArray;

@end

@implementation ListDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initData];
    [self setupUI];
    self.activityIndicatorView = [[SCSkypeActivityIndicatorView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - LOADING_SIZE)/2, (self.view.frame.size.height - LOADING_SIZE)/2 - 64, LOADING_SIZE, LOADING_SIZE)];
    self.activityIndicatorView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    self.activityIndicatorView.layer.cornerRadius = LOADING_SIZE * 0.5;
    self.activityIndicatorView.layer.masksToBounds = true;
    self.activityIndicatorView.hidden = YES;
    [self.view addSubview:self.activityIndicatorView];
    if (self.scene == false) {
        
        [MQTTService sharedInstance].delegate = self;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.scene) {
        NSArray *arrs = [dataArray copy];
        for (SceneDetail *dt in self.existDevice) {
            for (SceneDetail *detail in arrs) {
                if (dt.device.id == detail.device.id) {
                    if (dt.device.type != DeviceTypeTouchSwitch) {
                        [dataArray removeObject:detail];
                    }else{
                        if ([detail.device numberOfSwitchChannel] == [dt numberOfChanel]) {
                            [dataArray removeObject:detail];
                        }
                    }
                }
            }
        }
        [self.tableView reloadData];
        
    }
    if (self.scene == false) {
        if ( [[MQTTService sharedInstance] isConnected] == false) {
            [self showLoadingView];
            
            [[MQTTService sharedInstance] conect];
        }else{
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
        [self.tableView reloadData];

    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self hideLoadingView];
}
-(void)initData{
    selectedArray = [[NSMutableArray alloc] init];
    screenSize = [UIScreen mainScreen].bounds.size;
    typeArr = [[NSMutableArray alloc] init];
    if (self.scene) {
        NSArray *arrs = [[CoredataHelper sharedInstance] getListRoom];
        roomArray = [[NSMutableArray alloc] init];
        dataArray = [[NSMutableArray alloc] init];
            for (Room *room in arrs) {
                if ([self numberOfAvailableDevice:room.devices.allObjects] > 0) {
                    [roomArray addObject:room];
                }
            }
            for (Room *room in roomArray) {
                NSSortDescriptor *imageSort = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:NO];
                NSArray *allDevices =  [[[room.devices allObjects] sortedArrayUsingDescriptors:@[imageSort]] mutableCopy];
                
                for (Device *device in allDevices) {
                 
                    if ([[User sharedInstance] isAdmin]) {
                        SceneDetail *detail =[[CoredataHelper sharedInstance] addSceneDetail:1 value:1 status:ButtonTypeOpen device:device complete:^(SceneDetail *detail) {
                            if (detail) {
                                
                            }
                        }];
                        detail.value = 0;
                        detail.status = ButtonTypeOpen;
                        [dataArray addObject:detail];
                    }else{
                        if ([[User sharedInstance] isShared] ) {
                            if (device.type == DeviceTypeTouchSwitch) {
                                for (int i = 1 ; i <= [device numberOfSwitchChannel]; i++) {
                                    NSString *requestId = [NSString stringWithFormat:@"%@/%d",device.requestId,i];
                                    if ([[User sharedInstance].devices containsObject:requestId]) {
                                        SceneDetail *detail = [[CoredataHelper sharedInstance] addSceneDetail:1 value:1 status:ButtonTypeOpen device:device complete:^(SceneDetail *detail) {
                                            if (detail) {
                                                
                                            }
                                        }];
                                        detail.value = 0;
                                        detail.status = ButtonTypeOpen;
                                        [dataArray addObject:detail];
                                        break;
                                    }
                                    
                                }
                            }else{
                                if ([[User sharedInstance].devices containsObject:device.requestId]) {
                                    SceneDetail *detail = [[CoredataHelper sharedInstance] addSceneDetail:1 value:1 status:ButtonTypeOpen device:device complete:^(SceneDetail *detail) {
                                        if (detail) {
                                            
                                        }
                                    }];
                                    detail.value = 0;
                                    detail.status = ButtonTypeOpen;
                                    [dataArray addObject:detail];
                                }
                            }
                            
                            

                        }
                    }
                }
            }
      
    }else{
        NSArray *arrs = [[CoredataHelper sharedInstance] getListRoom];
        dataArray = [[NSMutableArray alloc] init];
        if ([[User sharedInstance] isAdmin]) {
            for (Room *room in arrs) {
                if ([self numberOfAvailableDevice:room.devices.allObjects] > 0) {
                    [dataArray addObject:room];
                }
            }
            for (Room *room in dataArray) {
                for (Device *device in room.devices.allObjects) {
                    NSString *type = [NSString stringWithFormat:@"%ld",device.type];
                    if ([typeArr containsObject:type] == false) {
                        [typeArr addObject:type];
                    }
                }
                
            }
        }else{
        if([User sharedInstance].isShared){
            for (Room *room in arrs) {
                if ([self numberOfAvailableDevice:room.devices.allObjects] > 0) {
                    if ([room getSharedDevices].count > 0){
                        [dataArray addObject:room];
                    }
                }
            }
            for (Room *room in dataArray) {
                for (Device *device in room.devices.allObjects) {
                    NSString *type = [NSString stringWithFormat:@"%ld",device.type];
                    if ([typeArr containsObject:type] == false) {
                        [typeArr addObject:type];
                    }
                }
                
            }
        }
        }
    }
    
    
}
-(void)setupNavigator{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.text = @"THIẾT BỊ";
    titleLabel.textColor = [UIColor whiteColor];//[Helper colorFromHexString:@"3fb2b5"];
    titleLabel.font = [UIFont systemFontOfSize:25];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:titleLabel];
    self.navigationItem.leftBarButtonItem = leftItem;
    if (self.scene) {
        self.saveButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 40)];
        [self.saveButton setTitle:@"Quay về" forState:UIControlStateNormal];
        self.saveButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;

        [ self.saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [ self.saveButton addTarget:self action:@selector(pressedRight:) forControlEvents:UIControlEventTouchUpInside];
//         self.saveButton.layer.cornerRadius = 3.0;
//         self.saveButton.layer.borderWidth = 1.0;
//         self.saveButton.layer.borderColor = [UIColor whiteColor].CGColor;
//         self.saveButton.layer.masksToBounds = YES;
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView: self.saveButton];
        self.navigationItem.rightBarButtonItem = rightItem;
        
    }
}
-(void)setupUI{
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"LightViewCell" bundle:nil] forCellReuseIdentifier:@"lightViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"LightOnOffViewCell" bundle:nil] forCellReuseIdentifier:@"lightOnOffViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"RemViewCell" bundle:nil] forCellReuseIdentifier:@"remViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TouchSwitchViewCell" bundle:nil] forCellReuseIdentifier:@"TouchSwitchViewCell"];

    
    [self setupNavigator];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 2.0; //seconds
    lpgr.delegate = self;
    [self.tableView addGestureRecognizer:lpgr];
}
-(CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    Device *device;
    SceneDetail *detail = nil;
    
    if (self.scene) {
        NSInteger selectedIndex =  0;
        for (NSInteger index =  0; index < indexPath.section ; index++) {
            selectedIndex = selectedIndex + [self tableView:tableView numberOfRowsInSection:index];
        }
        
        detail = [dataArray objectAtIndex:selectedIndex + indexPath.row];

        device = detail.device;
    }else{
        Room *room = [dataArray objectAtIndex:indexPath.section];
//        NSSortDescriptor *imageSort = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:NO];
//        NSArray *devices = [room.devices.allObjects sortedArrayUsingDescriptors:@[imageSort]];
        NSArray *devices  = [self getSharedDevice:room];
        device = [devices objectAtIndex:indexPath.row];
    }
    if (device.type == DeviceTypeLightOnOff) {
        return 100.0;
    }else if (device.type == DeviceTypeCurtain){
        return 140.0;
    }else if (device.type == DeviceTypeTouchSwitch){
        return 110 * [device numberofSharedChanel] + 30;
    }
    return 100;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (!self.scene) {
        if (dataArray) {
            return dataArray.count;
        }
        return 0;
    }else{
        if (roomArray) {
            
            return roomArray.count;
        }
        return 0;
    }
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (dataArray == nil){
        return 0;
    }
     if (!self.scene) {
        if ([dataArray objectAtIndex:section]) {
            Room *room = [dataArray objectAtIndex:section];
            return [self getSharedDevice:room].count;
        }else{
            return 0;
        }
     }else{
         if (roomArray) {
             Room *room = [roomArray objectAtIndex:section];
             return [self numberOfAvailableDevice:[self getSharedDevice:room]];
         }
         return 0;
     }
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    Room *room = nil;

    if (!self.scene) {
        room = [dataArray objectAtIndex:section];
      
    }else{
        room = [roomArray objectAtIndex:section];
    }
    if (room && [self getSharedDevice:room] > 0) {
        return 30.0;
    }
    return 00.0;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    Room *room = nil;

    if (!self.scene) {
        
        room = [dataArray objectAtIndex:section];
    }else{
        room = [roomArray objectAtIndex:section];
        
    }
    if (room && room.devices.allObjects.count > 0) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
        UILabel *lbRoomName = [[UILabel alloc] initWithFrame:CGRectMake(20, 2, self.view.frame.size.width - 40, 30 - 2)];
        lbRoomName.textAlignment = NSTextAlignmentLeft;
        lbRoomName.textColor = [UIColor whiteColor];
        lbRoomName.text = room.name;
        [headerView addSubview:lbRoomName];
        headerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1];
        return headerView;
        
    }
    
    return [UIView new];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    Device *device;
    SceneDetail *detail;
    if (self.scene) {
        NSInteger selectedIndex =  0;
        for (NSInteger index =  0; index < indexPath.section; index++) {
            selectedIndex = selectedIndex + [self tableView:tableView numberOfRowsInSection:index];
        }

        detail = [dataArray objectAtIndex:selectedIndex + indexPath.row];

        device = detail.device;
    }else{
        Room *room = [dataArray objectAtIndex:indexPath.section];
        NSArray *devicesInRoom = [self getSharedDevice:room];
        NSSortDescriptor *imageSort = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:NO];
        NSArray *devices = [devicesInRoom sortedArrayUsingDescriptors:@[imageSort]];
        device = [devices objectAtIndex:indexPath.row];
    }
    if(device.type  == DeviceTypeLightAdjust){
        LightValueViewCell *cell = (LightValueViewCell *)[tableView dequeueReusableCellWithIdentifier:@"lightViewCell" forIndexPath:indexPath];
        UIView *bg = [cell viewWithTag:1];
        bg.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewRowActionStyleDefault;
        if (self.scene) {
            //            cell setcontent
        }else{
            [cell setContentView:device type:self.scene? 1 : 0];
        }
        cell.delegate = self;
        return cell;
    }else if (device.type == DeviceTypeLightOnOff){
        LightStateViewCell *cell = (LightStateViewCell *)[tableView dequeueReusableCellWithIdentifier:@"lightOnOffViewCell" forIndexPath:indexPath];
        UIView *bg = [cell viewWithTag:1];
        bg.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewRowActionStyleDefault;
        if (self.scene) {
            
            [cell setContentView:detail];
        }else{
            [cell setContentView:device type:self.scene? 1 : 0 ];
        }
        cell.delegate = self;
        return cell;
        
    }else if (device.type == DeviceTypeTouchSwitch){
        TouchSwitchViewCell *cell = (TouchSwitchViewCell *)[tableView dequeueReusableCellWithIdentifier:@"TouchSwitchViewCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewRowActionStyleDefault;
        __weak ListDeviceViewController *wSelf = self;
        __weak TouchSwitchViewCell *wCell = cell;
        if (self.scene) {
            [cell setContentView:detail];
            cell.completionHandler = ^(NSString *value, NSInteger chanel) {
                detail.value = [value floatValue];
                [[CoredataHelper sharedInstance] save];
                [wSelf.tableView reloadData];
            };
            cell.handleSelectChanel = ^(NSInteger chanel) {
                NSLog(@"select chanel :%ld :  %d",chanel,[detail isChanelSelected:chanel]);
                if ([detail isChanelSelected:chanel]) {
                    if ([selectedArray containsObject:detail] == false) {
                        [selectedArray addObject:detail];
                    }
                }else{
                    if ([detail hasSelectedDevicel] == false) {
                        [selectedArray removeObject:detail];
                    }
                }
                detail.isSelected = [detail hasSelectedDevicel];
                [wSelf handleAddDeviceToSceneDetail:indexPath];

            };
        }else{
            cell.isLoading = self.isProcessing;
            [cell setContentView:device type:self.scene? 1 : 0 ];
            cell.controlHandler = ^{
                wSelf.isProcessing = true;
                wCell.isLoading = true;
                [wSelf showLoadingView];
            };
        }
  
        return cell;
    }else if(device.type == DeviceTypeCurtain){
        RemViewCell *cell = (RemViewCell *)[tableView dequeueReusableCellWithIdentifier:@"remViewCell" forIndexPath:indexPath];
        UIView *bg = [cell viewWithTag:1];
        bg.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewRowActionStyleDefault;
        if (self.scene) {
            [cell setContentView:detail];
            
        }else{
            [cell setContentView:device type:self.scene? 1 : 0 ];
        }
        cell.delegate = self;
        
        return cell;
    }else{
        return [UITableViewCell new];
        
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.scene) {
        NSInteger selectedIndex =  0;
        for (NSInteger index =  0; index < indexPath.section ; index++) {
            selectedIndex = selectedIndex + [self tableView:tableView numberOfRowsInSection:index];
        }
        SceneDetail *detail = [dataArray objectAtIndex:selectedIndex + indexPath.row];
        if (detail.device.isOnline) {
            detail.isSelected = !detail.isSelected;
            if (detail.isSelected) {
                [selectedArray addObject:detail];
            }else{
                [selectedArray removeObject:detail];
            }
            [self handleAddDeviceToSceneDetail:indexPath];
        }
    }
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

-(void)handleAddDeviceToSceneDetail:(NSIndexPath *)indexPath{
    if (self.saveButton) {
        if (selectedArray && selectedArray.count > 0) {
            [self.saveButton setTitle:@"Lưu" forState:UIControlStateNormal];
        }else{
            [self.saveButton setTitle:@"Quay về" forState:UIControlStateNormal];
            
        }
    }
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

-(NSArray *)getSharedDevice:(Room *)room{
    NSMutableArray *sharedDevices = [NSMutableArray new];
    
    
    NSSortDescriptor *imageSort = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:NO];
    NSArray *sortedDevices = [room.devices.allObjects sortedArrayUsingDescriptors:@[imageSort]];
    if ([[User sharedInstance] isAdmin]) {
        return sortedDevices;
    }else{
        if ([[User sharedInstance] isShared]) {
            for (Device *device in sortedDevices) {
                if (device.type == DeviceTypeTouchSwitch) {
                    for (int i = 1; i <= [device numberOfSwitchChannel]; i++) {
                        NSString *requestId = [NSString stringWithFormat:@"%@/%d",device.requestId,i];
                        if ([[User sharedInstance].devices containsObject:requestId]) {
                            [sharedDevices addObject:device];
                            break;
                        }
                    }
                }else{
                    if ([[User sharedInstance].devices containsObject:device.requestId]) {
                        [sharedDevices addObject:device];
                    }
                }
            }
        }
        return sharedDevices;

    }
}
#pragma mark
#pragma mark - EdidMenuDelegate
-(void)selectMenuAtIndex:(NSInteger)index{
    Device *device = [dataArray objectAtIndex:self.selectedIndex];
    
    switch (index) {
        case 0:
            //heng io
            break;
        case 1:
            //khoa thiet bi
            break;
        case 2:
            //thay bieu tuong
            break;
        case 3:
            //thong tin thiet bi
            break;
        case 4:
            //xoa thiet bi
            [[CoredataHelper sharedInstance] deleteDevice:device];
            [dataArray removeObject:device];
            [self.tableView reloadData];
            break;
        case 5:
            
            break;
        case 6:
            
            break;
        default:
            break;
    }
}
-(NSInteger)numberOfAvailableDevice:(NSArray *)arrs{
    NSInteger count = 0;
    for (SceneDetail *dt in self.existDevice) {
        for (Device *detail in arrs) {
            if (dt.device.id == detail.id) {
                count  ++;
            }
        }
    }
    return arrs.count - count;
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    if (indexPath == nil) {
        NSLog(@"long press on table view but not on a row");
    } else if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"long press on table view at row %ld", indexPath.row);
        self.selectedIndex = indexPath.row;
        [self showEditDeviceMenu];
    } else {
        NSLog(@"gestureRecognizer.state = %ld", gestureRecognizer.state);
    }
}

-(void)showEditDeviceMenu{
    EditDeviceMenuViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"EditDeviceMenuViewController"];
    vc.delegate = self;
    [self presentViewController:vc animated:true completion:nil];
}

-(void)pressedRight:(UIButton *)button{
    if (selectedArray && selectedArray.count > 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectedListDevces:)]) {
            for (SceneDetail *detail in dataArray) {
                if (detail.isSelected == false) {
                    [[CoredataHelper sharedInstance] deleteDetail:detail];
                }
            }
            [self.delegate didSelectedListDevces:selectedArray];
        }
    }
    [self.navigationController popViewControllerAnimated:true];

    
}
-(void)setStateValueForDevice:(NSString *)topic value:(float)value{
    if (!self.scene) {
        for (Room *room in dataArray) {
            for (Device *device in room.devices.allObjects) {
                if ([topic containsString:device.requestId]) {
                    device.value = value;
                    [[CoredataHelper sharedInstance] save];
                    [self.tableView reloadData];
                    break;
                    
                }
            }
        }
        
    }
    
}
-(void)setStateValueForLight:(NSString *)message{
    if ([message containsString:@"value"]) {
        NSArray *tmp = [message componentsSeparatedByString:@"'"];
        if (!self.scene) {
            for (Room *room in dataArray) {
                for (Device *device in room.devices.allObjects) {
                    //            device.value = value;
                    NSString *_id = tmp[1];
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
        
        
    }
}

#pragma mark
-(void)didChangeCellState:(NSInteger)deviceId value:(BOOL)value{
    if (!self.scene) {
        for (int i = 0; i < dataArray.count; i++) {
            Device *device = [dataArray objectAtIndex:i];
            if (device.id == deviceId) {
                device.state = value;
                break;
            }
        }
        [[CoredataHelper sharedInstance] save];
    }
}
-(void)didChangeCell:(NSInteger)deviceId value:(CGFloat)value{
    if (self.scene == false){
        for (Room *room in dataArray) {
            for (int i = 0; i < room.devices.allObjects.count; i++) {
                Device *device = [room.devices.allObjects objectAtIndex:i];
                if (device.id == deviceId) {
                    device.value = value;
                    [self showLoadingView];
                    [[MQTTService sharedInstance] publishControl:device.requestId topic:device.topic message:[NSString stringWithFormat:@"%f",value] type:device.type count:1 complete:^(BOOL finished) {
                        
                    }] ;
                    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(hideLoadingView) userInfo:nil repeats:false];
                    break;
                }
            }
        }
        
        [[CoredataHelper sharedInstance] save];
    }
}

-(void)didPressedButton:(NSInteger)deviceId value:(ButtonType)value{
    
    if (self.scene) {
        for (int i = 0; i < dataArray.count; i++) {
            SceneDetail *detail = [dataArray objectAtIndex:i];
            if (detail.device.id == deviceId) {
                detail.status = value;
                [self.tableView reloadData];
                break;
            }
        }
    }else{
        if (self.isProcessing) {
            return;
        }
        for (Room *room in dataArray) {
 
            for (int i = 0; i < room.devices.allObjects.count; i++) {
                Device *device = [room.devices.allObjects objectAtIndex:i];
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
                    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(hideLoadingView) userInfo:nil repeats:false];

                    break;
                }
            }
        }
    }
}

-(void)mqttConnected{
    [self.activityIndicatorView stopAnimating];
    self.activityIndicatorView.hidden = YES;
    self.isProcessing = false;
    if (!self.scene) {
        NSMutableArray *allDevice = [NSMutableArray new];
        for (Room *room in dataArray) {
            for (Device *device in room.devices.allObjects) {
                [allDevice addObject:device];
            }
        }
        [[MQTTService sharedInstance] setListDevices:allDevice];
    }
   
    
}

-(void)mqttDisConnect{
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state == UIApplicationStateActive) {
        if (_retry == 0 ) {
            
            _retry = 1;
            [[MQTTService sharedInstance] conect];
        }else{
            [[MQTTService sharedInstance] removeListDevices:dataArray];
            [self hideLoadingView];
            [self showMessageView:@"" message:@"Không có kết nối mạng" autoHide:false complete:^(NSInteger index) {
                if (index == 1) {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
        }
        
    }
}
-(void)requestStatusDeviceInRoom:(NSTimer *)timer{
    NSArray *devices = timer.userInfo;
    NSLog(@"requestStatusDeviceInRoom : %ld",devices.count);
    [[MQTTService sharedInstance] setListDevices:devices];
    
    
}

-(void)mqttFinishedProcess{
    self.isProcessing = false;
    [self hideLoadingView];
}


-(void)mqttPublishFail:(NSString *)topic{
    [self hideLoadingView];
    self.isProcessing = false;
    if (topic != NULL && topic.length > 0) {
        [self showMessageView:nil message:@"Thiết bị không phản hổi" autoHide:YES complete:nil];
    }
    [self.tableView reloadData];
    
}
-(void)mqttRequested:(NSString *)mqttId{
    [self hideLoadingView];
    self.isProcessing = false;

}
-(void)mqttSetStateValueForDevice:(NSString *)topic value:(float)value{
    self.isProcessing = false;
    
//    [self setStateValueForDevice:topic value:value];
    [self hideLoadingView];
    [self.tableView reloadData];
    
}
-(void)mqttSetStateValueForLight:(NSString *)message{
    self.isProcessing = false;
    
//    [self setStateValueForLight:message];
    [self hideLoadingView];
    [self.tableView reloadData];

}
-(void)appWillResignActive:(NSNotification*)note
{
    NSLog(@"appWillResignActive");
    for (NSTimer *timer in _timerArray) {
        [timer invalidate];
    }
    [[MQTTService sharedInstance] disconect];
}
-(void)appWillTerminate:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
}

@end
