//
//  FavoriteViewController.m
//  SmartHome
//
//  Created by Apple on 3/12/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import "FavoriteViewController.h"
#import "FavViewCell.h"
#import "ESPViewController.h"
//#import "BaseService.h"
#import "AppDelegate.h"
#import "MQTTClient.h"
#define device_id  @"1/9/8/CURTAIN"
@interface FavoriteViewController () <MQTTSessionDelegate>
{
    NSMutableArray *dataArray;
}
@property (strong, nonatomic) MQTTSession *session;

@end

@implementation FavoriteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupNavigator];
//    [[BaseService sharedInstance] getDeviceStatus:@"led1" complete:^(bool status) {
//        NSLog(@"status %d",status);
//        self.led1Button.tag = status ? 1 : 0;
//        self.led1Button.backgroundColor = status ? [UIColor redColor] : [UIColor whiteColor];
//    }];
//    [[BaseService sharedInstance] getDeviceStatus:@"led2" complete:^(bool status) {
//        NSLog(@"status %d",status);
//        self.let2Button.tag = status ? 1 : 0;
//        self.let2Button.backgroundColor = status ? [UIColor redColor] : [UIColor whiteColor];
//
//    }];
//    [[BaseService sharedInstance] getDeviceStatus:@"led3" complete:^(bool status) {
//        NSLog(@"status %d",status);
//        self.led3Button.tag = status ? 1 : 0;
//        self.led3Button.backgroundColor = status ? [UIColor redColor] : [UIColor whiteColor];
//
//    }];
    
//    [[BaseService sharedInstance] getToken];
    
    MQTTCFSocketTransport *transport = [[MQTTCFSocketTransport alloc] init];
    transport.host = @"quocanhtest.dyndns.tv";
    transport.port = 1883;
    
    _session = [[MQTTSession alloc] init];
    _session.transport = transport;
    _session.userName = @"";
    _session.password = @"";
    _session.delegate = self;
    
    [_session connectAndWaitTimeout:30];
}
-(void)setupNavigator{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 160, 40)];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.text = @"YÊU THÍCH";
    titleLabel.textColor = [Helper colorFromHexString:@"3fb2b5"];
    titleLabel.font = [UIFont systemFontOfSize:25];
//    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:titleLabel];
    self.navigationItem.titleView = titleLabel;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)smartConfig:(id)sender {
    ESPViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ESPViewController"];

    [self.navigationController pushViewController:vc animated:true];
}
- (IBAction)onOff:(id)sender {
//    UIButton *button = (UIButton *)sender;
//    button.tag = button.tag == 1 ? 0 : 1;
//    
//    [[BaseService sharedInstance] post:button.tag == 1 deviceName:@"led2"];
//    button.backgroundColor = button.tag == 1 ? [UIColor redColor] : [UIColor whiteColor];

}
- (IBAction)pressedLed1:(id)sender {
//    UIButton *button = (UIButton *)sender;
//    button.tag = button.tag == 1 ? 0 : 1;
//    
//    [[BaseService sharedInstance] post:button.tag == 1 deviceName:@"led1"];
//    button.backgroundColor = button.tag == 1 ? [UIColor redColor] : [UIColor whiteColor];
    [self publishTest:@"OPEN"];

}
- (IBAction)pressedLed3:(id)sender {
//    UIButton *button = (UIButton *)sender;
//    button.tag = button.tag == 1 ? 0 : 1;
//    
//    [[BaseService sharedInstance] post:button.tag == 1 deviceName:@"led3"];
//    button.backgroundColor = button.tag == 1 ? [UIColor redColor] : [UIColor whiteColor];
    [self publishTest:@"CLOSE"];

}

- (IBAction)listDevices:(id)sender {
//    [[BaseService sharedInstance] get];
}
-(void)publishTest:(NSString *)message{
    [_session publishData:[message dataUsingEncoding:NSUTF8StringEncoding] onTopic:@"1/9/8/CURTAIN/CONTROL" retain:NO qos:2];
}
-(void)connected:(MQTTSession *)session{
    NSLog(@"connected");
    [_session subscribeToTopic:@"1/9/8/CURTAIN/FEEDBACK" atLevel:2 subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss){
        if (error) {
            NSLog(@"Subscription failed %@", error.localizedDescription);
        } else {
            NSLog(@"Subscription sucessfull! Granted Qos: %@", gQoss);
//            [self publishTest:@"OPEN"];
        }
    }]; // t
    
}

-(void)connectionClosed:(MQTTSession *)session{
    NSLog(@"connectionClosed");
    
}

-(void)connectionError:(MQTTSession *)session error:(NSError *)error{
    NSLog(@"connectionError %@",error.description);
    
}

-(void)connectionRefused:(MQTTSession *)session error:(NSError *)error{
    NSLog(@"connectionRefused");
    
}

-(void)connected:(MQTTSession *)session sessionPresent:(BOOL)sessionPresent{
    NSLog(@"connected sessionPresent %d",sessionPresent);
}
- (void)newMessage:(MQTTSession *)session
              data:(NSData *)data
           onTopic:(NSString *)topic
               qos:(MQTTQosLevel)qos
          retained:(BOOL)retained
               mid:(unsigned int)mid {
    // this is one of the delegate callbacks
    NSLog(@"newMessage %@: %@",topic,[[NSString alloc] initWithData:data encoding:kCFStringEncodingUTF8]);
    NSString *respone = [[NSString alloc] initWithData:data encoding:kCFStringEncodingUTF8];
    if ([topic containsString:device_id]) {
        [self.let2Button setTitle:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] forState:UIControlStateNormal];
        if (respone && respone.length > 0) {
            if ([respone isEqualToString:@"0"]) {
                self.led1Button.backgroundColor = [UIColor redColor];
                self.led3Button.backgroundColor = [UIColor whiteColor];
            }else if ([respone isEqualToString:@"100"]){
                self.led3Button.backgroundColor = [UIColor redColor];
                self.led1Button.backgroundColor = [UIColor whiteColor];
            }
        }
    }
}

- (void)session:(MQTTSession*)session newMessage:(NSData*)data onTopic:(NSString*)topic{
    NSLog(@"newMessage 2 : %@ - %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding],topic);
    if ([topic containsString:device_id]) {
        [self.let2Button setTitle:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] forState:UIControlStateNormal];
    }
}
@end
