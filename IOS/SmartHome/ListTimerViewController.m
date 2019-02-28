//
//  ListTimerViewController.m
//  SmartHome
//
//  Created by Ngoc Truong on 7/27/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import "ListTimerViewController.h"
@interface ListTimerViewController () <UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *dataArray;
}
@end

@implementation ListTimerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [MQTTService sharedInstance].delegate = self;
    self.tableView.delegate= self;
    self.tableView.dataSource = self;
    self.tableView.userInteractionEnabled = YES;
    [self.tableView registerNib:[UINib nibWithNibName:@"TimerViewCell" bundle:nil] forCellReuseIdentifier:@"timerViewCell"];

}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
     // Do any additional setup after loading the view.
   // NSArray *allTimer = [[CoredataHelper sharedInstance] getListTimers];
//    for (SHTimer *timer in tmp) {
//        NSLog(@"Timer : %ld -- %@",timer.deviceId,timer.topic);
//    }
    if (self.chanel > 0) {
        NSString *requestID = [NSString stringWithFormat:@"%@/%ld",self.device.requestId,self.chanel];
         NSArray *tmp = [[CoredataHelper sharedInstance] getListTimerByRequestId:requestID] ;
        dataArray = [NSMutableArray new];
        for (SHTimer *timer in tmp ) {
            NSString *requestId = timer.requestId;
            if ([requestId containsString:@"/"]) {
                NSString *strChanel = [timer.requestId componentsSeparatedByString:@"/"][1];
                if ([strChanel integerValue] == self.chanel) {
                    [dataArray addObject:timer];
                }
            }
        }
    }else{
        NSArray *tmp = [[CoredataHelper sharedInstance] getListTimerByRequestId:self.device.requestId] ;
        dataArray = [tmp mutableCopy];
    }

    [self.tableView reloadData];
    [self setupUI];
    
    [[MQTTService sharedInstance] requestStatusTimer:dataArray topic:self.device.topic];
    if (self.device) {
        self.navigationItem.title = self.device.name;
    }
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (dataArray && dataArray.count >= 10) {
        [self.rightButton setHidden:true];
    }else{
        [self.rightButton setHidden:false];

    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[CoredataHelper sharedInstance] save];
   
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupUI{
    [self setupNavigator];
}

-(void)setupNavigator{
    
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
    
    self.rightButton = [[UIButton alloc] init];
    self.rightButton.frame = CGRectMake(0, 0, 40, 40);
    self.rightButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.rightButton setImage:[UIImage imageNamed:@"ic_add_device"] forState:UIControlStateNormal];
//    [self.rightButton setTitle:@"Save" forState:UIControlStateNormal];
    [self.rightButton addTarget:self action:@selector(pressedRight:) forControlEvents:UIControlEventTouchUpInside];
    self.rightButton.backgroundColor = [UIColor clearColor];
    self.rightButton.layer.cornerRadius = 3;
    self.rightButton.layer.masksToBounds = YES;
    self.rightButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (dataArray) {
        return dataArray.count;
    }
    
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TimerViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"timerViewCell" forIndexPath:indexPath];
    SHTimer *timer = [dataArray objectAtIndex:indexPath.row];
    timer.order = indexPath.row;
//    timer.requestId = self.device.topic;

    cell.onOffButton.tag = indexPath.row;
    cell.onOffButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell updateContent:timer deviceType:self.device.type];
    __weak TimerViewCell *wCell = cell;
    cell.pressedEnableHandle = ^{
        if (timer.topic == nil || timer.topic.length == 0) {
            timer.topic = self.device.topic;
        }
        if (timer) {
            timer.enable = !timer.enable;
            [[CoredataHelper sharedInstance] save];
            [[MQTTService sharedInstance] setTimer:timer deviceType:self.device.type];
            [wCell updateContent:timer deviceType:self.device.type];

        }
    };
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SHTimer *timer = [dataArray objectAtIndex:indexPath.row];
    
    if (timer.enable) {
        AddTimerViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AddTimerViewController"];
        vc.device = self.device;
        vc.timer = timer;
        //vc.timer.order = indexPath.row;
        NSLog(@"timerOrder %ld",timer.order);
        vc.order = indexPath.row;
        vc.chanel = self.chanel;
        [self.navigationController pushViewController:vc animated:YES];

    }
}

#pragma mark

-(void)mqttSetStateValueForTimer:(NSString *)message{
    NSArray *arrs = [message componentsSeparatedByString:@"'"];
    
    NSLog(@"----- %@",arrs);
}
- (IBAction)pressedEnableTimer:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    SHTimer *timer = [dataArray objectAtIndex:button.tag];
    if (timer.topic == nil || timer.topic.length == 0) {
        timer.topic = self.device.topic;
    }
    if (timer) {
        timer.enable = !button.selected;
        [[CoredataHelper sharedInstance] save];
        [[MQTTService sharedInstance] setTimer:timer deviceType:self.device.type];

    }
}
-(void)pressedRight:(UIButton *)button{
    AddTimerViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AddTimerViewController"];
    vc.device = self.device;
    vc.order = dataArray.count;
    vc.chanel = self.chanel;
    if (dataArray.count <= 10) {
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        [self showMessageView:@"Thông báo" message:@"Bạn được thêm tối đa 10 timers" autoHide:false complete:^(NSInteger index) {
            
        }];
    }
}

-(void)pressedLeft:(UIButton *)button{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
