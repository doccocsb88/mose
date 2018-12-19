//
//  EditDeviceMenuViewController.m
//  SmartHome
//
//  Created by Apple on 3/26/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import "EditDeviceMenuViewController.h"
#define CELL_HIGHT 50
#define HEADER_HIGHT 50
#define FOOTER_HIGHT 60

@interface EditDeviceMenuViewController () <UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *dataArray;
    CGSize screenSize;
}
@end

@implementation EditDeviceMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initData];
    [self setupUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)initData{
    dataArray = [[NSMutableArray alloc] init];
    
    [dataArray addObject:@"Hẹn giờ"];
    
    if (self.device) {
        if ([self.device isAutoControl:(int)self.chanel]) {
            [dataArray addObject:@"Không cho phép tự động mở"];
        }else{
            [dataArray addObject:@"Cho phép tự động mở"];

        }
    }else{
        [dataArray addObject:@"Cho phép tự động mở"];
    }
    
    if ([[User sharedInstance] isAdmin]) {
        [dataArray addObject:@"Đổi tên thiêt bị"];
        
        [dataArray addObject:@"Thay biểu tượng"];
        [dataArray addObject:@"Thông tin thiết bị"];
        [dataArray addObject:@"Xoá thiết bị"];
    }

    [dataArray addObject:@"Huỷ"];

}

-(void)setupUI{
    screenSize = [UIScreen mainScreen].bounds.size;
    self.tableView.layer.cornerRadius = 10;
    self.tableView.layer.masksToBounds = true;
    self.tableView.alwaysBounceVertical = true;
    self.tableView.scrollEnabled = false;
    self.marginTop.constant = (screenSize.height - CELL_HIGHT * dataArray.count - HEADER_HIGHT - FOOTER_HIGHT)/2 - 20;
    [self.view updateFocusIfNeeded];

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < dataArray.count - 1) {
        CELL_HIGHT;
    }
    return FOOTER_HIGHT;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return HEADER_HIGHT;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    CGFloat width = screenSize.width - 60;
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 50)];
    UILabel *oldTitle = [header viewWithTag:1];
    if(oldTitle == nil){
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 50)];
        title.tag = 1;
        title.textAlignment = NSTextAlignmentCenter;
        title.text = @"Vận hành thiết bị";
        [header addSubview:title];
    }
    UIView *oldLine = [header viewWithTag:2];
    if(oldLine == nil){
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, HEADER_HIGHT - 1, width, 1)];
        line.tag = 2;
        line.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
        [header addSubview:line];
    }
    return header;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
//    CGFloat width = screenSize.width - 60;
//
//    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 60)];
//    UILabel *oldTitle = [header viewWithTag:1];
//    if(oldTitle == nil){
//        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 60)];
//        title.textAlignment = NSTextAlignmentCenter;
//        title.text = @"Huỷ";
//        [header addSubview:title];
//    }
//    header.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
//    return header;
    return [[UIView alloc] init];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"editDeviceMenuCell" forIndexPath:indexPath];
    UILabel *title = [cell viewWithTag:1];
    title.text = [dataArray objectAtIndex:indexPath.row];
    if (indexPath.row <  dataArray.count - 1) {
        cell.backgroundColor = [UIColor whiteColor];
    }else{
        cell.backgroundColor = [UIColor lightGrayColor];
    }
    cell.selectionStyle = UITableViewRowActionStyleNormal;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < dataArray.count - 1) {
        if([self.delegate respondsToSelector:@selector(selectMenuAtIndex:)]){
            [self dismissViewControllerAnimated:true completion:^{
                [self.delegate selectMenuAtIndex:indexPath.row];

            }];
        }
    }else{
        [self dismissViewControllerAnimated:true completion:nil];
    }
}
@end
