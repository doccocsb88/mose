//
//  CoredataHelper.h
//  SmartHome
//
//  Created by Apple on 3/27/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Room+CoreDataClass.h"
#import "Device.h"
#import "Scene.h"
#import "SHTimer+CoreDataProperties.h"
#import "Utils.h"
#import "NSString+Utils.h"
#import "Controller.h"
@interface CoredataHelper : NSObject
@property (strong, nonatomic) NSManagedObjectContext *context;
+ (instancetype)sharedInstance;
-(void)initRoomData;
-(void)addNewController:(NSString *)controllerId name:(NSString *)name order:(NSInteger)order type:(NSInteger)type code:(NSString *)code key:(NSString *)key complete:(void(^)(BOOL complete, Controller * room))complete;
-(NSArray *)getListcontroller;
-(NSArray *)getListcontrollerBytype:(NSInteger)type;
-(Controller *)getControllerById:(NSString *)controllerId;
-(NSInteger)countController:(NSInteger)type;
-(BOOL)hasController:(NSString *)controllerId;
/**/
- (Room *)addNewRoom:(NSString *)_id name:(NSString *)name parentId:(NSString *)parentId complete:(void(^)(BOOL complete, Room * room))complete;
- (Room *)addNewRoomV2:(NSString *)_id key:(NSString *)key name:(NSString *)name code:(NSString *)code order:(NSInteger)order complete:(void(^)(BOOL))complete;

-(Device *)addNewDevice:(NSString *)token name:(NSString *) name deviceId:(NSInteger )_id state:(BOOL)value value:(NSInteger)value requestId:(NSString *)requestId topic:(NSString *)topic  type:(NSInteger)type complete:(void(^)(Device * device))complete;
-(Device *)addNewDevice:(NSString *)token name:(NSString *) name deviceId:(NSInteger )_id topic:(NSString *)topic control:(BOOL)control state:(BOOL)state value:(NSInteger)value mqttId:(NSString *)mqttId type:(NSInteger)type order:(NSInteger)order complete:(void(^)(Device * device))complete;
-(SHTimer *)addTimer;
-(SHTimer *)getTimerByCode:(NSString *)code;
-(NSArray *)getListRoom;
-(NSArray *)getListDevice;
-(NSArray *)getListDeviceByRoom:(NSInteger)roomId;
-(Room *)getRoomByid:(NSInteger)roomId;
-(Room *)getRoomByCode:(NSString *)code;

-(NSArray *)getListTimerByDeviceId:(NSInteger )deviceId;
-(NSArray *)getListTimers;
-(NSArray *)getListTimerByRequestId:(NSString *)requestId;

-(NSInteger )countDevice;
-(void)deleteDevice:(Device *)device;
-(void)deleteDetail:(SceneDetail *)detail;
-(Device *)getDeviceByTopic:(NSString *)topic;
-(Device *)getDeviceByTopic:(NSString *)topic type:(NSInteger)type;
-(Device *)getDeviceById:(NSInteger )id;
-(Device *)getDeviceBycode:(NSString *)code;
-(Device *)getDeviceByMqttId:(NSString *)mqttId;

//
-(NSArray *)getListScene;
-(Scene *)getSceneByCode:(NSString *)code;
-(Scene *)getSceneById:(NSInteger )id;

-(void)addNewScene:(NSInteger)_id name:(NSString *)name complete:(void(^)(Scene * room))complete;
-(void)addNewSceneV2:(NSInteger)_id name:(NSString *)name code:(NSString *)code complete:(void(^)(Scene * room))complete;

-(NSArray *)getAllSceneDetail;
-(SceneDetail *)addSceneDetail:(NSInteger)_id value:(NSInteger) value status:(BOOL)status device:(Device *)device complete:(void(^)(SceneDetail * detail))complete;
-(SceneDetail *)addSceneDetailV2:(NSInteger)_id key:(NSString *)key value:(NSInteger) value status:(NSInteger)status device:(Device *)device code:(NSString *)code complete:(void(^)(SceneDetail * detail))complete;
-(SceneDetail *)getSceneDetailByCode:(NSString *)code;
-(void)deleteDetailByDeviceId:(NSInteger )deviceId;
-(void)deleteTimerByDeviceId:(NSString *)requestId;
-(void)deleteTimerByCode:(NSString *)code;
-(void)deleteRoomByCode:(NSString *)code;
-(void)deleteRoom:(Room *)room;
-(void)deleteSceneCode:(NSString *)code;
-(void)deleteSceneDetailByCode:(NSString *)code;
-(BOOL)hasObject:(NSString *)name code:(NSString *)code;
-(BOOL)hasDevice:(NSString *)mqttId;
-(void)clearData;
-(void)save;
@end

