//
//  BaseService.h
//  SmartHome
//
//  Created by Apple on 3/13/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>
#define API_LED3 @"POST https://api.thinger.io/v2/users/ROLLERTECH/devices/ESP8266/led3"
#define API_LED1 @"POST https://api.thinger.io/v2/users/ROLLERTECH/devices/ESP8266/led1"
#define API_LED2 @"POST https://api.thinger.io/v2/users/ROLLERTECH/devices/ESP8266/led2"

@interface BaseServicez : NSObject
//@property (strong, nonatomic) NSString *deviceToken;
@property (strong, nonatomic) NSString *access_token;
@property (strong, nonatomic) NSString *refresh_token;
@property (strong, nonatomic) NSString *token_type;
@property (strong, nonatomic) NSString *scope;
@property (strong, nonatomic) NSString *expires_in;
+ (instancetype)sharedInstance;

-(void)getToken;
-(void)getDeviceStatus:(NSString *)name complete:(void (^)(bool status))finishBlock;
-(void)post:(BOOL)onOff deviceName:(NSString *)deviceName;
-(void)get;
@end
