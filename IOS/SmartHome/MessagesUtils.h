//
//  MessagesUtils.h
//  SmartHome
//
//  Created by Macintosh HD on 9/13/18.
//  Copyright © 2018 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessagesUtils : NSObject
+(NSString *)getMqttIdFromMessage:(NSString *)mqttMessage;
@end
