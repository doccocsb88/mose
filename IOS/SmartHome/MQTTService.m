//
//  MQTTService.m
//  SmartHome
//
//  Created by Ngoc Truong on 7/15/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import "MQTTService.h"
#import "Utils.h"
#import "NSString+Utils.h"
#import "FirebaseHelper.h"
#import "AppDelegate.h"
#import <Reachability.h>
#import "MessagesUtils.h"
#define CHECK_PUBLISH_TIME 2
#define REQUEST_STATUS_TIME 0.5

#define SEND_REQUEST_COUNT 3
static MQTTService *instance = nil;

@interface MQTTService() <MQTTSessionDelegate>
{
    double delayInSeconds;
    
}
@property (assign, nonatomic) NSInteger countProcess;
@property (strong, nonatomic) NSMutableDictionary *sucessTimerArr;
@property (strong, nonatomic) NSMutableDictionary *subscribeToTopics;

@end
@implementation MQTTService
+ (instancetype)sharedInstance
{
    if (instance == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            instance = [[MQTTService alloc] _init];
        });
    }
    
    return instance;
}

//- (instancetype)init {
//    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"..." userInfo:nil];
//}
- (instancetype)_init {
    self = [super init];
    if (!self) {
        return nil;
    }
    [self setUP];
    return self;
}

- (void)setUP {
    if (_isInit == false) {
        MQTTCFSocketTransport *transport = [[MQTTCFSocketTransport alloc] init];
        transport.host = @"mqtt.rollertech.vn";//@"quocanhtest.dyndns.tv";
        transport.port = 1883;
        NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
        NSString *clientId = [pref objectForKey:@"mqttClientId"];
        //        transport.sho
        _session = [[MQTTSession alloc] init];
        _session.transport = transport;
        _session.keepAliveInterval = 120;
        _session.delegate = self;
        _session.userName = @"hardone";
        _session.password = @"-m>5p}VzxT^>S&2L";
        _session.clientId =  clientId ? clientId : [@"" randomStringWithLength:32];
        _session.cleanSessionFlag = NO;
        _isConnecting = true;
        NSLog(@"aabbccddeeff");
        //
        self.publishingTopic = [[NSMutableArray alloc] init];
        self.sucessTimerArr = [[NSMutableDictionary alloc] init];
        self.subscribeToTopics = [[NSMutableDictionary alloc] init];
        _isInit = true;
        //        [_session disconnect];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kMqttConnectToServer" object:nil userInfo:@{@"result":@"0"}];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(conect) name:kReachabilityChangedNotification object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subscribeToTopicSuccess:) name:@"subscribeToTopic" object:nil];
    }
    
    
}
-(void)removeListDevices:(NSArray *)devices{
    NSArray *arr = [self.dataArray copy];
    for (Device *device in devices) {
        for (Device *d in arr) {
            if (device.id == d.id) {
                NSString *topic = @"";
                
                topic = device.topic;
                
                [self.dataArray removeObject:d];
                
                
            }
        }
    }
}

-(void)subcribeDevices:(NSArray *)devices{
    //NSLog(@"subcribeDevices %ld",devices.count);
    self.countProcess = 0;
    
    __weak MQTTService *wself = self;
    
    if (!wself.dataArray) {
        wself.dataArray = [[NSMutableArray alloc] init];
    }
    NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:devices];
    for (Device *dv in devices) {
        for (Device *dc in wself.dataArray) {
            if (dc.id == dv.id) {
                [arr removeObject:dv];
            }
        }
        
    }
    [wself.dataArray addObjectsFromArray:arr];
    delayInSeconds = 0;
    for (Device *device in devices) {
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // throw your call to other functions in here
           [wself subscribeToTopic:device];
       
        delayInSeconds += 0.25;
    }
    
}

-(void)subscribeToTopic:(Device *)device{
    __weak MQTTService *wsekf = self;
    NSString *topic = device.topic;
    NSInteger index = 1;
    NSLog(@"subscribeToTopic %@",device.topic);
    if (![self getDeviceByMqttId:device.requestId]) {
        [self.dataArray addObject:device];
    }
    if (device.isSubcrible == false) {
        if (topic && topic.length > 0) {
            wsekf.countProcess ++;
//            NSTimer *subscribeTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(checkSubcribeSucess:) userInfo:@{@"mqttId":topic} repeats:false];
//            //        });
//            [self.subscribeToTopics setObject:subscribeTimer forKey:topic];
            //
            [_session subscribeToTopic:topic atLevel:MQTTQosLevelAtMostOnce subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss){
                NSTimer *subcribeTimer = [wsekf.subscribeToTopics objectForKey:topic];
                if (subcribeTimer) {
                    [subcribeTimer invalidate];
                    subcribeTimer = nil;
                }
                [wsekf.subscribeToTopics removeObjectForKey:topic];

                if (error) {
                    NSLog(@"Subscription failed %@ %@",topic, error.localizedDescription);
                } else {
                    NSLog(@"Subscription sucessfull! %@", topic);
                    
                    self.countProcess --;
                    [self checkFinishedProcess];
                    device.isSubcrible = TRUE;
                    delayInSeconds  = index * REQUEST_STATUS_TIME;
                    if (device.isGetStatus == false) {
                        NSLog(@"publicRequestStatus a");
//                        [self publicRequestStatus:device];//
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"subscribeToTopic" object:nil userInfo:@{@"device":device}];
                    }
                   
                    
                    
                }
            }];
            
            
        }
    }else{
        if (device.isGetStatus == false) {
            NSLog(@"publicRequestStatus b");

            [self publicRequestStatus:device];
        }
    }
}

-(void)requestStatus:(NSArray *)devices{
    __weak MQTTService *wsekf = self;
    int index = 0;
    double delayInSeconds = 0;

    for (Device *dv in devices) {
        delayInSeconds  = index * REQUEST_STATUS_TIME;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            //code to be executed on the main queue after delay
            if (dv.isGetStatus == false) {
                [wsekf publicRequestStatus:dv];
            }
        });
        index++;
    }
}
-(void)clearPublishDevice{
//    self.publishedTopic = [NSMutableArray new];
}
-(void)clearRequestStatusDevice{
    NSLog(@"cleardata 1");
    NSArray *devices = [[CoredataHelper sharedInstance] getListDevice];
    for (Device *device in devices){
        device.isGetStatus = false;
    }
    [self.dataArray removeAllObjects];
}
-(Device *)getDeviceByTopic:(NSString *)topic{
    for (Device *device in self.dataArray) {
        if (device.type == DeviceTypeCurtain || device.type == DeviceTypeTouchSwitch) {
            if ([topic containsString:device.requestId]) {
                return device;
            }
        }else if (device.type == DeviceTypeLightOnOff){
            if ([topic isEqualToString:device.requestId]) {
                return device;
            }
        }
        
    }
    return nil;
}
-(Device *)getDeviceByMqttId:(NSString *)mqttId{
    for (Device *device in self.dataArray) {
        if ([device.requestId isEqualToString:mqttId]) {
            return device;
        }
    }
    return nil;
}
-(void)publicRequestStatus:(Device *)device{
    
    
//    __weak MQTTService *wSelf = self;
    NSString *message= @"";
    NSString *topic = device.topic;
    NSString *mqttId = device.requestId;
    if ([self.publishingTopic containsObject:mqttId]) {
        return;
    }
    if (device.type == DeviceTypeCurtain || device.type == DeviceTypeTouchSwitch) {
        message = [NSString stringWithFormat:@"id='%@' cmd='GETSTATUS'",mqttId];
    }else if(device.type == DeviceTypeLightOnOff){
        message = [NSString stringWithFormat:@"id='%@' cmd='GETSTATUS'",mqttId];
    }else{
        NSLog(@"publicRequestStatus : wtf");
        
    }
    
    
    NSLog(@"publicRequestStatus 1: %@",mqttId);
    
    if ([mqttId containsString:@"WT3"]) {
        NSLog(@"publicRequestStatus testOfflineWifi : %@",mqttId);
    }
    NSLog(@"publicRequestStatus 2: %@",message);
    
    [self publicMessage:message mqttId:mqttId topic:topic type:device.type count:3 complete:^(BOOL finished) {
        
    }];
    
}

-(void)publishControl:(NSString *)requestId topic:(NSString *)topic message:(NSString *)message type:(NSInteger)type count:(int)count complete:(void(^)(BOOL finished))complete{
    NSString *msg = @"";
    NSString *mqttId = requestId;
    if ([self.publishingTopic containsObject:requestId]) {
        complete(false);
        return;
    }
    NSLog(@"publishControl xxx %@",requestId);
    if (type == DeviceTypeCurtain) {
        NSString *msg = [NSString stringWithFormat:@"id='%@' cmd='%@'",requestId,message];
        if ([message containsString:@"value"]) {
            msg = message;
        }
        
//        [self cancelCheckPublishTimerByMqttId:requestId];
//        [self.publishingTopic addObject:requestId];
//
//        NSTimer *sucessTimer = [NSTimer scheduledTimerWithTimeInterval:CHECK_PUBLISH_TIME target:self selector:@selector(checkPublishSucess:) userInfo:@{@"mqttId":requestId,@"topic":topic,@"message":message,@"type":[NSString stringWithFormat:@"%ld",type],@"count":[NSString stringWithFormat:@"%d",count]} repeats:NO];
//        [_sucessTimerArr setObject:sucessTimer forKey:requestId];
//
//        [_session publishData:[msg dataUsingEncoding:NSUTF8StringEncoding] onTopic:topic retain:NO qos:MQTTQosLevelAtMostOnce publishHandler:^(NSError *error) {
//            complete(true);
//
//        }];
    }else if (type == DeviceTypeTouchSwitch){
        NSArray *info = [message componentsSeparatedByString:@"'"];
        mqttId = info[1];
        NSLog(@"tw : 2 :2 %@",requestId);
        msg = message;
//        if ([mqttId containsString:@"WT"] == true && [mqttId containsString:@"/"] == true) {
//            if ([self.publishingTopic containsObject:mqttId] == false) {
//                [self.publishingTopic addObject:mqttId];
//                [self cancelCheckPublishTimerByMqttId:mqttId];
//
//                NSTimer *sucessTimer = [NSTimer scheduledTimerWithTimeInterval:CHECK_PUBLISH_TIME target:self selector:@selector(checkPublishSucess:) userInfo:@{@"mqttId":mqttId,@"topic":topic,@"message":message,@"type":[NSString stringWithFormat:@"%ld",type],@"count":[NSString stringWithFormat:@"%d",count]} repeats:NO];
//                NSLog(@"tw : 3 %@",message);
//                [_sucessTimerArr setObject:sucessTimer forKey:mqttId];
//
//                //
//                [_session publishData:[message dataUsingEncoding:NSUTF8StringEncoding] onTopic:topic retain:NO qos:MQTTQosLevelAtMostOnce publishHandler:^(NSError *error) {
//                    complete(true);
//                }];
//            }
//        }
        
        
    }else if (type == DeviceTypeLightOnOff){
        if ([message isEqualToString:@"CLOSE"]) {
            msg = [NSString stringWithFormat:@"id='%@' cmd='OFF'",requestId];
        }else if ([message isEqualToString:@"OPEN"]){
            msg = [NSString stringWithFormat:@"id='%@' cmd='ON'",requestId];
            
        }
    }
    if (msg && msg.length > 0) {
        [self publicMessage:msg mqttId:mqttId topic:topic type:type count:count complete:^(BOOL finished) {
            complete(finished);
        }];
    }
}

-(void)publicMessage:(NSString *)message mqttId:(NSString *)mqttId topic:(NSString *)topic type:(NSInteger)type count:(int)count complete:(void(^)(BOOL finished))complete{
    
    NSLog(@"publicMessage start %@",message);
    [self cancelCheckPublishTimerByMqttId:mqttId];
    [self.publishingTopic addObject:mqttId];
    if (type == DeviceTypeCurtain) {
        NSLog(@"publicMessage curtain");
    }
    //
    NSDictionary *userInfo = @{@"mqttId":mqttId,@"topic":topic,@"message":message,@"type":[NSString stringWithFormat:@"%ld",type],@"count":[NSString stringWithFormat:@"%d",count]};
    NSTimer *sucessTimer = [NSTimer scheduledTimerWithTimeInterval:CHECK_PUBLISH_TIME target:self selector:@selector(checkPublishSucess:) userInfo:userInfo repeats:NO];
    [_sucessTimerArr setObject:sucessTimer forKey:mqttId];
    
    //
    NSLog(@"publicMessage publishData %@",userInfo);
    [_session publishData:[message dataUsingEncoding:NSUTF8StringEncoding] onTopic:topic retain:NO qos:MQTTQosLevelAtMostOnce publishHandler:^(NSError *error) {
        complete(true);
        
        if (error) {
            NSLog(@"publicMessage publish failed");
            if (self.delegate && [self.delegate respondsToSelector:@selector(mqttPublishFail:)]) {
                [self.delegate mqttPublishFail:topic];
            }
        }
    }];
}
-(void)requestStatusTimer:(NSArray *)arrTimer{
    NSInteger index = 0;
    for (SHTimer *timer in arrTimer) {
        double delayInSeconds = index * 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            NSString *msg = [timer getStatusCommandString];
            [_session publishData:[msg dataUsingEncoding:NSUTF8StringEncoding] onTopic:timer.topic retain:NO qos:MQTTQosLevelAtMostOnce publishHandler:^(NSError *error) {
                
                if (error) {
                    NSLog(@"publish failed");
                    if (self.delegate && [self.delegate respondsToSelector:@selector(mqttPublishFail:)]) {
                        [self.delegate mqttPublishFail:timer.topic];
                    }
                }
            }];
        });
        index ++;
    }
    
}
-(void) setTimer:(SHTimer *)timer{
    NSString *msg = [timer getCommandString:DeviceTypeUnknow goto:timer.isSlide];
    NSLog(@"setTimer : %@",msg);
    [_session publishData:[msg dataUsingEncoding:NSUTF8StringEncoding] onTopic:timer.topic retain:NO qos:MQTTQosLevelAtMostOnce publishHandler:^(NSError *error) {
        
        if (error) {
            NSLog(@"publish failed");
            if (self.delegate && [self.delegate respondsToSelector:@selector(mqttPublishFail:)]) {
                [self.delegate mqttPublishFail:timer.topic];
            }
        }
    }];
    //    id='WT3-0000000004/1' cmd='SETTIMER' value='0,1,13:39,0,01111100'
    //    id='WT3-0000000004/1' cmd='SETTIMER' value='1,1,13:41,0,01111110'
    //    id='WT3-0000000004/3' cmd='SETTIMER' value='1,1,13:47,1,01110110'
    
    
}

-(void)addMQTTDevice:(Device *)device{
    [_session publishData:[[device getAddMessage] dataUsingEncoding:NSUTF8StringEncoding] onTopic:device.topic retain:NO qos:MQTTQosLevelAtMostOnce publishHandler:^(NSError *error) {
        
        if (error) {
            NSLog(@"publish failed");
            if (self.delegate && [self.delegate respondsToSelector:@selector(mqttPublishFail:)]) {
                [self.delegate mqttPublishFail:device.topic];
            }
        }
    }];
    
}
-(void)delMQTTDevice:(Device *)device{
    [_session publishData:[[device getDelMessage] dataUsingEncoding:NSUTF8StringEncoding] onTopic:device.topic retain:NO qos:MQTTQosLevelAtMostOnce publishHandler:^(NSError *error) {
        
        if (error) {
            NSLog(@"publish failed");
            if (self.delegate && [self.delegate respondsToSelector:@selector(mqttPublishFail:)]) {
                [self.delegate mqttPublishFail:device.topic];
            }
        }
    }];
    
}
-(void)checkSubcribeSucess:(NSTimer *)timer{
    NSDictionary *userInfo = timer.userInfo;
    if (userInfo) {
        NSString *mqttId = [userInfo objectForKey:@"mqttId"];
        if (mqttId != nil) {
            Device *getStatusDevice = [[ CoredataHelper sharedInstance] getDeviceByTopic:mqttId];
            if (getStatusDevice) {
                getStatusDevice.isOnline = false;
                getStatusDevice.isSubcrible = true;
                [[CoredataHelper sharedInstance] save];
                NSLog(@"checkSubcribeSucess %@",getStatusDevice.requestId);

                if (self.delegate && [self.delegate respondsToSelector:@selector(mqttPublishFail:)]) {
                    [self.delegate mqttPublishFail:@""];
                }
            }
            
        }
    }
}
-(void)checkPublishSucess:(NSTimer *)timer{
    NSLog(@"checkPublishSucess timer");
    NSDictionary *userInfo = timer.userInfo;
    if (userInfo) {
        NSString *mqttId = [userInfo objectForKey:@"mqttId"];
        NSString *topic = [userInfo objectForKey:@"topic"];
        
        if ([mqttId containsString:@"WT3"]) {
            NSLog(@"testOfflineWifi2 %@",mqttId);
        }
        if (mqttId && self.publishingTopic.count > 0) {
            if ([self.publishingTopic containsObject:mqttId]) {
                NSString *message = [userInfo objectForKey:@"message"];
                NSInteger type = [[userInfo objectForKey:@"type"] integerValue];
                int count  = [[userInfo objectForKey:@"count"] intValue];
                NSLog(@"publish failed message : %@",mqttId);
                [self removePublishingTopic:mqttId];
                if (count < SEND_REQUEST_COUNT) {
                    count = count + 1;
                    
                    [self publishControl:mqttId topic:topic message:message type:type count:count complete:^(BOOL finished) {
                        
                    }];
                    
                }else{
                    if ([mqttId containsString:@"WT3"]) {
                        NSLog(@"testOfflineWifi3 %@",mqttId);
                    }
                    
                    NSString *cmd = [self getCmdFromMessage:message];
                    
                    Device *getStatusDevice = [[ CoredataHelper sharedInstance] getDeviceByTopic:topic];
                    if (getStatusDevice) {
                        getStatusDevice.isOnline = false;
                        getStatusDevice.isGetStatus = true;
                        [[CoredataHelper sharedInstance] save];
                        
                        
                    }
//                    if ([cmd isEqualToString:@"GETSTATUS"]) {
//                        if (self.delegate && [self.delegate respondsToSelector:@selector(mqttPublishFail:)]) {
//                            [self.delegate mqttPublishFail:@""];
//                        }
//
//                    }else{
                        if (self.delegate && [self.delegate respondsToSelector:@selector(mqttPublishFail:)]) {
                            [self.delegate mqttPublishFail:mqttId];
                        }
                        
//                    }
                }
            }else{
                NSLog(@"publish cmn roi : %@",mqttId);
            }
        }
    }else{
        NSLog(@"testOfflineWifi0 ");
        
        
        
    }
}
-(void)turnOffAllDevice:(NSString *)topic message:(NSString *)message type:(NSInteger)type{
    
}

-(void)checkFinishedProcess{
    NSLog(@"checkFinishedProcess %ld",self.countProcess);
    if (self.countProcess == 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(mqttFinishedProcess)]) {
            [self.delegate mqttFinishedProcess];
        }
    }
}
-(BOOL)isConnected{
    return _isConnect;
}
-(void)disconect{
    /*
     test clean session
     if(_session){
     [_session disconnect];
     }
     [self resetData];
     */
}
-(void)conect{
    if([[FirebaseHelper sharedInstance] isLogin]){
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        
        if(_session && appDelegate.internetActive && self.session.status != MQTTSessionStatusConnected && self.session.status != MQTTSessionStatusConnecting){
            _isConnecting = true;
            NSLog(@"connect::::");
            [_session connectAndWaitTimeout:30];
        }
    }
}
-(void)connected:(MQTTSession *)session{
    NSLog(@"connected");
    //    [self handleMQTTConnectionSucess];
}

-(void)connectionClosed:(MQTTSession *)session{
    NSLog(@"connectionClosed");
    [self resetData];
    
}

-(void)connectionError:(MQTTSession *)session error:(NSError *)error{
    NSLog(@"connectionError %@",error.description);
    [self resetData];
    [self handleMQTTConnectionError];
    
}

- (void)handleEvent:(MQTTSession *)session event:(MQTTSessionEvent)eventCode error:(NSError *)error{
    if (eventCode == MQTTSessionEventConnected){
        [self handleMQTTConnectionSucess];
    }else if (eventCode == MQTTSessionEventConnectionClosed){
        
    }else{
        [self resetData];
        [self handleMQTTConnectionError];
        
    }
    
}
-(void)connectionRefused:(MQTTSession *)session error:(NSError *)error{
    NSLog(@"connectionRefused");
    [self resetData];
    if (self.delegate && [self.delegate respondsToSelector:@selector(mqttDisConnect)]) {
        [self.delegate mqttDisConnect];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kMqttConnectToServer" object:nil userInfo:@{@"result":@"2"}];
}

-(void)connected:(MQTTSession *)session sessionPresent:(BOOL)sessionPresent{
    //    [self handleMQTTConnectionSucess];
    
    NSLog(@"connected :%@------- %@",_session.clientId,session.clientId );
    NSLog(@"connected :%d------- %d",_session.cleanSessionFlag,session.cleanSessionFlag );
    
}

-(void)handleMQTTConnectionError{
    [self resetData];
    if (self.delegate && [self.delegate respondsToSelector:@selector(mqttDisConnect)]) {
        [self.delegate mqttDisConnect];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kMqttConnectToServer" object:nil userInfo:@{@"result":@"3"}];
    //    [self conect];
    
}
-(void)handleMQTTConnectionSucess{
    NSLog(@"handleMQTTConnectionSucess");
    _isConnect = true;
    _isConnecting = false;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(mqttConnected)]) {
        NSLog(@"setListDevices cc");
        [self.delegate mqttConnected];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kMqttConnectToServer" object:nil userInfo:@{@"result":@"1"}];
    
}
- (void)newMessage:(MQTTSession *)session
              data:(NSData *)data
           onTopic:(NSString *)topic
               qos:(MQTTQosLevel)qos
          retained:(BOOL)retained
               mid:(unsigned int)mid {
    // this is one of the delegate callbacks
    NSString *message = [[NSString alloc] initWithData:data encoding:kCFStringEncodingUTF8];
    NSLog(@"newMessage %@: %@",topic,message);
    BOOL isValue = false;
    Controller *controller = [[CoredataHelper sharedInstance] getControllerById:topic];
    
    if ([message isNumber]) {
        if (controller && controller.type == DeviceTypeCurtain) {
            [self removePublishingTopic:topic];
            Device *getStatusDevice = [self getDeviceByTopic:topic];
            if (getStatusDevice) {
                getStatusDevice.isOnline = true;
            }
            if (self.delegate && [self.delegate respondsToSelector:@selector(mqttSetStateValueForDevice:value:)]) {
                isValue = true;
                [self.delegate mqttSetStateValueForDevice:topic value:[message floatValue]];
            }
        }
    }else{
        //        if([[Utils getDeviceType:topic] == DeviceTypeLightOnOff || [Utils getDeviceType:topic] == DeviceTypeCurtain || [Utils getDeviceType:topic] == DeviceTypeTouchSwitch]){
        if(controller){
            //            NSLog(@"newMessage : %@ :::: %ld",controller.id,controller.type);
            if ([message containsString:@"TIMERSTATUS"]) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(mqttSetStateValueForTimer:)]) {
                    [self.delegate mqttSetStateValueForTimer:message];
                }
                
            }else if ([message containsString:@"STATUS"]){
                
                NSArray *tmp = [message componentsSeparatedByString:@"'"];
                
                if (tmp.count > 5) {
                    NSString *value = tmp[5];
                    NSString *mqttId = tmp[1];
                    NSLog(@"message 1: %@",message);

                    if ([value isEqualToString:@"1,2,0"] || [value isEqualToString:@"1,2,1"]) {
                        //den
                        [self removePublishingTopic:mqttId];
                        [self cancelCheckPublishTimerByMqttId:mqttId];
                        Device *getStatusDevice = [[CoredataHelper sharedInstance] getDeviceByTopic:mqttId type:DeviceTypeLightOnOff];
                        if (getStatusDevice != nil) {
                            if ([value isEqualToString:@"1,2,1"]) {
                                getStatusDevice.state = NO;
                            }else if([value isEqualToString:@"1,2,0"]){
                                getStatusDevice.state = YES;
                                
                            }
                            getStatusDevice.isGetStatus = true;
                            getStatusDevice.isOnline = true;
                            [[CoredataHelper sharedInstance] save];
                            [self cancelCheckPublishTimerByMqttId:mqttId];
                            
                        }
                        if (self.delegate && [self.delegate respondsToSelector:@selector(mqttSetStateValueForLight:)]) {
                            isValue = true;
                            [self.delegate mqttSetStateValueForLight:message];
                            
                        }
                    }else if ([value containsString:@"W"]){
                        //touch switch
                        NSLog(@"message 2: %@",message);
                        if([mqttId containsString:@"/"]){
                            NSString *topic = [tmp[1] componentsSeparatedByString:@"/"].firstObject;
                            NSString *chanel = [tmp[1] componentsSeparatedByString:@"/"].lastObject;
                            
                            [self removePublishingTopic:mqttId];
                            [self removePublishingTopic:topic];//get status
                            [self cancelCheckPublishTimerByMqttId:mqttId];
                            NSLog(@"publish cmn roi 2:%@",mqttId);
                            Device *getStatusDevice = [self getDeviceByTopic:topic];
                            
                            
                            if (getStatusDevice) {
                                if (chanel.length > 0 && [chanel isNumber]) {
                                    int numberIndex = [chanel intValue];
                                    [getStatusDevice updateStatusForChanel:numberIndex value:value];
                                    
                                }
                                getStatusDevice.isGetStatus = true;
                                getStatusDevice.isOnline = true;
                                [[CoredataHelper sharedInstance] save];
                                [self cancelCheckPublishTimerByMqttId:mqttId];
                                
                            }
                        }
                        if (self.delegate && [self.delegate respondsToSelector:@selector(mqttSetStateValueForLight:)]) {
                            [self.delegate mqttSetStateValueForLight:message];
                        }
                    }else if([value isNumber])
                    {
                        //rem
                        [self removePublishingTopic:mqttId];
                        [self cancelCheckPublishTimerByMqttId:mqttId];
                        Device *getStatusDevice = [self getDeviceByTopic:tmp[1]];
                        if (getStatusDevice) {
                            getStatusDevice.isGetStatus = true;
                            getStatusDevice.isOnline = true;
                            getStatusDevice.value = [value floatValue];
                            [[CoredataHelper sharedInstance] save];
                            [self cancelCheckPublishTimerByMqttId:mqttId];
                        }
                        if (self.delegate && [self.delegate respondsToSelector:@selector(mqttSetStateValueForLight:)]) {
                            [self.delegate mqttSetStateValueForLight:message];
                        }
                        
                    }
                }else{
                    //device is not respne
                    NSLog(@"device is not response %@ --- %@",message,tmp[1]);
                    Device *getStatusDevice = [self getDeviceByTopic:tmp[1]];
                    NSString *mqttId = [MessagesUtils getMqttIdFromMessage:message];
                    [self removePublishingTopic:mqttId];

                    if (getStatusDevice) {
                        getStatusDevice.isGetStatus = true;
//                        getStatusDevice.isOnline = false;

                        [[CoredataHelper sharedInstance] save];
                        if (self.delegate && [self.delegate respondsToSelector:@selector(mqttPublishFail:)]) {
                            [self.delegate mqttPublishFail:@""];
                        }
                    }
                    
                    
                    
                }
                
                
                
            }else if ([message containsString:@"ADD"]){
                if (self.delegate && [self.delegate respondsToSelector:@selector(mqttAddSuccess)]) {
                    [self.delegate mqttAddSuccess];
                }
            }else if ([message containsString:@"DELOK"]){
                // id=‘xxxx’ cmd=‘DELOK’
                if (self.delegate && [self.delegate respondsToSelector:@selector(mqttDelSuccess)]) {
                    NSArray *tmp = [message componentsSeparatedByString:@"'"];
                    NSString *mqttId = tmp[1];
                    if (mqttId && mqttId.length > 0) {
                        [[FirebaseHelper sharedInstance] delleteDevice:mqttId];
                        [[FirebaseHelper  sharedInstance] delleteDeviceInSystem:mqttId];
                    }
                    if ([tmp containsObject:@"DELOK"]) {
                        [self.delegate mqttDelSuccess];
                    }
                }
                
            }
        }
    }
    if (!isValue) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(mqttPublishFail:)]) {
            isValue = true;
            //            [self.delegate mqttPublishFail];
        }
    }
}
-(void)clearPublishTopic:(NSString *)topic{
//    if (self.publishedTopic) {
//        [self.publishedTopic removeObject:topic];
//    }
    if (self.publishingTopic) {
        [self.publishingTopic removeObject:topic];
    }
}

-(void)removePublishingTopic:(NSString *)mqttId{
    
    if (self.publishingTopic) {
        for (NSString *mqtt in self.publishingTopic) {
            NSLog(@"removePublishingTopic %@ :: %@",mqtt,mqttId);
            if ([mqtt isEqualToString:mqttId]) {
                NSLog(@"removePublishingTopic $$$$$$$$$$");
                
            }
        }
        
        [self.publishingTopic removeObject:mqttId];
    }
    
}


-(void)resetData{
    NSLog(@"cleardata 0");
    
    _isConnect = false;
    _isConnecting = false;
  
}
-(NSString *)getCmdFromMessage:(NSString *)message{
    NSArray *tmp = [message componentsSeparatedByString:@"'"];
    if (tmp != NULL && tmp.count > 3) {
        return tmp[3];
    }
    return @"";
}

-(void)cancelCheckPublishTimerByMqttId:(NSString *)mqttid{
    NSTimer *timer = [_sucessTimerArr objectForKey:mqttid];
    NSLog(@"checkPublishSucess : cancelCheckPublish %@",mqttid);
   
    if (timer != NULL) {
        [timer invalidate];
        [_sucessTimerArr removeObjectForKey:mqttid];
        if ([mqttid containsString:@"0000000003"]) {
            NSLog(@"checkPublishSucess : touchswitch");
        }
    }
    for (NSString *key in _sucessTimerArr.allKeys) {
        if ([key containsString:@"0000000003"]) {
            NSLog(@"checkPublishSucess : touchswitch");
        }
    }
}

-(void)subscribeToTopicSuccess:(NSNotification *)notif{
    NSDictionary *userInfo = notif.userInfo;
    if (userInfo) {
        Device *device = userInfo[@"device"];
        [self publicRequestStatus:device];
    }
}
@end

