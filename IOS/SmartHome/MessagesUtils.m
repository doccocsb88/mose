//
//  MessagesUtils.m
//  SmartHome
//
//  Created by Macintosh HD on 9/13/18.
//  Copyright © 2018 Apple. All rights reserved.
//

#import "MessagesUtils.h"

@implementation MessagesUtils
+(NSString *)getMqttIdFromMessage:(NSString *)mqttMessage{
    NSArray *tmp = [mqttMessage componentsSeparatedByString:@"'"];
    if(tmp != NULL && tmp.count > 1){
        if([tmp[1] containsString:@"/"]){
            //touchswitch
            NSString *topic = [tmp[1] componentsSeparatedByString:@"/"].firstObject;
            return topic;
        }
        return tmp[1];
    }
    return NULL;
}

+(BOOL)isTouchSwitchQrCodeValidate:(NSString *)qrcode{
    if ([qrcode containsString:@";"]) {
        NSArray *info = [qrcode componentsSeparatedByString:@";"];
        NSString *cmdPrefix = info[0];
        if ([cmdPrefix isEqualToString:@"controller"]) {
            return true;
        }else if([cmdPrefix isNumber]){
            if([cmdPrefix integerValue] >= 1 && [cmdPrefix integerValue] <= 4){
                NSInteger deviceType = [cmdPrefix integerValue];
                NSString *topic = [info[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                
                if (deviceType == DeviceTypeTouchSwitch){
                    if ([topic containsString:@"-"]){
                        NSString *touchswitchPrefix = [topic componentsSeparatedByString:@"-"][0];
                        if(touchswitchPrefix.length == 3 && [touchswitchPrefix containsString:@"WT"]){
                            NSString *lastChar = [touchswitchPrefix substringFromIndex:touchswitchPrefix.length - 1];
                            if ([lastChar isNumber]) {
                                NSInteger touchswitchNumber = [lastChar integerValue];
                                if(touchswitchNumber >=1 && touchswitchNumber <= 4){
                                    return true;
                                }
                            }
                        }
                    }
                    
                    
                }else if (deviceType == DeviceTypeCurtain){
                    if ([topic containsString:@"-"]) {
                        NSString *curtainPrefix = [topic componentsSeparatedByString:@"-"][0];
                        if ([curtainPrefix isEqualToString:@"WC"]) {
                            return true;
                        }
                    }
                }
            }
        }
    }
    
    return false;

}
@end
