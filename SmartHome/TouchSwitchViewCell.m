//
//  TouchSwitchViewCell.m
//  
//
//  Created by Apple on 3/6/18.
//

#import "TouchSwitchViewCell.h"
#import "User.h"
@interface TouchSwitchViewCell()
@property (assign, nonatomic) float value;
@property (assign, nonatomic) NSInteger existChanel;
@property (strong, nonatomic) NSMutableArray *requestIds;

@end
@implementation TouchSwitchViewCell 

- (void)awakeFromNib {
    [super awakeFromNib];
    self.requestIds = [NSMutableArray new];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.scrollEnabled = false;
      [self.tableView registerNib:[UINib nibWithNibName:@"ChannelViewCell" bundle:nil] forCellReuseIdentifier:@"ChannelViewCell"];
    self.myBackgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    self.myBackgroundView.layer.cornerRadius = 5.0;
    self.myBackgroundView.layer.masksToBounds = YES;
    // Initialization code
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    self.visualEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
    self.visualEffectView.frame = self.tableView.bounds;
    self.visualEffectView.alpha = 0.5;
    self.visualEffectView.layer.cornerRadius = 5.0;
    self.visualEffectView.layer.masksToBounds = true;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setContentView:(SceneDetail *)detail{
    self.isScene = true;
    self.detail = detail;
    [self setContentValue:detail.device];
//    if (detail.isSelected) {
//        self.myBackgroundView.backgroundColor = [UIColor redColor];
//    }else{
//        self.myBackgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
//    }
    self.myBackgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
}
-(void)setContentValue:(Device *)device{
    self.requestIds = [NSMutableArray new];
    self.device = device;
    self.deviceNameLabel.text = self.device.name;
    [self.tableView reloadData];
    for (int i = 0; i < [self.device numberOfSwitchChannel]; i++) {
        int chanelIndex = i + 1;
        NSString *requestId = [NSString stringWithFormat:@"%@/%d",self.device.requestId,chanelIndex];
        if ([[User sharedInstance].devices containsObject:requestId] || [[User sharedInstance] isAdmin]) {
        
            [self.requestIds addObject:requestId];
        }
    }
    NSLog(@"setContentValue : %ld",self.requestIds.count);
    if (self.visualEffectView) {
        [self.visualEffectView removeFromSuperview];
    }
    if (self.device.isOnline == false) {
        self.visualEffectView.frame = CGRectMake(10, 5, self.bounds.size.width - 20, self.bounds.size.height - 10);
        [self addSubview:self.visualEffectView];
    }
}
-(void)setContentView:(Device *)device type:(NSInteger)type{
    [self setContentValue:device];
    self.tableView.userInteractionEnabled = type == 0;
}
-(void)setContentView:(Device *)device type:(NSInteger)type selected:(BOOL)selected{
    [self setContentView:device type:type];
    if (selected) {
        self.myBackgroundView.backgroundColor = [UIColor redColor];
    }else{
        self.myBackgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    }
}
-(NSInteger )numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.isScene) {
        if (self.isEdit) {
            return [self.detail numberOfChanel];
        }else{
            return [self.detail.device numberofSharedChanel];
        }
        
    }

    return [self.device numberofSharedChanel];
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ChannelViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChannelViewCell" forIndexPath:indexPath];;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    NSString *requestId = [self.requestIds objectAtIndex:indexPath.row];
    NSString *chanelIndex = [requestId componentsSeparatedByString:@"/"][1];
    NSInteger tag = [chanelIndex integerValue];
    [cell.onOffButton addTarget:self action:@selector(didPressedOnOff:) forControlEvents:UIControlEventTouchUpInside];
    float deviceValue = self.device.value;
    if (self.isScene) {
        tag = indexPath.row + 1;
        if (self.isEdit) {
            if ([self.detail getChanelIndex:indexPath.row] != NSNotFound){
                tag = [self.detail getChanelIndex:indexPath.row];
            }

        }
        deviceValue = self.detail.value;

        [cell setChanelSelected:[self.detail isChanelSelected:tag] && !self.isEdit];
    }else{
        [cell setChanelSelected:false];

    }
    cell.onOffButton.tag = tag;

    if (tag == 1) {
        //chanel 1
        if ((int)deviceValue % 2 == 0) {
            cell.onOffButton.selected = false;
        }else{
            cell.onOffButton.selected = true;
        }
    }else if (tag == 2){
         //chanel 2
        if (deviceValue == 2 || deviceValue == 3 || deviceValue == 6 || deviceValue == 7) {
            cell.onOffButton.selected = true;
        }else{
            cell.onOffButton.selected = false;
        }
    }else if (tag == 3){
         //chanel 3
        if (deviceValue >= 4.0) {
            cell.onOffButton.selected = true;
        }else{
            cell.onOffButton.selected = false;
        }
    }
    NSString *nameKey = [NSString stringWithFormat:@"name%ld",tag];
    NSString *jsonString = self.device.chanelInfo;
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
//    NSLog(@"change touch switch name  : %@", jsonString);
    NSString *name = [json objectForKey:nameKey];
    if (name && name.length > 0) {
        cell.nameLabel.text = name;
    }else{
        cell.nameLabel.text = [NSString stringWithFormat:@"Đèn %ld",tag];
    }
    cell.controlButton.tag = tag;
    [cell.controlButton addTarget:self action:@selector(didPressedControl:) forControlEvents:UIControlEventTouchUpInside];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.handleSelectChanel) {
        [self.detail setSelectedChanel:indexPath.row + 1];

        self.handleSelectChanel(indexPath.row + 1);
        [self.tableView reloadData];
    }
}
/**/
-(void)didPressedOnOff:(UIButton *)sender{
    NSInteger tag = sender.tag;
    self.value = self.device.value;
    BOOL isSelected = true;
    
    if (self.isScene) {
        self.value = self.detail.value;
        isSelected = [self.detail isChanelSelected:tag];
    }
    if (tag > 0) {
//        id=’WT3-0000000003/1’ cmd=’ON’ value=’W3,2,1’
        NSLog(@"updateStatusForChanel ::::: %ld",tag);

        BOOL cmd = false;
        if (tag == 1) {
            //chenal 1
            if ((int)self.value % 2 == 0) {
                self.value += 1;
                cmd = true;
            }else{
                self.value -= 1;
            }
        }else if (tag == 2 ){
            //chenal 2
            if (self.value == 2 || self.value == 3 || self.value == 6 || self.value == 7) {
                self.value -= 2;
            }else{
                self.value += 2;
                cmd = true;

            }
        }else if (tag == 3 ){
            //chenal 3
            if (self.value == 4 || self.value == 5 || self.value == 6 || self.value == 7) {
                self.value -= 4;
            }else{
                self.value += 4;
                cmd = true;

            }
        }
        if (self.isScene) {
            self.detail.value = self.value;
            
            if (self.completionHandler) {
                self.completionHandler([NSString stringWithFormat:@"%f",self.value],tag);
                
            }
        }else{
//            self.device.value = self.value;
            if(self.isLoading == false){
                [[MQTTService sharedInstance] publishControl:self.device.requestId topic:self.device.topic message:[self.device switchChancelMessage:(int)tag status:cmd] type:self.device.type count:0];
                if (self.controlHandler) {
                    self.controlHandler();
                }
            }else{
                NSLog(@"dang loading");
            }
        }

    }
//    [[CoredataHelper sharedInstance] save];
//    [self.tableView reloadData];
}

-(void)didPressedControl:(UIButton *)button{
    if (self.completionHandler) {
        self.completionHandler([NSString stringWithFormat:@"%f",self.value],button.tag);
        
    }
}
@end
