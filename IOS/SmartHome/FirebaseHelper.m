//
//  FirebaseHelper.m
//  SmartHome
//
//  Created by Apple on 1/7/18.
//  Copyright © 2018 Apple. All rights reserved.
//

#import "FirebaseHelper.h"
#import "NSString+Utils.h"
@implementation FirebaseHelper
+ (instancetype)sharedInstance
{
    static FirebaseHelper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[FirebaseHelper alloc] init];
        // Do any other initialisation stuff here
        sharedInstance.ref = [[FIRDatabase database] reference];
    });
    return sharedInstance;
}
-(NSString *)getAccessNode{
    if([User sharedInstance].accountType == AccountTypeAdmin){
        //admin
        return self.user.uid;
    }else if([User sharedInstance].accountType == AccountTypeMember){
        return [User sharedInstance].node;
    }
    return @"";
}
-(void)initObserver{
    NSString *accessNode  = [self getAccessNode];
    NSLog(@"synData accessNode : %@",accessNode);
    if (accessNode == nil || accessNode.length == 0) {
        return;
    }
    if (self.user && self.user.uid) {
        [[[[self.ref child:@"users"] child:accessNode] child:@"timers"] observeEventType:FIRDataEventTypeChildRemoved withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            if (snapshot && snapshot.value) {
                NSLog(@"initObserver : %@",snapshot.value);
                NSLog(@"initObserver : %@",snapshot.value);
                NSDictionary *dict = snapshot.value;
                if ([dict objectForKey:@"timer_code"]) {
                    NSString *code = [dict objectForKey:@"timer_code"];
                    [[CoredataHelper sharedInstance] deleteTimerByCode:code];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"kFirebaseRemoveTimer" object:nil userInfo:nil];

                }
            }
        }];
        [[[[self.ref child:@"users"] child:accessNode] child:@"devices"] observeEventType:FIRDataEventTypeChildRemoved withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            if (snapshot && snapshot.value) {
                NSLog(@"initObserver : %@",snapshot.value);
                NSDictionary *dict = snapshot.value;
                if ([dict objectForKey:@"device_mqtt_id"]) {
                    NSString *mqttid = [dict objectForKey:@"device_mqtt_id"];
                    Device *device = [[CoredataHelper sharedInstance] getDeviceBycode:mqttid];
                    if (device) {
                        [[CoredataHelper sharedInstance] deleteDevice:device];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"kFirebaseRemoveDevice" object:nil userInfo:nil];

                    }
                }
            }
        }];
        [[[[self.ref child:@"users"] child:accessNode] child:@"rooms"] observeEventType:FIRDataEventTypeChildRemoved withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            if (snapshot && snapshot.value) {
                NSLog(@"initObserver : %@",snapshot.value);
                NSDictionary *dict = snapshot.value;
                if ([dict objectForKey:@"room_code"]) {
                    NSString *code = [dict objectForKey:@"room_code"];
                    [[CoredataHelper sharedInstance] deleteRoomByCode:code];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"kFirebaseRemoveRoom" object:nil userInfo:nil];

                }
            }
        }];
        [[[[self.ref child:@"users"] child:self.user.uid] child:@"scenes"] observeEventType:FIRDataEventTypeChildRemoved withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            if (snapshot && snapshot.value) {
                NSLog(@"initObserver : %@",snapshot.value);
                
                NSDictionary *dict = snapshot.value;
                if ([dict objectForKey:@"scene_code"]) {
                    NSString *code = [dict objectForKey:@"scene_code"];
                    [[CoredataHelper sharedInstance] deleteSceneCode:code];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"kFirebaseRemoveScene" object:nil userInfo:nil];

                }
            }
        }];
        [[[[self.ref child:@"users"] child:self.user.uid] child:@"scene_details"] observeEventType:FIRDataEventTypeChildRemoved withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            if (snapshot && snapshot.value) {
                NSLog(@"initObserver : %@",snapshot.value);
                NSDictionary *dict = snapshot.value;
                if ([dict objectForKey:@"scene_details_code"]) {
                    NSString *code = [dict objectForKey:@"scene_details_code"];
                    [[CoredataHelper sharedInstance] deleteSceneDetailByCode:code];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"kFirebaseRemoveSceneDetail" object:nil userInfo:nil];

                }
            }
        }];
    }
}
-(void)loginDemo:(nullable FirebaseLoginCallback)completion{
    [[FIRAuth auth] signInWithEmail:@"anhhai@a.com" password:@"aaaaaa" completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
        completion(user,true);
    }];
}
-(void)loginWithCredential:(FIRAuthCredential *)credential loginType:(LoginType)loginType completion:(nullable FirebaseLoginCallback)completion{
    __weak FirebaseHelper  *wSelf = self;
    [[FIRAuth auth] signInWithCredential:credential completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
        if (user) {
            NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
            [pref setObject:[@"" randomStringWithLength:32] forKey:@"mqttClientId"];
            [pref synchronize];
            wSelf.loginType = loginType;
            [wSelf getProfileInfo:^(FIRUser *user, Boolean isNew) {
                completion(user,isNew);

            }];
        }else{
            completion(user,false);

        }
    }];
}
//-(void)loginWithEmail:(NSString *)email password:(NSString *)password completion:(nullable FirebaseLoginCallback)completion{
//    [[FIRAuth auth] createUserWithEmail:email
//                               password:password
//                             completion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
//                                 // ...
//                                 completion(user,true);
//                             }];
//    
//}
-(void)logout{
    NSError *signOutError;
    BOOL status = [[FIRAuth auth] signOut:&signOutError];
    if (!status) {
        NSLog(@"Error signing out: %@", signOutError);
        return;
    }else{
        NSLog(@"Successfully Signout");
        [[CoredataHelper sharedInstance] clearData];
    }
//    [[CoredataHelper sharedInstance] initRoomData];
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref removeObjectForKey:@"mqttClientId"];
    [pref synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kFirebaseLogout" object:nil userInfo:nil];
}
-(NSString *)getUid{
    if (self.user == NULL) {
        self.user = [FIRAuth auth].currentUser;
    }
    return self.user.uid;
}
-(BOOL)isLogin{
    if ([FIRAuth auth].currentUser && [FIRAuth auth].currentUser.uid) {
        return YES;
    }
    return NO;
}
-(BOOL)isAdmin{
    if ([self isLogin]) {
        return [User sharedInstance].accountType == AccountTypeAdmin;
    }
    return NO;
}
-(void)getProfileInfo:(nullable FirebaseLoginCallback)completion{
    if ([FIRAuth auth].currentUser) {
        // User is signed in.
        // ...
        __weak FirebaseHelper *wself = self;
        _user = [FIRAuth auth].currentUser;
        NSString *uid = _user.uid;
        NSString *profilePath = [NSString stringWithFormat:@"/users/%@/profile",uid];
        NSLog(@"getProfileInfo %@",profilePath);

        [[self.ref child:profilePath] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            if(snapshot && [snapshot.value isKindOfClass:[NSNull class]] == false){
                NSLog(@"getProfileInfo: %@",snapshot.value);
                [[User sharedInstance] setData:snapshot];
                [self initObserver];

                if ([[User sharedInstance] isAuthentication]) {
                    [wself synData];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [wself synSceneData];
                    });
                    completion(_user,false);

                }
            }else{
                NSLog(@"writeUser");
                [wself writeUser];
                completion(_user,true);
            }
            
           
        }];
        
    } else {
        // No user is signed in.
        // ...
    }
    
}
-(void)writeUser{
    User *newUser = [User sharedInstance];
    if (newUser.email == NULL || newUser.email.length == 0) {
        return;
    }
    NSDictionary *dic = @{
                          @"displayName":newUser.displayName?newUser.displayName:@"",
                          @"email":newUser.email?newUser.email:@"",
                          @"username":newUser.username?newUser.username:@"",
                          @"active":[NSNumber numberWithInteger:true],
                          @"accountType":[NSNumber numberWithInteger:newUser.accountType],
                         };

    NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/users/%@/profile", self.user.uid]: dic};
    [_ref updateChildValues:childUpdates];
}
-(void)synData{
    NSString *accessNode  = [self getAccessNode];
    NSLog(@"synData accessNode : %@",accessNode);
    if (accessNode == nil || accessNode.length == 0) {
        return;
    }
    [[[[self.ref child:@"users"] child:accessNode] child:@"controllers"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        //
        if(snapshot && snapshot.value){
            for(FIRDataSnapshot *data in [snapshot children]){
                NSDictionary *info = data.value;

                NSString *controllerId = [info objectForKey:@"id"];
                NSString *code = [info objectForKey:@"code"];
                NSString *name = [info objectForKey:@"name"];
                NSInteger order = 0;
                if ([info objectForKey:@"order"]) {
                    order = [[info objectForKey:@"order"] integerValue];
                }
                NSInteger type = 0;
                if ([info objectForKey:@"type"]) {
                    type = [[info objectForKey:@"type"] integerValue];
                }
                
                Controller *controller = [[CoredataHelper sharedInstance] getControllerById:controllerId];
                if (!controller) {
                    [[CoredataHelper sharedInstance] addNewController:controllerId name:name order:order ? order : 0 type:type code:code ? code : @"" key:data.key complete:^(BOOL complete, Controller *room) {
                        
                    }];
                }else{
                    controller.code = code;
                    controller.key = data.key;
                    controller.type = type;
                }
            }
           
        }
        [[CoredataHelper sharedInstance] save];

    }];
    [[[[self.ref child:@"users"] child:accessNode] child:@"rooms"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        //
        if(snapshot && snapshot.value){
            for(FIRDataSnapshot *data in [snapshot children]){
                NSDictionary *info = data.value;
                NSLog(@"synData rooms: %@",data.value);
                if([info objectForKey:@"room_code"]){
                    NSString *roomId = [info objectForKey:@"id"];
                    NSString *code = [info objectForKey:@"room_code"];
                    NSString *name = [info objectForKey:@"room_name"];
                    NSInteger order = [[info objectForKey:@"room_order"] integerValue];
                    if(![[CoredataHelper sharedInstance] hasObject:@"Room" code:code]){
                        [[CoredataHelper sharedInstance] addNewRoomV2:roomId key:data.key name:name code:code order:order complete:^(BOOL complete) {
                            if (complete) {
                              
                            }
                        }];
                    }else{
                        Room *room = [[CoredataHelper sharedInstance] getRoomByCode:code];
                        room.name = name;
                        room.order = order;
                        [[CoredataHelper sharedInstance] save];
                    }
                }
                
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kFirebasedidFinishSynRoom" object:nil userInfo:nil];
        }
    }];
    //
    [[[[self.ref child:@"users"] child:accessNode] child:@"devices"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        //
        if(snapshot && snapshot.value){
            for(FIRDataSnapshot *data in [snapshot children]){
                NSDictionary *info = data.value;
                NSLog(@"synData devices: %@",data.value);
                if([info objectForKey:@"device_mqtt_id"]){
                    NSString *mqttId = [info objectForKey:@"device_mqtt_id"];
                    NSInteger deviceId = [[info objectForKey:@"id"] integerValue];
                    NSString *name  = [info objectForKey:@"device_name"];
                    BOOL control = [[info objectForKey:@"device_control"] boolValue];
                    int type =  [[info objectForKey:@"device_type"] intValue];
                    NSInteger status =  [[info objectForKey:@"device_status"] integerValue];
                    NSString *topic = [info objectForKey:@"device_topic"];
                    NSInteger value = [[info objectForKey:@"device_value"] integerValue];
                    NSInteger order = [[info objectForKey:@"device_order"] integerValue];
                    NSInteger roomId = [[info objectForKey:@"deviceId"] integerValue];
                    NSString *chanelInfo = [info objectForKey:@"chanels"];
                    Room *room = [[CoredataHelper sharedInstance] getRoomByid:roomId];

                    if(![[CoredataHelper sharedInstance] hasDevice:mqttId]){
    
                        if (![[CoredataHelper sharedInstance] hasController:topic]) {
                            [[CoredataHelper sharedInstance] addNewController:topic name:topic order:0 type:type code:@"" key:@"" complete:^(BOOL complete, Controller *room) {
                                
                            }];
                        }
                        [[CoredataHelper sharedInstance] addNewDevice:topic name:name deviceId:deviceId topic:topic control:control state:status value:value mqttId:mqttId type:type order:order complete:^(Device *device) {
                            if (device) {
                                NSLog(@"AddDeviceFromFireBase : %@",device.name);
                                device.key = data.key;
                                device.chanelInfo = chanelInfo?chanelInfo:@"";
                                if (room && device) {
                                    [room addDevicesObject:device];
                                }
                            }
                        }];
                       
                    }else{

                        Device *device = [[CoredataHelper sharedInstance] getDeviceBycode:mqttId];
                        NSLog(@"updateDeviceFromFireBase : %@ --- %@",device.name,name);

                        if (device) {
                            device.name = name;
                            device.control = control;
                            device.chanelInfo = chanelInfo?chanelInfo:@"";
                            device.isOnline = true;
                        }
                        if (room) {
                            [room addDevicesObject:device];
                        }
//                        room add
                        [[CoredataHelper sharedInstance] save];

                    }
                }
                //                    deviceId = 1;
                //                    "device_control" = 1;
                //                    "device_mqtt_id" = B00026A1;
                //                    "device_name" = decice3;
                //                    "device_order" = 7;
                //                    "device_scene_status" = 0;
                //                    "device_scene_value" = 0;
                //                    "device_status" = 0;
                //                    "device_thumbnail" = 2131230915;
                //                    "device_topic" = "QA_HCL_123";
                //                    "device_type" = 2;
                //                    "device_value" = 0;
                //                    id = 5;
                //                    sceneId = 3;
                //                    Device
                
            }
        }
    }];
    [[[[self.ref child:@"users"] child:accessNode] child:@"timers"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        // days = "0:1:1:0:1:0:0";
        //            deviceId = 2;
        //            enable = 1;
        //            id = 3;
        //            repeat = 0;
        //            status = 0;
        //            time = "11 : 43";
        //            value = 0;
        if(snapshot && snapshot.value){
            for(FIRDataSnapshot *data in [snapshot children]){
                NSDictionary *info = data.value;
                NSLog(@"synData timers: %@",data.value);
                NSInteger deviceId = [[info objectForKey:@"deviceId"] integerValue];
//                Device *device = [[CoredataHelper sharedInstance] getDeviceById:deviceId];
                NSString *code = @"";
                if ([info objectForKey:@"timer_code"]) {
                    code = [info objectForKey:@"timer_code"];
                }
                NSString *requestId = [info objectForKey:@"requestId"];
                NSString *topic = [info objectForKey:@"topic"];
                int type = DeviceTypeUnknow;
                if ([info objectForKey:@"type"] != nil){
                    
                    type= [[info objectForKey:@"type"] intValue];
                }
                SHTimer *timer = [[CoredataHelper sharedInstance] getTimerByCode:code];
                BOOL hasTimer = NO;
                if (timer) {
                    hasTimer = YES;
                }else{
                    timer = [[CoredataHelper sharedInstance] addTimer];
                    //                    self.timer.enable = YES;
                    timer.requestId = requestId;
                    timer.type = type;
                    timer.topic = topic;
                    timer.deviceId = deviceId;
                    timer.code = code;
                    timer.key = data.key;
                }
                if ([info objectForKey:@"enable"]) {
                    timer.enable = [[info objectForKey:@"enable"] boolValue];
                }
                if([info objectForKey:@"value"]){
                    timer.value = [[info objectForKey:@"value"] integerValue];
                    
                }
                if([info objectForKey:@"status"]){
                    timer.status = [[info objectForKey:@"status"] boolValue];
                }
                if([info objectForKey:@"repeat"]){
                    
                }
                if([info objectForKey:@"time"]){
                    timer.timer =  [info objectForKey:@"time"];
                }
                if ([info objectForKey:@"timer_code"]) {
                    timer.code = [info objectForKey:@"timer_code"];
                }
                if ([info objectForKey:@"requestId"]) {
                    timer.requestId = [info objectForKey:@"requestId"];
                }
                [timer resetRepeat];
                NSArray *days = [[info objectForKey:@"days"] componentsSeparatedByString:@":"];
                for (int i = 0; i < days.count;i++) {
                    NSString *day = days[i];
                    if ([day isEqualToString:@"1"]) {
                        
                        switch (i) {
                            case 0:
                                timer.t2 = YES;
                                break;
                            case 1:
                                timer.t3 = YES;
                                
                                break;
                            case 2:
                                timer.t4 = YES;
                                
                                break;
                            case 3:
                                timer.t5 = YES;
                                
                                break;
                            case 4:
                                timer.t6 = YES;
                                
                                break;
                            case 5:
                                timer.t7 = YES;
                                
                                break;
                            case 6:
                                timer.t8 = YES;
                                break;
                            default:
                                break;
                        }
                    }
                }
                [[CoredataHelper sharedInstance] save];
                if (!hasTimer && [[User sharedInstance] isAdmin]) {
                    //will not call settimer when syn data from firebase
                   // [[MQTTService sharedInstance] setTimer:timer];
                }
            }
        }
    }];
    if ([User sharedInstance].accountType == AccountTypeMember) {
        [[[[[[self.ref child:@"users"] child:accessNode] child:@"members"] queryOrderedByChild:@"uid"] queryEqualToValue:self.user.uid] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            if (snapshot && snapshot.value) {
                FIRDataSnapshot *memberData = [[[snapshot children] allObjects] firstObject];
                [[User sharedInstance] setDevicesData:memberData];

            }
        }];
    }
}
-(void)synMemberList:(nullable FirebaseMemberCallback)completion{
    [[[[self.ref child:@"users"] child:[self getAccessNode]] child:@"members"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (snapshot && snapshot.value) {
            NSMutableArray *members = [NSMutableArray new];
            for(FIRDataSnapshot *data in [snapshot children]){
                
                NSLog(@"synMemberList : %@ %@",data.key,data.value);
                NSDictionary *info = data.value;
                SHMember *member = [[SHMember alloc] init];
                member.key = data.key;
                if ([info objectForKey:@"name"]) {
                    member.displayname = [info objectForKey:@"name"];
                }else{
                    member.displayname = @"Thành viên";
                }
                if ([info objectForKey:@"uid"]) {
                    member.uid = [info objectForKey:@"uid"];
                }
                if ([info objectForKey:@"accept"]) {
                    member.accept = [[info objectForKey:@"accept"] boolValue];
                }
                if ([info objectForKey:@"rooms"]) {
                    member.rooms = [info objectForKey:@"rooms"];
                }
            
                if ([info objectForKey:@"device"]) {
                    member.devices = [info objectForKey:@"device"];
                }else{
                    member.devices = @"";
                }
                [members addObject:member];
            }
            completion(members);
        }
    }];
}
-(void)synSceneData{
    [[[[self.ref child:@"users"] child:_user.uid] child:@"scenes"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if(snapshot && snapshot.value){
            for(FIRDataSnapshot *data in [snapshot children]){
                NSLog(@"synSceneData : %@",data.value);
                NSDictionary *info = data.value;
                NSString *code = @"";
                
                if([info objectForKey:@"scene_code"]){
                    code = [info objectForKey:@"scene_code"];
                    NSString *name = @"";
                    NSInteger sceneId = NSIntegerMax;
                    if([info objectForKey:@"scene_name"]){
                        name = [info objectForKey:@"scene_name"];
                    }
                    if([info objectForKey:@"id"]){
                        sceneId = [[info objectForKey:@"id"] integerValue];
                    }
                    if(![[CoredataHelper sharedInstance] hasObject:@"Scene" code:code]){
                        [[CoredataHelper sharedInstance] addNewSceneV2:sceneId name:name code:code complete:^(Scene *room) {
                            
                        }];
                        
                    }
                }
            }
            
        }
    }];
    [[[[self.ref child:@"users"] child:_user.uid] child:@"scene_details"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if(snapshot && snapshot.value){
            for(FIRDataSnapshot *data in [snapshot children]){
                NSLog(@"synSceneData scene_details: %@",data.value);
                NSDictionary *info = data.value;
                NSString *code = @"";
                //
                //                    "device_id" = 5;
                //                    "device_order" = 1;
                //                    "device_status" = 0;
                //                    "device_value" = 0;
                //                    id = 1;
                //                    sceneId = 2;
                //                    "scene_detail_code" = pj7it2ehmqkswls029p2zrjwqpmo7ea8;
                if([info objectForKey:@"scene_detail_code"]){
                    code = [info objectForKey:@"scene_detail_code"];
                    NSInteger deviceId = [[info objectForKey:@"device_id"] integerValue];
                    NSInteger detailId = [[info objectForKey:@"id"] integerValue];
                    NSInteger deviceStatus = [[info objectForKey:@"device_status"] integerValue];
                    NSInteger deviceValue = [[info objectForKey:@"device_value"] integerValue];
                    NSInteger sceneId = [[info objectForKey:@"sceneId"] integerValue];
                    NSString *chanels = [info objectForKey:@"chanels"];
//                    @"chanels":sceneDetail.chanels ? sceneDetail.chanels : @""

                    Device *device  = [[CoredataHelper sharedInstance] getDeviceById:deviceId];
                    if(![[CoredataHelper sharedInstance] hasObject:@"SceneDetail" code:code]){
                        SceneDetail *sceneDetail = [[CoredataHelper sharedInstance] addSceneDetailV2:detailId key:data.key value:deviceValue status:deviceStatus device:device code:code complete:^(SceneDetail *detail) {
                            if (detail) {
                                
                            }
                        }];
                        Scene *scene =  [[CoredataHelper sharedInstance] getSceneById:sceneId];
                        if(scene){
                            if (sceneDetail != nil) {
                                sceneDetail.chanels = chanels ? chanels :  @"";
                                [scene addSceneDetailObject:sceneDetail];
                            }
                            
                        }
                    }
                }
                
                
            }
            
        }
        [[CoredataHelper sharedInstance] save];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kFirebasedidFinishSynScene" object:nil userInfo:nil];

    }];
}
-(void)addController:(Controller *)controller{
    NSString *accessNode = [self getAccessNode];
    if (accessNode && accessNode.length > 0){
        NSString *key = [[[[self.ref child:@"users"] child:accessNode] child:@"controllers"] childByAutoId].key;
        NSDictionary *dic = @{@"id":[NSString stringWithFormat:@"%@",controller.id],@"code":controller.code,@"name":controller.name,@"order":[NSString stringWithFormat:@"%ld",controller.order],@"type":[NSString stringWithFormat:@"%ld",controller.type]};
        NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/users/%@/controllers/%@", self.user.uid, key]: dic};
        controller.key = key;
        [_ref updateChildValues:childUpdates];
    }
}
/**/
-(void)addRoom:(Room *)room{
    NSString *key = [[[[self.ref child:@"users"] child:self.user.uid] child:@"rooms"] childByAutoId].key;
    NSDictionary *dic = @{@"id":[NSString stringWithFormat:@"%ld",room.id],@"room_code":room.code,@"room_name":room.name,@"room_thumb":room.image,@"room_order":[NSString stringWithFormat:@"%ld",room.order]};
    NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/users/%@/rooms/%@", self.user.uid, key]: dic};
    room.key = key;
    [_ref updateChildValues:childUpdates];
}
-(void)updateRoom:(Room *)room{
    NSDictionary *dic = @{@"id":[NSString stringWithFormat:@"%ld",room.id],@"room_code":room.code,@"room_name":room.name,@"room_thumb":room.image,@"room_order":[NSString stringWithFormat:@"%ld",room.order]};
    NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/users/%@/rooms/%@", self.user.uid, room.key]: dic};
    [_ref updateChildValues:childUpdates];
}

-(void)deleteRoom:(NSString *)code{
    NSString *keyPath = [NSString stringWithFormat:@"users/%@/rooms",self.user.uid];
    [[[[self.ref child:keyPath] queryOrderedByChild:@"room_code"] queryEqualToValue:code] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (snapshot && snapshot.childrenCount > 0) {
            for(FIRDataSnapshot *data in [snapshot children]){
                [[[self.ref child:keyPath] child:data.key] removeValue];
            }
        }
    }];
}
-(void)addScene:(Scene *)scene{
    NSString *key = [[[[self.ref child:@"users"] child:self.user.uid] child:@"scenes"] childByAutoId].key;
    NSDictionary *dic = @{@"id":[NSString stringWithFormat:@"%ld",scene.id],@"scene_code":scene.code,@"scene_name":scene.name,@"scene_order":[NSString stringWithFormat:@"%ld",scene.order]};
    NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/users/%@/scenes/%@", self.user.uid, key]: dic};
    [_ref updateChildValues:childUpdates];
    
}
-(void)deleteScene:(NSString *)code{
    //    var ref = firebase.database(); //root reference to your data
//    ref.orderByChild('user_id').equalTo('-KTruPWrYO9WFj-TF8Ft')
//    .once('value').then(function(snapshot) {
//        snapshot.forEach(function(childSnapshot) {
//            //remove each child
//            ref.child(childSnapshot.key).remove();
//        });
//    });
    NSString *keyPath = [NSString stringWithFormat:@"users/%@/scenes",self.user.uid];
    [[[[self.ref child:keyPath] queryOrderedByChild:@"scene_code"] queryEqualToValue:code] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (snapshot && snapshot.childrenCount > 0) {
            for(FIRDataSnapshot *data in [snapshot children]){
                [[[self.ref child:keyPath] child:data.key] removeValue];
            }
        }
    }];
}
-(void)addSceneDetail:(SceneDetail *)sceneDetail sceneId:(NSInteger )sceneId{
    NSString *key = [[[[self.ref child:@"users"] child:self.user.uid] child:@"scene_details"] childByAutoId].key;
    NSDictionary *dic = @{
                          @"id":[NSNumber numberWithInteger:sceneDetail.id],
                          @"device_status":[NSNumber numberWithInteger:sceneDetail.status],
                          @"device_value":[NSNumber numberWithInteger:sceneDetail.value],
                          @"device_order":[NSNumber numberWithInteger:sceneDetail.device.order],
                          @"sceneId":[NSNumber numberWithInteger:sceneId],
                          @"device_id":[NSNumber numberWithInteger:sceneDetail.device.id],
                          @"scene_detail_code":sceneDetail.code,
                          @"chanels":sceneDetail.chanels ? sceneDetail.chanels : @""
                          };
    NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/users/%@/scene_details/%@", self.user.uid, key]: dic};
    sceneDetail.key = key;
    [_ref updateChildValues:childUpdates];
}
-(void)updateSceneDetail:(SceneDetail *)sceneDetail sceneId:(NSInteger )sceneId{
    NSDictionary *dic = @{
                          @"id":[NSNumber numberWithInteger:sceneDetail.id],
                          @"device_status":[NSNumber numberWithInteger:sceneDetail.status],
                          @"device_value":[NSNumber numberWithInteger:sceneDetail.value],
                          @"device_order":[NSNumber numberWithInteger:sceneDetail.device.order],
                          @"sceneId":[NSNumber numberWithInteger:sceneId],
                          @"device_id":[NSNumber numberWithInteger:sceneDetail.device.id],
                          @"scene_detail_code":sceneDetail.code,
                          @"chanels":sceneDetail.chanels ? sceneDetail.chanels : @""
                          };
    NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/users/%@/scene_details/%@", self.user.uid, sceneDetail.key]: dic};
    [_ref updateChildValues:childUpdates];
}
-(void)deleteSceneDetail:(NSString *)code{
    NSString *keyPath = [NSString stringWithFormat:@"users/%@/scene_details",self.user.uid];
    [[[[self.ref child:keyPath] queryOrderedByChild:@"scene_detail_code"] queryEqualToValue:code] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (snapshot && snapshot.childrenCount > 0) {
            for(FIRDataSnapshot *data in [snapshot children]){
                [[[self.ref child:keyPath] child:data.key] removeValue];
            }
        }
    }];
}

-(void)deleteSceneDetailByDeviceId:(NSInteger)deviceId{
    NSString *keyPath = [NSString stringWithFormat:@"users/%@/scene_details",self.user.uid];
    [[[[self.ref child:keyPath] queryOrderedByChild:@"device_id"] queryEqualToValue:@(deviceId)] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (snapshot && snapshot.childrenCount > 0) {
            for(FIRDataSnapshot *data in [snapshot children]){
                [[[self.ref child:keyPath] child:data.key] removeValue];
            }
        }
    }];
}
-(void)addDevice:(Device *)device roomId:(NSInteger)roomId{
    NSString *key = [[[[self.ref child:@"users"] child:self.user.uid] child:@"devices"] childByAutoId].key;
    //                    deviceId = 1;//roomid
    //                    "device_control" = 1;
    //                    "device_mqtt_id" = B00026A1;
    //                    "device_name" = decice3;
    //                    "device_order" = 7;
    //                    "device_scene_status" = 0;
    //                    "device_scene_value" = 0;
    //                    "device_status" = 0;
    //                    "device_thumbnail" = 2131230915;
    //                    "device_topic" = "QA_HCL_123";
    //                    "device_type" = 2;
    //                    "device_value" = 0;
    //                    id = 5;
    //                    sceneId = 3;
    NSInteger deviceId = device.id;
    
    NSDictionary *dic = @{@"id": [NSNumber numberWithInteger:deviceId],
                          @"device_control":[NSNumber numberWithBool:device.control],
                          @"device_mqtt_id":device.requestId,
                          @"device_name":device.name,
                          @"device_order":[NSNumber numberWithInteger:device.order],
                          @"device_status":[NSNumber numberWithInteger:device.state],
                          @"device_value":[NSNumber numberWithInteger:device.value],
                          @"device_topic":device.topic?device.topic:@"",
                          @"device_type":[NSNumber numberWithInteger:device.type],
                          @"deviceId":[NSNumber numberWithInteger:roomId],
                          @"chanels":device.chanelInfo?device.chanelInfo:@""
                          };
    NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/users/%@/devices/%@", self.user.uid, key]: dic};
    device.key = key;
    [_ref updateChildValues:childUpdates];
}
-(void)updateDevice:(Device *)device roomId:(NSInteger)roomId{
    NSString *key = device.key;

    NSDictionary *dic = @{@"id": [NSNumber numberWithInteger:device.id],
                          @"device_control":[NSNumber numberWithBool:device.control],
                          @"device_mqtt_id":device.requestId,
                          @"device_name":device.name,
                          @"device_order":[NSNumber numberWithInteger:device.order],
                          @"device_status":[NSNumber numberWithInteger:device.state],
                          @"device_value":[NSNumber numberWithInteger:device.value],
                          @"device_topic":device.topic,
                          @"device_type":[NSNumber numberWithInteger:device.type],
                          @"deviceId":[NSNumber numberWithInteger:roomId],
                          @"chanels":device.chanelInfo?device.chanelInfo:@""

                          };
    NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/users/%@/devices/%@", self.user.uid, key]: dic};
    [_ref updateChildValues:childUpdates];
}
-(void)addTimer:(SHTimer *)timer deviceId:(NSInteger)deviceId complete:(void (^)(NSString *))complete{
    
    
    NSString *key = @"";
    if (timer.key && timer.key.length > 0) {
        key = timer.key;
    }else{
        key = [[[[self.ref child:@"users"] child:[self getAccessNode]] child:@"timers"] childByAutoId].key;
    }
    NSDictionary *dic = @{@"deviceId":[NSNumber numberWithInteger:deviceId],
                          @"enable":[NSNumber numberWithBool:timer.enable],
                          @"repeat":[NSNumber numberWithBool:timer.isRepeat],
                          @"status":[NSNumber numberWithInteger:timer.status],
                          @"value":[NSNumber numberWithInteger:timer.value],
                          @"time":timer.timer,
                          @"days":[timer getDays],
                          @"requestId":timer.requestId,
                          @"timer_code":timer.code
                          };
    NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/users/%@/timers/%@", [self getAccessNode], key]: dic};
    [_ref updateChildValues:childUpdates withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        complete(key);
    }];
}

-(void)addDeviceToSystem:(NSString *)mqttId{
    NSString *key = mqttId;
    NSDictionary *dic = @{@"uid":self.user.uid};
    NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/devices/%@",key]: dic};
    [_ref updateChildValues:childUpdates];
}
-(void)delleteDeviceInSystem:(NSString *)mqttId{
    NSString *keypath  = [NSString stringWithFormat:@"/devices/%@",mqttId];
    [[self.ref child:keypath] removeValue];

}
-(void)delleteDevice:(NSString *)mqttId{
    //NSString *keypath  = [NSString stringWithFormat:@"/devices/%@",mqttId];
    NSString *keypath  = [NSString stringWithFormat:@"/users/%@/devices/%@",self.user.uid,mqttId];

    [[self.ref child:keypath] removeValue];

}
-(void)deleteDevidesInRoom:(NSString *)roomId{
    NSString *keypath  = [NSString stringWithFormat:@"/users/%@/devices",self.user.uid];
    [[[[self.ref child:keypath] queryOrderedByChild:@"deviceId"] queryEqualToValue:roomId] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (snapshot && snapshot.childrenCount > 0) {
            for(FIRDataSnapshot *data in [snapshot children]){
                [[[self.ref child:@"devices"] child:data.key] removeValue];
            }
        }
    }];

}
-(void)hasDeviceInSystem:(NSString *)mqttId completion:(FirebaseCallback)completion{
    NSString *keypath  = [NSString stringWithFormat:@"/devices/%@",mqttId];
//    [[self.ref child:keypath] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
//        NSString *record = snapshot.value;
//        NSLog(@"zbc : %@ --- %@",snapshot.key, snapshot.value);
//
//      
//    }];
    [[self.ref child:keypath] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (snapshot && [snapshot.value isEqual:[NSNull null]] == false) {
            completion(YES);
        }else{
            completion(NO);
        }
    }];
}
-(void)shareDevice:(NSString *)mqttId forUser:(NSString *)key{
    NSString *keypath = [NSString stringWithFormat:@"users/%@/members/%@/device",self.user.uid,key];
    [[self.ref child:keypath] setValue:mqttId];
}
-(void)updateMemberShareStatus:(BOOL)status name:(NSString *)name devices:(NSString *)devices uid:(NSString *)uid key:(NSString *)key{

NSDictionary *dic = @{@"accept":[NSNumber numberWithInteger:status],
                          @"device":devices,
                          @"name":name,
                          @"uid":uid
                          };
    NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/users/%@/members/%@", [self getUid], key]: dic};
    [self.ref updateChildValues:childUpdates];
}
-(void)clearData:(nullable FirebaseCallback)completion{
    NSString *controllerPath  = [NSString stringWithFormat:@"/users/%@/controller/",self.user.uid];

    NSString *devicesPath  = [NSString stringWithFormat:@"/users/%@/devices/",self.user.uid];
    NSString *roomsPath  = [NSString stringWithFormat:@"/users/%@/rooms/",self.user.uid];
    NSString *scenePath  = [NSString stringWithFormat:@"/users/%@/scenes/",self.user.uid];
    NSString *sceneDetailPath  = [NSString stringWithFormat:@"/users/%@/scene_details/",self.user.uid];
    NSString *timersPath  = [NSString stringWithFormat:@"/users/%@/timers/",self.user.uid];
    NSString *membersPath  = [NSString stringWithFormat:@"/users/%@/members/",self.user.uid];
    
    
    [[self.ref child:controllerPath] removeValue];
    [[self.ref child:devicesPath] removeValue];
    [[self.ref child:roomsPath] removeValue];
    [[self.ref child:scenePath] removeValue];
    [[self.ref child:sceneDetailPath] removeValue];
    [[self.ref child:timersPath] removeValue];
    [[self.ref child:membersPath] removeValue];
//    [[self.ref child:membersPath] removeValue];

    //
    [[[[self.ref child:@"devices"] queryOrderedByChild:@"uid"] queryEqualToValue:self.user.uid] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (snapshot && snapshot.childrenCount > 0) {
            for(FIRDataSnapshot *data in [snapshot children]){
                [[[self.ref child:@"devices"] child:data.key] removeValue];
            }
        }
    }];
//    if ([[User sharedInstance] getNode].length > 0) {
//        NSString *adminMemberPath = [NSString stringWithFormat:@"users/%@/members",[User sharedInstance].node];
//        [[[[self.ref child:adminMemberPath] queryOrderedByChild:@"uid"] queryEqualToValue:self.user.uid] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
//            if (snapshot && snapshot.childrenCount > 0) {
//                for(FIRDataSnapshot *data in [snapshot children]){
//                    
//                    [[[self.ref child:adminMemberPath] child:data.key] removeValue];
//                }
//            }
//            if (completion) {
//                completion(true);
//            }
//        }];
//
//    }else{
//        if (completion) {
//            completion(true);
//        }
//    }

}

-(void)requestMember:(NSString *)adminUid completion:(nullable FirebaseCallback)completion{
//accept:
//device: close
//name:
//rooms:
//uid:
    __weak FirebaseHelper *wSelf = self;
    [User sharedInstance].node = adminUid;
    User *newUser = [User sharedInstance];
    NSString *key = [[[[self.ref child:@"users"] child:adminUid] child:@"members"] childByAutoId].key;
    NSDictionary *dic = @{@"uid":[self getUid],@"accept":[NSNumber numberWithBool:YES],@"name":[User sharedInstance].displayName};
  
    NSDictionary *profiledic = @{
                          @"displayName":newUser.displayName?newUser.displayName:@"",
                          @"email":newUser.email?newUser.email:@"",
                          @"username":newUser.username?newUser.username:@"",
                          @"active":[NSNumber numberWithInteger:true],
                          @"accountType":[NSNumber numberWithInteger:AccountTypeMember],
                          @"node":adminUid
                          };
    NSDictionary *profileUpdates = @{[NSString stringWithFormat:@"/users/%@/profile/",self.user.uid]: profiledic};
    NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/users/%@/members/%@",adminUid,key]: dic};
    [_ref updateChildValues:profileUpdates];
    [_ref updateChildValues:childUpdates withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        if (error) {
            completion(false);
            return;
        }
        [wSelf synData];
        completion(true);
    }];
}
-(void)isMemberOf:(NSString *)adminUid completion:(nullable FirebaseCallback)completion{
    NSString *adminMemberPath = [NSString stringWithFormat:@"users/%@/members",adminUid];
    [[[[self.ref child:adminMemberPath] queryOrderedByChild:@"uid"] queryEqualToValue:self.user.uid] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (snapshot && snapshot.childrenCount > 0) {
            for(FIRDataSnapshot *data in [snapshot children]){
                
                completion(true);
                
            }
        }else{
            completion(false);
        }
    }];

}
-(void)deleteMember:(SHMember *)user{
    NSString *membersPath  = [NSString stringWithFormat:@"/users/%@/members/%@",self.user.uid,user.key ];
    [[_ref child:membersPath] removeValueWithCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        NSLog(@"deleteMember : %@",error ? error.localizedDescription : @"error");
    }];
}
@end

