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
        return tmp[1];
    }
    return NULL;
}
@end
