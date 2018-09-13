//
//  Member.h
//  SmartHome
//
//  Created by Apple on 1/8/18.
//  Copyright © 2018 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FirebaseHelper.h"
@interface SHMember : NSObject
@property (strong,nonatomic) NSString *key;
@property (strong,nonatomic) NSString *displayname;
@property (strong,nonatomic) NSString *devices;
@property (strong,nonatomic) NSString *rooms;
@property (strong,nonatomic) NSString *uid;
@property (assign,nonatomic) BOOL accept;
-(void)shareDevice:(NSString *)mqttId;
-(void)unShareDevice:(NSString *)mqttId;
-(void)updateShareDeviceForMember;
-(void)updateShareStatus;
@end
