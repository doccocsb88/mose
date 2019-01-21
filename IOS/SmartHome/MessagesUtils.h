//
//  MessagesUtils.h
//  SmartHome
//
//  Created by Macintosh HD on 9/13/18.
//  Copyright © 2018 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+Utils.h"
#import "Device.h"
@interface MessagesUtils : NSObject
+(NSString *)getMqttIdFromMessage:(NSString *)mqttMessage;
+(BOOL)isTouchSwitchQrCodeValidate:(NSString *)qrcode;
@end
