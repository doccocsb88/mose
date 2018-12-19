//
//  APPChildViewController.m
//  SmartHome
//
//  Created by Apple on 3/19/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import "APPChildViewController.h"
#import "TypeRoomViewCell.h"
#import "RoomViewController.h"
#import "GalleryViewController.h"
#import "ControlRoomPopup.h"
#import "KLCPopup.h"

@interface APPChildViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate,GalleryDelegate,RoomCellDelegate>
{
    CGSize screenSize;
}
@property (assign, nonatomic) NSInteger selectedIndex;
//@property (strong, nonatomic) UIImageView *backgroundView;
//@property (weak) UIViewController *myPopup;
@property (strong, nonatomic) KLCPopup *controlPopup;
@property (strong, nonatomic) ControlRoomPopup *popupContent;
@end

@implementation APPChildViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];
    [self initData];
    [self setupUI];
    NSLog(@"Roomtype: %ld",(long)_roomtype);
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.collectionView) {
        [self.collectionView reloadData];
    }
}
-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    [self.view layoutIfNeeded];
//    if (size.height < 420) {
//        [UIView animateWithDuration:[coordinator transitionDuration] animations:^{
//            self.popupController.view.bounds = CGRectMake(0, 0, (size.height-20) * .75, size.height-20);
//            [self.view layoutIfNeeded];
//        }];
//    } else {
//        [UIView animateWithDuration:[coordinator transitionDuration] animations:^{
//            self.myPopup.view.bounds = CGRectMake(0, 0, 100, 100);
//            [self.view layoutIfNeeded];
//        }];
//    }
}
-(void)initData{

    screenSize = [UIScreen mainScreen].bounds.size;
   self.popupContent = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"popupController"];
    CGRect frame = self.popupContent.view.frame;
    frame.size = CGSizeMake(100, 100);
    self.popupContent.view.frame = frame;
    self.controlPopup = [KLCPopup popupWithContentView:self.popupContent.view showType:KLCPopupShowTypeGrowIn dismissType:KLCPopupDismissTypeGrowOut maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    
}
-(void)setupUI{
    [self.collectionView registerNib:[UINib nibWithNibName:@"TypeRoomViewCell" bundle:nil] forCellWithReuseIdentifier:@"TypeRoomViewCell"];
    self.collectionView.contentInset = UIEdgeInsetsMake(5, 5, 5, 5);
    if (_roomtype == 1) {
        //if this is childroom
        self.navigationItem.title = _roomname;
    }
    // attach long press gesture to collectionView
    UILongPressGestureRecognizer *lpgr
    = [[UILongPressGestureRecognizer alloc]
       initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.delegate = self;
    lpgr.delaysTouchesBegan = YES;
    [self.collectionView addGestureRecognizer:lpgr];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataArray.count;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = (screenSize.width - 40 )/3;
    CGFloat height = (screenSize.height - 114 - 90) / 4;
//    width = width ? height ?
//    width =  height > width ? width : height;
    return CGSizeMake(width, width);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"TypeRoomViewCell";
    
    TypeRoomViewCell *cell = (TypeRoomViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    Room *room = [_dataArray objectAtIndex:indexPath.row];
    cell.delegate = self;
    [cell setContentView:room];
//    cell.thumbnail.image = [UIImage imageNamed:[NSString stringWithFormat:@"ic_room_%ld",indexPath.row]];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([MQTTService sharedInstance].isConnect == false) {
        return;
    }
//    if (_roomtype == 0){
//        //open child room
//        Room *room  = [_dataArray objectAtIndex:indexPath.row];
//        [self openChildroomController:room.name];
//    }else if (_roomtype == 1){
            Room *room  = [_dataArray objectAtIndex:indexPath.row];

        [self openroomDetailController:room];
//    }
}
-(void)reloadData:(NSArray *)data{
    NSLog(@"___ %ld",_dataArray.count);
    self.dataArray = [[NSMutableArray alloc] initWithArray:data];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
    NSLog(@"___+++++ %ld",_dataArray.count);

}
-(void)reloadData{
    [self.collectionView reloadData];
}
-(void)openChildroomController:(NSString *)roomName{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PageContentViewController *vc =  [storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
    vc.roomtype = 1;
    vc.roomname = roomName;
    [self.navController pushViewController:vc animated:YES];
}
-(void)openroomDetailController:(Room *)room{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RoomViewController *vc =  [storyboard instantiateViewControllerWithIdentifier:@"RoomViewController"];
    vc.hidesBottomBarWhenPushed = YES;
    vc.room = room;
    [self.navController pushViewController:vc animated:YES];

}

-(void)showEditRoomMenu{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *changeIconAction = [UIAlertAction actionWithTitle:@"Thay đổi biểu tượng" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        <#code#>
        [self showGalleryController];
    }];
    UIAlertAction *changeNameAction = [UIAlertAction actionWithTitle:@"Thay đổi tên" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //        <#code#>
        [self showChangeRoomName];
    }];

    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Xoá phòng" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //        <#code#>
        [self showDeleteRoomConfirm];
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Bỏ qua" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        //        <#code#>
    }];
    [alert addAction:cancelAction];
    [alert addAction:changeIconAction];
    [alert addAction:changeNameAction];
    [alert addAction:defaultAction];

    [self presentViewController:alert animated:true completion:nil];
}
//
-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
    CGPoint p = [gestureRecognizer locationInView:self.collectionView];
    
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:p];
    if (indexPath == nil){
        NSLog(@"couldn't find index path");
    } else {
        // get the cell at indexPath (the one you long pressed)
        self.selectedIndex = indexPath.row;
        UICollectionViewCell* cell =
        [self.collectionView cellForItemAtIndexPath:indexPath];
        // do stuff with the cell
        [self showEditRoomMenu];
    }
}
-(void)showChangeRoomName{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Đổi tên phòng" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Nhập tên phòng";
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Đồng ý" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //        <#code#>
        UITextField *tf = alert.textFields.firstObject;
        NSString *roomName = tf.text;
        if (roomName && roomName.length > 0) {
            if (self.selectedIndex != NSNotFound && self.selectedIndex < self.dataArray.count){
                Room *room = [_dataArray objectAtIndex:self.selectedIndex];
                room.name = roomName;
                [[CoredataHelper sharedInstance] save];
                [[FirebaseHelper sharedInstance] updateRoom:room];
                [self.collectionView reloadData];
            }
        }else{
            //
        }
       
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Bỏ qua" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //        <#code#>
    }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:true completion:nil];
    
}

-(void)showDeleteRoomConfirm{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Xoá phòng" message:@"Bạn có muốn xoá phòng này không?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Đồng ý" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //        <#code#>
            if (self.selectedIndex != NSNotFound && self.selectedIndex < self.dataArray.count){
                Room *room = [_dataArray objectAtIndex:self.selectedIndex];
//                [[CoredataHelper sharedInstance] deleteRoom:room];
//                [[CoredataHelper sharedInstance] save];
                NSString *roomCode = room.code;
                for (Device *device in [room.devices allObjects]) {
                    [[FirebaseHelper sharedInstance] delleteDevice:device.key];
                    [[FirebaseHelper sharedInstance] delleteDeviceInSystem:device.requestId];
                }
                [[FirebaseHelper sharedInstance] deleteRoom:roomCode];
                [[CoredataHelper sharedInstance] deleteRoom:room];
            }
        
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Bỏ qua" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //        <#code#>
    }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:true completion:nil];

}

-(void)showGalleryController{
    GalleryViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"GalleryViewController"];
    vc.delegate = self;
    vc.room = [_dataArray objectAtIndex:self.selectedIndex];
    [self.navController pushViewController:vc animated:true];
}
#pragma mark - GalleryDelegate
-(void)didChangeThumbnail{
    [self.collectionView reloadData];
}
    
#pragma mark - HTKDraggableCollectionViewCellDelegate
    
- (BOOL)userCanDragCell:(UICollectionViewCell *)cell {
    // All cells can be dragged in this demo
    return YES;
}
    
- (void)userDidEndDraggingCell:(UICollectionViewCell *)cell {
    
    HTKDragAndDropCollectionViewLayout *flowLayout = (HTKDragAndDropCollectionViewLayout *)self.collectionView.collectionViewLayout;
    
    // Save our dragging changes if needed
    if (flowLayout.finalIndexPath != nil) {
        // Update datasource
        NSObject *objectToMove = [self.dataArray objectAtIndex:flowLayout.draggedIndexPath.row];
        [self.dataArray removeObjectAtIndex:flowLayout.draggedIndexPath.row];
        [self.dataArray insertObject:objectToMove atIndex:flowLayout.finalIndexPath.row];
    }
    
    // Reset
    [flowLayout resetDragging];
}

-(void)didControlRoom:(NSInteger)roomId status:(BOOL)turnOn{

    if (turnOn) {
        self.popupContent.thumbView.image = [UIImage imageNamed:@"ic_light_gray"];
        [self turnOnAllDeviceInRoo:roomId];

    }else{
        self.popupContent.thumbView.image = [UIImage imageNamed:@"ic_light"];
        [self turnOffAllDeviceInRoo:roomId];
    }
//    popup.presentedController = presentingController;
//    popup.presentingController = self;
    CGFloat delaInSecond  = 2;
    Room *room  = [Utils getRoomWithId:roomId in:self.dataArray];
    if (room) {
        delaInSecond = [room countAutocontrolDevice];
        delaInSecond = delaInSecond <= 2 ? delaInSecond : 2;
//        delaInSecond = 2;
        if ([room.devices allObjects].count > 0) {
            [self.controlPopup showWithDuration:delaInSecond];
            [self.controlPopup showAtCenter:self.view.center inView:self.view];
            [self.controlPopup show];

//            self.myPopup = presentingController;
//            [self presentViewController:presentingController animated:YES completion:nil];
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delaInSecond * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self.collectionView reloadData];
//                [self.myPopup dismissViewControllerAnimated:YES completion:nil];
            });
        }
    }
  
  
}
-(void)turnOnAllDeviceInRoo:(NSInteger )roomId{
    
    for (Room *room in _dataArray) {
        if (room.id == roomId ) {
            NSInteger index = 0;
            //            [[MQTTService sharedInstance] setListDevices:[room.devices allObjects]];
            for (Device *device in [room.devices allObjects]) {
                if ([device numberOfSwitchChannel] > 0) {
                    for (int i = 1; i <= [device numberOfSwitchChannel]; i++) {
                        double delayInSeconds = index * 0.5;
                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                        
                        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                            
                            [[MQTTService sharedInstance] publishControl:device.requestId topic:device.topic message:[device switchChancelMessage:(int)i status:false] type:device.type count:0 complete:^(BOOL finished) {
                                
                            }];
                        });
                        index ++;
                    }
                }else{
                    double delayInSeconds = index * 0.5;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        //code to be executed on the main queue after delay
                        [[MQTTService sharedInstance] publishControl:device.requestId topic:device.topic message:@"CLOSE" type:device.type count:1 complete:^(BOOL finished) {
                            
                        }];
                    });
                    index ++;
                }
//                NSLog(@"delayInSeconds %f",delayInSeconds);
                
            }
            break;
        }
    }

}
-(void)turnOffAllDeviceInRoo:(NSInteger )roomId{
    for (Room *room in _dataArray) {
        if (room.id ==roomId ) {
            NSInteger index = 0;
            NSMutableArray *arrs = [[NSMutableArray alloc] init];
            for (Device *device in [room.devices allObjects]) {
                if (device.type == DeviceTypeTouchSwitch){
                    [arrs addObject:device];
                }else{
                    if (device.control) {
                        [arrs addObject:device];
                    }
                }
            }
            //            [[MQTTService sharedInstance] setListDevices:arrs];
            index = 0;
            for (Device *device in arrs) {
                if (device.type == DeviceTypeTouchSwitch) {
                    for (int i = 1; i <= [device numberOfSwitchChannel]; i++) {
                        if ([device isAutoControl:i]) {
                            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, index * 0.5 * NSEC_PER_SEC);
                            
                            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                
                                [[MQTTService sharedInstance] publishControl:device.requestId topic:device.topic message:[device switchChancelMessage:(int)i status:true] type:device.type count:0 complete:^(BOOL finished) {
                                    
                                }];
                            });
                            index ++;
                        }
                       
                    }
                }else{
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, index * 0.5 * NSEC_PER_SEC);
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        
                        [[MQTTService sharedInstance] publishControl:device.requestId topic:device.topic message:@"OPEN" type:device.type count:1 complete:^(BOOL finished) {
                            
                        }];
                    });
                    index ++;

                }
            }
            break;
        }
    }
}
@end
