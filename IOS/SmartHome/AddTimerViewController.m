//
//  AddTimerViewController.m
//  SmartHome
//
//  Created by Ngoc Truong on 7/27/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import "AddTimerViewController.h"
#define DAYARRAY @[@"Thứ hai",@"Thứ ba",@"Thứ tư",@"Thứ năm",@"Thứ sáu",@"Thứ bảy",@"Chủ nhật"]
@interface AddTimerViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) NSMutableArray *selectedDate;
@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *statusButton;

@end

@implementation AddTimerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectedDate = [[NSMutableArray alloc] init];
    // Do any additional setup after loading the view.
    [self.timePicker setValue:[UIColor whiteColor] forKey:@"textColor"];
    self.statusButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.curtainValueSlider addTarget:self action:@selector(touchEnded:)
          forControlEvents:UIControlEventTouchUpInside];

    [self iniNavigator];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.device.type == DeviceTypeCurtain) {
        self.lightStatusView.hidden = YES;
        self.curtainStatusView.hidden = NO;
        
    }else{
        self.lightStatusView.hidden = NO;
        self.curtainStatusView.hidden = YES;
    }
    if (self.timer) {
        
        [self layoutCurtainView:!self.timer.status value:self.timer.value];
 
        
        self.statusButton.selected = !self.timer.status;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat =  @"HH:mm";
        
        NSDate *date = [dateFormatter dateFromString:self.timer.timer];
        
        self.timePicker.date = date;
        if (self.timer.t2) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            if ([self.selectedDate containsObject:indexPath] == false) {
                [self.selectedDate addObject:indexPath];
            }
        }
        if (self.timer.t3) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];

            if ([self.selectedDate containsObject:indexPath] == false) {
                [self.selectedDate addObject:indexPath];
            }
        }
        if (self.timer.t4) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];

            if ([self.selectedDate containsObject:indexPath] == false) {
                [self.selectedDate addObject:indexPath];
            }
        }
        if (self.timer.t5) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:3 inSection:0];

            if ([self.selectedDate containsObject:indexPath] == false) {
                [self.selectedDate addObject:indexPath];
            }
        }
        if (self.timer.t6) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:4 inSection:0];

            if ([self.selectedDate containsObject:indexPath] == false) {
                [self.selectedDate addObject:indexPath];
            }
        }
        if (self.timer.t7) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:5 inSection:0];

            if ([self.selectedDate containsObject:indexPath] == false) {
                [self.selectedDate addObject:indexPath];
            }
        }
        if (self.timer.t8) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:6 inSection:0];

            if ([self.selectedDate containsObject:indexPath] == false) {
                [self.selectedDate addObject:indexPath];
            }
        }
        [self.tableView reloadData];
    }else{
     
        [self layoutCurtainView:true value:0.0];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)iniNavigator{
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
    self.navigationItem.title = @"Hẹn giờ";
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    //
    self.rightButton = [[UIButton alloc] init];
    self.rightButton.frame = CGRectMake(0, 0, 40, 40);
//    self.rightButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
//    [self.rightButton setImage:[UIImage imageNamed:@"ic_add_device"] forState:UIControlStateNormal];
    [self.rightButton setTitle:@"Lưu" forState:UIControlStateNormal];
    [self.rightButton addTarget:self action:@selector(pressedRight:) forControlEvents:UIControlEventTouchUpInside];
    self.rightButton.backgroundColor = [UIColor clearColor];
    self.rightButton.layer.cornerRadius = 3;
    self.rightButton.layer.masksToBounds = YES;
    self.rightButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    self.rightButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.rightButton.layer.borderWidth = 1.0;
    [self.rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
}
#pragma mark
#pragma TableView 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return DAYARRAY.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"timeDayViewCell" forIndexPath:indexPath];
    UILabel *titleLable = [cell viewWithTag:1];
    titleLable.text = DAYARRAY[indexPath.row];
    UIImageView *selectedImage = [cell viewWithTag:2];
    if (selectedImage) {
        selectedImage.hidden = ![self.selectedDate containsObject:indexPath];
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.selectedDate containsObject:indexPath]) {
        [self.selectedDate removeObject:indexPath];
    }else{
        [self.selectedDate addObject:indexPath];
    }
    [self.tableView beginUpdates];
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}
-(void)layoutCurtainView:(BOOL)status value:(CGFloat)value{
    self.curtainCloseButton.selected = !status;
    self.curtainOpenButton.selected = status;
    self.curtainValueSlider.value = value;

}
- (IBAction)didSelectedDateTime:(id)sender {
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"HH:mm"]; //24hr time format
    NSString *dateString = [outputFormatter stringFromDate:self.timePicker.date];
    NSLog(@"zzz : %@",dateString);
}
- (NSString *)getTimer{
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"HH:mm"]; //24hr time format
    NSString *dateString = [outputFormatter stringFromDate:self.timePicker.date];
    return dateString;
}
- (IBAction)pressedLightState:(id)sender {
    self.statusButton.selected = !self.statusButton.selected;
}
- (IBAction)pressedCurtainClose:(id)sender {
    //

    [self layoutCurtainView:false value:self.curtainValueSlider.value];
    self.isSlide = false;

}
- (IBAction)pressedCurtainOpen:(id)sender {

    [self layoutCurtainView:true value:self.curtainValueSlider.value];
    self.isSlide = false;
    
}
- (IBAction)curtaintValueChanged:(id)sender {
    
    [self layoutCurtainView:self.curtainOpenButton.selected value:self.curtainValueSlider.value];
    
}


-(void)touchEnded:(UISlider *)sender{
    self.isSlide = true;
}
-(void)pressedLeft:(UIButton *)button{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)pressedRight:(UIButton *)button{
    if (self.timer == nil) {
        self.timer = [[CoredataHelper sharedInstance] addTimer];
        self.timer.enable = YES;
        if([self.device.requestId containsString:@"WT"] && self.chanel > 0){
            self.timer.requestId = [NSString stringWithFormat:@"%@/%d",self.device.requestId,self.chanel];
        }else{
            self.timer.requestId = self.device.requestId;

        }
        self.timer.type = self.device.type;
        self.timer.topic = self.device.topic;
    }
    if (self.device.type == DeviceTypeLightOnOff || self.device.type == DeviceTypeTouchSwitch) {
        self.timer.status = !self.statusButton.selected;

    }else if (self.device.type == DeviceTypeCurtain){
        BOOL status = self.curtainOpenButton.selected;
        self.timer.status = !status;
    }
    self.timer.timer = [self getTimer];
    self.timer.deviceId = self.device.id;
    self.timer.order = self.order;
    self.timer.value = self.curtainValueSlider.value;
    self.timer.isSlide = self.isSlide;
    self.timer.type = self.device.type;
    [self.timer resetRepeat];
    for (NSIndexPath *indexPath in self.selectedDate) {
        
        switch (indexPath.row) {
            case 0:
                self.timer.t2 = YES;
                break;
            case 1:
                self.timer.t3 = YES;
                
                break;
            case 2:
                self.timer.t4 = YES;

                break;
            case 3:
                self.timer.t5 = YES;

                break;
            case 4:
                self.timer.t6 = YES;

                break;
            case 5:
                self.timer.t7 = YES;

                break;
            case 6:
                self.timer.t8 = YES;

                break;
            default:
                break;
        }
    }
    [[CoredataHelper sharedInstance] save];
    [[FirebaseHelper sharedInstance] addTimer:self.timer deviceId:self.device.id complete:^(NSString *key) {
        self.timer.key = key;
        [[MQTTService sharedInstance] setTimer:self.timer deviceType:self.device.type];
        [self.navigationController popViewControllerAnimated:YES];

    }];
    
}
@end
