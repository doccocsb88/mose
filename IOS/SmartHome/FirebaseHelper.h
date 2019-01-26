//
//  FirebaseHelper.h
//  SmartHome
//
//  Created by Apple on 1/7/18.
//  Copyright © 2018 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "SHMember.h"
#import "CoredataHelper.h"
#import "MQTTService.h"
#import "Utils.h"
@import Firebase;
@import FirebaseAuth;
typedef enum LoginType : NSUInteger {
    LoginTypeFacebook,
    LoginTypeGoogle
} LoginType;
@interface FirebaseHelper : NSObject
typedef void (^FirebaseLoginCallback)(FIRUser * user, Boolean isNew);
typedef void (^FirebaseMemberCallback)(NSArray * members);
typedef void (^FirebaseCallback)(BOOL exist);

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) FIRUser *user;
@property (assign, nonatomic) LoginType loginType;
+ (instancetype)sharedInstance;
-(void)logout;
-(void)loginDemo:(nullable FirebaseLoginCallback)completion;
-(void)loginWithCredential:(nullable FIRAuthCredential *)credential loginType:(LoginType)loginType completion:(nullable FirebaseLoginCallback)completion;
//-(void)loginWithEmail:(NSString *)email password:(NSString *)password completion:(nullable FirebaseLoginCallback)completion;
-(NSString *)getUid;
-(BOOL)isLogin;
-(BOOL)isAdmin;
-(void)getProfileInfo:(nullable FirebaseLoginCallback)completion;
-(void)synMemberList:(nullable FirebaseMemberCallback)completion;
-(void)shareDevice:(NSString *)mqttId forUser:(NSString *)key;
-(void)updateMemberShareStatus:(BOOL)status name:(NSString *)name devices:(NSString *)device uid:(NSString *)uid key:(NSString *)key;
/**/
-(void)addController:(Controller *)controller;
/**/
-(void)addRoom:(Room *)room;
-(void)updateRoom:(Room *)room;
-(void)deleteRoom:(NSString *)code;
//
-(void)addScene:(Scene *)scene;
-(void)updateScene:(Scene *)scene;
-(void)deleteScene:(NSString *)code;
//
-(void)addSceneDetail:(SceneDetail *)sceneDetail sceneId:(NSInteger )sceneId;
-(void)updateSceneDetail:(SceneDetail *)sceneDetail sceneId:(NSInteger )sceneId;
-(void)deleteSceneDetail:(NSString *)code;
-(void)deleteSceneDetailByDeviceId:(NSInteger )deviceId;
//
-(void)addDevice:(Device *)device roomId:(NSInteger)roomId;
-(void)updateDevice:(Device *)device roomId:(NSInteger)roomId;
//
-(void)addTimer:(SHTimer *)timer deviceId:(NSInteger)deviceId complete:(void(^)(NSString *key))complete;
-(void)addDeviceToSystem:(NSString *)mqttId;
-(void)delleteDevice:(NSString *)mqttId;
-(void)deleteDevidesInRoom:(NSString *)roomId;
-(void)delleteDeviceInSystem:(NSString *)mqttId;
-(void)hasDeviceInSystem:(NSString *)mqttId completion:(nullable FirebaseCallback)completion;
-(void)clearData:(nullable FirebaseCallback)completion;
-(void)requestMember:(NSString *)adminUid completion:(nullable FirebaseCallback)completion;;
-(void)isMemberOf:(NSString *)adminUid completion:(nullable FirebaseCallback)completion;
-(void)deleteMember:(SHMember *)user;
@end

