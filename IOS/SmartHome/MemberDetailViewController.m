//
//  MemberDetailViewController.m
//  SmartHome
//
//  Created by Apple on 1/8/18.
//  Copyright © 2018 Apple. All rights reserved.
//

#import "MemberDetailViewController.h"
#define kTableCellHeight 40
#define kTableHeaderHight 50
@interface MemberDetailViewController () <UITableViewDelegate, UITableViewDataSource, MemberDetailDelegate>
{
    NSMutableArray *roomArray;
    NSMutableArray *deviceArray;
    NSMutableDictionary *expenddict;
}
@end

@implementation MemberDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initData];
    [self loadData];
    [self setupUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)initData{
    [self.tableView registerNib:[UINib nibWithNibName:@"MemberDetailViewCell" bundle:nil] forCellReuseIdentifier:@"MemberDetailViewCell"];
    self.tableView.backgroundColor = [UIColor clearColor];
}
-(void)loadData{
    NSArray *allRooms = [[[CoredataHelper sharedInstance] getListRoom] mutableCopy];
    roomArray = [[NSMutableArray alloc] init];
    for (Room *room in allRooms) {
        if ([room getDeviceForShared].count > 0) {
            [roomArray addObject:room];
        }
    }
    expenddict = [NSMutableDictionary new];
    for (Room *room in roomArray) {
        [expenddict setObject:[NSNumber numberWithBool:false] forKey:room.code];
    }
    
    [self.tableView reloadData];
}
-(void)setupUI{
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
    self.navigationItem.title = self.member.displayname;
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return kTableHeaderHight;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kTableCellHeight;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (roomArray) {
        return roomArray.count;
    }
    return 0;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    Room *room = [roomArray objectAtIndex:section];
    NSNumber *status = [expenddict objectForKey:room.code];
    if (status.boolValue) {
        NSArray *shareDevices =  [room getDeviceForShared];
        return shareDevices.count;
    }
    return 0;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kTableHeaderHight)];
    UIButton *headerLabel = [[UIButton alloc] initWithFrame:CGRectMake(20, 0, header.frame.size.width - (20 + 50), kTableHeaderHight)];
    Room *room = [roomArray objectAtIndex:section];
    [headerLabel setTitle:room.name forState:UIControlStateNormal];
    [headerLabel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [headerLabel addTarget:self action:@selector(didPressedExpend:) forControlEvents:UIControlEventTouchUpInside];
    headerLabel.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    headerLabel.tag= section;
    [header addSubview:headerLabel];

    //
    UIButton *expandbutton = [[UIButton alloc] initWithFrame:CGRectMake(width - (30 + 10), (kTableHeaderHight - 30)/2, 30, 30)];
    [expandbutton setImage:[UIImage imageNamed:@"ic_checkbox"] forState:UIControlStateNormal];
    [expandbutton setImage:[UIImage imageNamed:@"ic_checkbox_selected"] forState:UIControlStateSelected];
    BOOL selected = [room.devices allObjects].count >0 ? true:false;
    NSArray *shareDevices = [room getDeviceForShared];
    for (ShareDevice *device in shareDevices) {
        if ([self.member.devices containsString:device.mqttId] == false) {
            selected = false;
            break;
        }
    }
    expandbutton.selected = selected;
    [expandbutton setTitle:@"a" forState:UIControlStateNormal];
    [expandbutton addTarget:self action:@selector(didPressedShareRoom:) forControlEvents:UIControlEventTouchUpInside];
    expandbutton.tag = section;
    expandbutton.backgroundColor = [UIColor clearColor];
    [header addSubview:expandbutton];
    //
    UIView *separater = [[UIView alloc] initWithFrame:CGRectMake(0, kTableHeaderHight - 1, width, 1)];
    separater.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.8];
    [header addSubview:separater];
    header.backgroundColor = [UIColor blackColor];
    return header;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    Room *room = [roomArray objectAtIndex:indexPath.section];

    NSArray *shareDevices = [room getDeviceForShared];
    ShareDevice *device = [shareDevices objectAtIndex:indexPath.row];
    MemberDetailViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MemberDetailViewCell" forIndexPath:indexPath];
    cell.nameLabel.text = device.name;
    if ([self.member.devices containsString:device.mqttId]) {
        cell.sharebutton.on = true;
    }else{
        cell.sharebutton.on = false;
    }
    cell.tag = indexPath.section * 100 + indexPath.row;
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)didPressedExpend:(UIButton *)button{
    NSInteger index = button.tag;
    if (index < roomArray.count) {
        Room *room = [roomArray objectAtIndex:index];
        NSNumber *status = [expenddict objectForKey:room.code];
        [expenddict setObject:[NSNumber numberWithBool:!status.boolValue] forKey:room.code];
        [self.tableView reloadData];
    }
 
}

-(void)didPressedShareRoom:(UIButton *)button{
    button.selected = !button.selected;
    NSInteger index = button.tag;
    NSMutableArray *deviceArr = [[self.member.devices componentsSeparatedByString:@";"] mutableCopy];
    
    if (index < roomArray.count) {
        Room *room = [roomArray objectAtIndex:index];
        //            NSString *deviceString = @"";
        for (ShareDevice *device in [room getDeviceForShared]) {
            if (button.selected == true) {
                
                if ([deviceArr containsObject:device.mqttId] == false) {
                    [deviceArr addObject:device.mqttId];
                }
            }else{
                if ([deviceArr containsObject:device.mqttId]) {
                    [deviceArr removeObject:device.mqttId];
                }
            }
        }
        
    }
    
    self.member.devices = [deviceArr componentsJoinedByString:@";"];
    
    [self.member updateShareDeviceForMember];
    [self.tableView reloadData];
}
#pragma mark
#pragma mark MemberDetailDelegate

-(void)didValueChange:(id)sender value:(BOOL)value{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    if (indexPath.section < roomArray.count) {
        Room *room = [roomArray objectAtIndex:indexPath.section];
        NSArray *shareDevices = [room getDeviceForShared];
        if (indexPath.row < shareDevices.count) {
            ShareDevice *device = [shareDevices objectAtIndex:indexPath.row];
            if (value) {
                [self.member shareDevice:device.mqttId];
            }else{
                [self.member unShareDevice:device.mqttId];
            }
        }
        
    }
    [self.tableView reloadData];
    
}

-(void)pressedLeft:(UIButton *)button{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
