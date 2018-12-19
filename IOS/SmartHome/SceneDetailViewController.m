//
//  SceneDetailViewController.m
//  SmartHome
//
//  Created by Apple on 4/6/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import "SceneDetailViewController.h"

@interface SceneDetailViewController () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate,DeviceCellDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (assign, nonatomic) NSInteger selectedIndex;
@end

@implementation SceneDetailViewController
@synthesize dataArray;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupNavigator];
    [self setupUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backtoPrevious) name:@"kFirebaseLogout" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backtoPrevious) name:@"kFirebaseRemoveSceneDetail" object:nil];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"kFirebaseLogout" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"kFirebaseRemoveSceneDetail" object:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[CoredataHelper sharedInstance] save];

}
-(void)setupNavigator{
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

    self.navigationItem.title = self.title;
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    //[self.navigationController.navigationBar setTitleTextAttributes:
    // @{NSForegroundColorAttributeName:[Helper colorFromHexString:@"3fb2b5"]}];
    

}
-(void)setupUI{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 114)];
    self.tableView .delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone       ;
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
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.alwaysBounceVertical = true;
    
    [self.view addSubview:self.tableView];
    
}
-(CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    SceneDetail *detail = [dataArray objectAtIndex:indexPath.row];
    Device *device = detail.device;
    if (device.type == DeviceTypeLightOnOff) {
        return 100.0;
    }else if (device.type == DeviceTypeCurtain){
        return 140.0;
    }else if (device.type == DeviceTypeTouchSwitch){
        return 110 * [detail numberOfChanel] + 30;
    }
    return 100.0;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (dataArray == nil){
        return 0;
    }
    return [dataArray count];
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc] init];
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc] init];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SceneDetail *detail = [dataArray objectAtIndex:indexPath.row];
    Device *device = detail.device;
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
        [cell setContentView:detail];
        cell.delegate = self;
        return cell;
        
    }else if(device.type == DeviceTypeCurtain){
        RemViewCell *cell = (RemViewCell *)[tableView dequeueReusableCellWithIdentifier:@"remViewCell" forIndexPath:indexPath];
        UIView *bg = [cell viewWithTag:1];
        bg.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewRowActionStyleDefault;
        [cell setContentView:detail];
        cell.delegate = self;
        return cell;
        
    }else if (device.type == DeviceTypeTouchSwitch){
        TouchSwitchViewCell *cell = (TouchSwitchViewCell *)[tableView dequeueReusableCellWithIdentifier:@"TouchSwitchViewCell" forIndexPath:indexPath];
        cell.isEdit = true;
        [cell setContentView:detail];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.completionHandler = ^(NSString *value, NSInteger chanel) {
            detail.value = [value floatValue];
            [[CoredataHelper sharedInstance] save];
            [self.tableView reloadData];
            
        };
        return cell;
    }
    return [UITableViewCell new];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SceneDetail *detail = [dataArray objectAtIndex:indexPath.row];
//    if (_type != 0) {
//        if ([_delegate respondsToSelector:@selector(didSelectedDevce:)]) {
//            [_delegate didSelectedDevce:device];
//        }
//        [self.navigationController popViewControllerAnimated:true];
//    }
    
}
-(void)didChangeCell:(NSInteger )deviceId value:(CGFloat )value{
    int index  = 0;
    for (SceneDetail *detail in dataArray) {
        if (detail.device.id == deviceId) {
            detail.value = value;
            [[FirebaseHelper sharedInstance] updateSceneDetail:detail sceneId:self.scene.id];

//            [self.tableView reloadData];
        }
    
    }

}
-(void)didChangeCellState:(NSInteger)deviceId value:(BOOL)value{

}
-(void)didPressedButton:(NSInteger)deviceId value:(ButtonType)value{
    int index = 0;
    for (SceneDetail *detail in dataArray) {
        if (detail.device.id == deviceId) {
            detail.status = value;
            [[FirebaseHelper sharedInstance] updateSceneDetail:detail sceneId:self.scene.id];
            
            [self.tableView reloadData];
            break;
        }
        index++;
    }
    
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
//    [self.tableView beginUpdates];
//    
//    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//    [self.tableView endUpdates];
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
    } else {
        NSLog(@"gestureRecognizer.state = %ld", gestureRecognizer.state);
    }
}

-(void)pressedLeft:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:true];
}
-(void)backtoPrevious{
    [self.navigationController popViewControllerAnimated:true];

}
@end
