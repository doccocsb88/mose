//
//  SortRoomViewController.m
//  SmartHome
//
//  Created by Ngoc Truong on 7/22/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import "SortRoomViewController.h"

@interface SortRoomViewController () <UITableViewDelegate, UITableViewDataSource>
    {
        NSMutableArray *dataArray;
    }
    
    @property (strong, nonatomic) UITableView *tableView;
    @end

@implementation SortRoomViewController
    
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self setupUI ];
    self.automaticallyAdjustsScrollViewInsets = NO;
    // Do any additional setup after loading the view.
}
    
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
    -(void)setupUI{
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 110)];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;

        [self.tableView registerNib:[UINib nibWithNibName:@"SortRoomViewCell" bundle:nil] forCellReuseIdentifier:@"SortRoomViewCell"];
        self.tableView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:self.tableView];
        self.tableView.editing = YES;
    }
    
    -(void)initData{
        dataArray = [[[CoredataHelper sharedInstance] getListRoom] mutableCopy];
        NSLog(@"order");
    }
    /*
     #pragma mark - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
    
    -(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
        return 70.0;
    }
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    [self setReorderingEnabled:( dataArray.count > 1 )];

    return dataArray.count;
}
    
    -(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
        Room *room = [dataArray objectAtIndex:indexPath.row];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SortRoomViewCell" forIndexPath:indexPath];
        
        UILabel *nameLabel = [cell viewWithTag:2];
        if (nameLabel) {
            nameLabel.text = room.name;
        }
        
        UIImageView *thumbView = [cell viewWithTag:1];
        if (thumbView) {
            [thumbView setImage:[UIImage imageNamed:room.image]];
        }
        return cell;
    }
    
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
    {
        return YES;
    }
    - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
        return YES;
    }
    
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}
    
- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    Room *itemFrom = [dataArray objectAtIndex:sourceIndexPath.row];
    Room *itemTo = [dataArray objectAtIndex:sourceIndexPath.row];
    NSInteger order = itemFrom.order;
    itemFrom.order = itemTo.order;
    itemTo.order = order;
    [[CoredataHelper sharedInstance] save];
    //[dataArray removeObjectAtIndex:sourceIndexPath.row];
    //[dataArray insertObject:itemToMove atIndex:destinationIndexPath.row];
    NSLog(@"moveRowAtIndexPath");
}

    @end
