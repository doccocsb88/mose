//
//  ScenceViewController.m
//  SmartHome
//
//  Created by Apple on 3/30/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import "ScenceViewController.h"
#import "GPUImage.h"
@interface ScenceViewController () <UITableViewDelegate, UITableViewDataSource,UIGestureRecognizerDelegate,ListDeviceDelegate>
{
    NSMutableArray *dataArray;
}
@property (assign, nonatomic) NSInteger selectedIndex;
@property (strong, nonatomic) NSTimer* publishTimer;

@end

@implementation ScenceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadData];
    [self setupNavigator];
    [self setupUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData) name:@"kFirebaseLogout" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData) name:@"kFirebaseRemoveScene" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData) name:@"kFirebasedidFinishSynScene" object:nil];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if ( [[MQTTService sharedInstance] isConnected] == false) {
        if(dataArray.count > 0){
            [self showLoadingView];
        }
        
        [[MQTTService sharedInstance] conect];
    }else{
//        [[MQTTService sharedInstance] setListDevices:dataArray];
    }

}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"kFirebaseLogout" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"kFirebaseRemoveScene" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"kFirebasedidFinishSynScene" object:nil];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)setupNavigator{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 160, 40)];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.text = @"NGỮ CẢNH";
    titleLabel.textColor = [UIColor whiteColor];//[Helper colorFromHexString:@"3fb2b5"];
    titleLabel.font = [UIFont systemFontOfSize:25];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:titleLabel];
    self.navigationItem.leftBarButtonItem = leftItem;
    self.rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    //        [self.rightButton setTitle:@"Add" forState:UIControlStateNormal];
    self.rightButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    [self.rightButton setImage:[UIImage imageNamed:@"ic_add_fav"] forState:UIControlStateNormal];
    self.rightButton.backgroundColor = [UIColor clearColor];
    [self.rightButton addTarget:self action:@selector(pressedAdd:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
 
}
-(void)loadData{
    self.selectedIndex = NSNotFound;
    dataArray = [[[CoredataHelper sharedInstance] getListScene] mutableCopy];
    [self.tableView reloadData];
}

-(void)setupUI{
    self.tableView.alwaysBounceVertical = true;
    // attach long press gesture to collectionView
    UILongPressGestureRecognizer *lpgr
    = [[UILongPressGestureRecognizer alloc]
       initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.delegate = self;
    lpgr.delaysTouchesBegan = YES;
    [self.tableView addGestureRecognizer:lpgr];
    [self initLoadingView];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSString *des = segue.identifier;
    if ([des isEqualToString:@"sceneDetailSegue"]) {
        Scene *scene = [dataArray objectAtIndex:self.selectedIndex];
        SceneDetailViewController *vc = segue.destinationViewController;
        vc.dataArray = [[scene getListSceneDetail] mutableCopy];
        vc.title = scene.name ? scene.name : @"";
        vc.scene = scene;
        NSLog(@"detail: %ld",vc.dataArray.count);
    }
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
    return 100;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray.count;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc] init];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    Scene *scene = [dataArray objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sceneCell" forIndexPath:indexPath];
    UIImageView *thumbnail = [cell viewWithTag:1];
    if (thumbnail != nil){
        
    }
    UILabel *titleName= [cell viewWithTag:2];
    UILabel *numberLabel = [cell viewWithTag:3];
    if (numberLabel != nil) {
        numberLabel.backgroundColor = [UIColor whiteColor];
        numberLabel.layer.cornerRadius = 20;
        numberLabel.layer.masksToBounds = true;
        numberLabel.text = [NSString stringWithFormat:@"%li",scene.sceneDetail.count];
        numberLabel.textColor = [UIColor blackColor];
    }
    titleName.text = scene.name;
    cell.selectionStyle = UITableViewRowActionStyleDefault;
    UIView *bgView = [cell viewWithTag:9];
    if (bgView) {
        bgView.layer.cornerRadius = 10;
        bgView.layer.masksToBounds = YES;
    }
    UIImageView *bgzView = (UIImageView *)[cell viewWithTag:5];
    if (bgzView) {
        UIImage *inputImage = [UIImage imageNamed:@"ic_device_bg"];
        GPUImagePicture *stillImageSource1 = [[GPUImagePicture alloc] initWithImage:inputImage];

        GPUImageMultiplyBlendFilter *blendFilter = [[GPUImageMultiplyBlendFilter alloc] init];
        [stillImageSource1 processImage];
        [stillImageSource1 addTarget:blendFilter];
        [stillImageSource1 processImage];
        UIImage *filteredImage = [blendFilter imageFromCurrentFramebuffer];
        bgzView.image = filteredImage;
        UIImage *xx = [self createDimImage:inputImage];
        bgzView.image = xx;

    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    self.selectedIndex = indexPath.row;
//    [self performSegueWithIdentifier:@"sceneDetailSegue" sender:nil];
    Scene * scene = [dataArray objectAtIndex:indexPath.row];
    [self showLoadingView];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW,[scene getLoadingTime]* NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self hideLoadingView];
    });

    NSInteger index = 0;
    for (SceneDetail *detail in [scene.sceneDetail allObjects]) {
        Device *device = detail.device;
        if([[MQTTService sharedInstance] isSubcribeTopic:device] ==false){
            [[MQTTService sharedInstance] subscribeToTopic:device];
            index++;
        }
    }
    for (SceneDetail *detail in [scene.sceneDetail allObjects]) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, index * 0.5 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //code to be executed on the main queue after delay
            Device *device = detail.device;
            NSInteger value = detail.status;
            if (device.type == DeviceTypeLightOnOff) {
                if (value == ButtonTypeClose) {
                    [[MQTTService sharedInstance] publishControl:device.requestId topic:device.topic message:@"OPEN" type:device.type count:3];
                }else if (value == ButtonTypeStop){
                    //                [self showLoadingView];
                    
                    
                    [[MQTTService sharedInstance] publishControl:device.requestId topic:device.topic message:@"STOP" type:device.type count:3];
                    
                }else if (value == ButtonTypeOpen){
                    //            [self showLoadingView];
                    //            self.isProcessing = true;
                    
                    [[MQTTService sharedInstance] publishControl:device.requestId topic:device.topic message:@"CLOSE" type:device.type count:3];
                    
                }
                
            }else if (device.type == DeviceTypeTouchSwitch){
                NSInteger numberOfChanel = [detail numberOfChanel];
                for (int i = 0; i < numberOfChanel; i++) {
                    NSInteger chanel = [detail getChanelIndex:i];
                    NSString *requestId = device.requestId;
                    NSString *message = [device switchChancelMessage:(int)chanel status:[detail isChanelOn:chanel]];
                    NSInteger type = device.type;
                    NSDictionary *userInfo  = @{@"requestId":requestId,@"topic":device.topic, @"message":message,@"type":@(type)};
                    NSLog(@"tw : 1 : %@",message);
//                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25*i * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                          [[MQTTService sharedInstance] publishControl:device.requestId message:[device switchChancelMessage:i status:[detail isChanelOn:i]] type:device.type count:1];
//                    });
              
                  NSTimer *timer  = [NSTimer scheduledTimerWithTimeInterval:0.25 * i target:self selector:@selector(publishTopic:) userInfo:userInfo repeats:NO];

                }
         
            }else{
                //curtain
                if (value == ButtonTypeClose) {
                    [[MQTTService sharedInstance] publishControl:device.requestId topic:device.topic message:@"CLOSE" type:device.type count:3];
                }else if (value == ButtonTypeStop){
                    //                [self showLoadingView];
                    
                    
                    [[MQTTService sharedInstance] publishControl:device.requestId topic:device.topic message:@"STOP" type:device.type count:3];
                    
                }else if (value == ButtonTypeOpen){
                    //            [self showLoadingView];
                    //            self.isProcessing = true;
                    
                    [[MQTTService sharedInstance] publishControl:device.requestId topic:device.topic message:@"OPEN" type:device.type count:3];
                    
                }
            }
        });
        if ([Utils getDeviceType:detail.device.topic] == DeviceTypeLightOnOff ) {
            index ++;
        }else{
            
        }
        
    }
}

#pragma mark 
-(void)didSelectedDevce:(Device *)device{
    Scene *scene = [dataArray objectAtIndex:self.selectedIndex];
    SceneDetail *detail =[[CoredataHelper sharedInstance] addSceneDetail:1 value:1 status:false device:device complete:^(SceneDetail *detail) {
        if (detail) {
            [[FirebaseHelper sharedInstance] addSceneDetail:detail sceneId:scene.id];
        }
    }];

    if (detail != nil) {
        [scene addSceneDetailObject:detail];
        [[CoredataHelper sharedInstance] save];
        NSLog(@"bbb %li",scene.sceneDetail.count);
    }
    NSArray *zzz = [[CoredataHelper sharedInstance] getAllSceneDetail];
    NSLog(@"aaa %li",zzz.count);

    self.selectedIndex = NSNotFound;
    [self.tableView reloadData];

}
-(void)didSelectedListDevces:(NSArray *)selectedDevices{
    Scene *scene = [dataArray objectAtIndex:self.selectedIndex];
    for (SceneDetail *detail in selectedDevices) {
        if (detail != nil) {
            detail.isSelected = false;
            if(detail.device.type != DeviceTypeTouchSwitch){
                [scene addSceneDetailObject:detail];
                [[FirebaseHelper sharedInstance] addSceneDetail:detail sceneId:scene.id];

            }else{
                SceneDetail *existDetail = [scene getDetailByRequestId:detail.device.requestId];
                if (existDetail) {
                    for (int i = 0; i < [detail numberOfChanel];i++){
                        NSInteger chanel = [detail getChanelIndex:i];
                        [existDetail addSelectedChanel:chanel];
                    }
                    [[FirebaseHelper sharedInstance] updateSceneDetail:existDetail sceneId:scene.id];

                }else{
                    [scene addSceneDetailObject:detail];
                    [[FirebaseHelper sharedInstance] addSceneDetail:detail sceneId:scene.id];

                }
            }
            [[CoredataHelper sharedInstance] save];
            NSLog(@"bbb %li",scene.sceneDetail.count);
        }
        NSArray *zzz = [[CoredataHelper sharedInstance] getAllSceneDetail];
        NSLog(@"aaa %li",zzz.count);

    }
    
    self.selectedIndex = NSNotFound;
    [self.tableView reloadData];
}
-(void)pressedAdd:(UIButton *)sender{
    self.selectedIndex = NSNotFound;
    [self showAddScene];
    
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    CGPoint p = [gestureRecognizer locationInView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    if (indexPath == nil){
        NSLog(@"couldn't find index path");
    } else {
        // get the cell at indexPath (the one you long pressed)
        self.selectedIndex = indexPath.row;
        UITableViewCell* cell =
        [self.tableView cellForRowAtIndexPath:indexPath];
        // do stuff with the cell
        [self showSceneMenu];
    }
}
-(void)showAddScene{
    NSString *title = self.selectedIndex != NSNotFound ? @"Đổi tên ngữ cảnh" : @"Thêm ngữ cảnh";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Nhập tên ngữ cảnh";
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //        <#code#>
        UITextField *tf = alert.textFields.firstObject;
        NSString *roomName = tf.text;
        if (self.selectedIndex == NSNotFound) {
            [[CoredataHelper sharedInstance] addNewScene:[self getMaxScenceId] name:roomName complete:^(Scene *scene) {
                if (scene) {
                    [[FirebaseHelper sharedInstance] addScene:scene];
                }
            }];
        }else{
            Scene *scene = [dataArray objectAtIndex:self.selectedIndex];
            scene.name = roomName;
        }
        [self loadData];
        self.selectedIndex = NSNotFound;
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //        <#code#>
        self.selectedIndex = NSNotFound;

    }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:true completion:nil];
}

-(void)showListDeviceScreen{
    ListDeviceViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ListDeviceViewController"];
    vc.type = 1;
    vc.delegate = self;
    vc.scene = YES;
    Scene *scene = [dataArray objectAtIndex:self.selectedIndex];
//    NSMutableArray *arrs = [[NSMutableArray alloc] init];

    if (scene && scene.sceneDetail) {
        NSArray *arr = [scene.sceneDetail allObjects];
        vc.existDevice = arr;

    }
    [self.navigationController pushViewController:vc animated:true];
}
-(void)showSceneMenu{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *editScenceAction = [UIAlertAction actionWithTitle:@"Cài đặt ngữ cảnh" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //        <#code#>
        //        [self showGalleryController];
        [self performSegueWithIdentifier:@"sceneDetailSegue" sender:nil];
        
    }];
    UIAlertAction *changeIconAction = [UIAlertAction actionWithTitle:@"Thêm thiết bị" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //        <#code#>
//        [self showGalleryController];
        [self showListDeviceScreen];

    }];
    UIAlertAction *changeNameAction = [UIAlertAction actionWithTitle:@"Đổi tên" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //        <#code#>
//        self.selectedIndex = NSNotFound;
        [self showAddScene];

    }];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Xoá" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //        <#code#>
        if (self.selectedIndex < dataArray.count) {
            Scene *scene = [dataArray objectAtIndex:self.selectedIndex];
            [dataArray removeObject:scene];
            for (SceneDetail *detail in [scene.sceneDetail allObjects]){
                [[FirebaseHelper sharedInstance] deleteSceneDetail:detail.code];
                [[CoredataHelper sharedInstance].context deleteObject:detail];

            }
            [[FirebaseHelper sharedInstance] deleteScene:scene.code];
            [[CoredataHelper sharedInstance].context deleteObject:scene];
            self.selectedIndex = NSNotFound;
            [self.tableView reloadData];
        }

    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        //        <#code#>
        self.selectedIndex = NSNotFound;
    }];
    [alert addAction:editScenceAction];
    [alert addAction:cancelAction];
    [alert addAction:changeIconAction];
    [alert addAction:changeNameAction];
    [alert addAction:defaultAction];
    
    [self presentViewController:alert animated:true completion:nil];
}
- (UIImage *)createDimImage:(UIImage *)image; {
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    CGRect imageRect = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // Draw a white background (for white mask)
    CGContextSetRGBFillColor(ctx, 1.0f, 1.0f, 1.0f, 1.0f);
    CGContextFillRect(ctx, imageRect);
    
    // Apply the source image's alpha
    [image drawInRect:imageRect blendMode:kCGBlendModeDestinationIn alpha:0.1f];
    
    UIImage* outImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return outImage;
}

-(void)publishTopic:(NSTimer *)timer{
    NSDictionary *userInfo = timer.userInfo;
    NSString *requestId = [userInfo objectForKey:@"requestId"];
    NSString *topic = [userInfo objectForKey:@"topic"];
    NSString *message = [userInfo objectForKey:@"message"];
    NSInteger type = [[userInfo objectForKey:@"type"] integerValue];
    NSLog(@"tw : 2 : %@",message);
    [[MQTTService sharedInstance] clearPublishTopic:topic];
    [[MQTTService sharedInstance] publishControl:requestId topic:topic message:message  type:type count:3];
    
}

-(NSInteger)getMaxScenceId{
    NSInteger max = dataArray.count;
    for (Scene *scene in dataArray) {
        if (scene.id > max) {
            max = scene.id;
        }
    }
    return max + 1;
}
@end
