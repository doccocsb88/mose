//
//  Utils.h
//  SmartHome
//
//  Created by Ngoc Truong on 7/10/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Device.h"
#import "Room+CoreDataClass.h"

@interface Utils : NSObject
+(DeviceType)getDeviceType:(NSString *)topic;

//+(BOOL)hasTopic:(NSString *)topic;
//+(void)setTopic:(NSString *)topic;
//+(NSString *)getTopic;
+(Room *)getRoomWithId:(NSInteger)roomid in:(NSArray *)arrs;
+(Room *)getRoomWithcode:(NSString *)code inData:(NSArray *)arrs;

+ (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size;
+ (UIImage *)imageFromColor:(UIColor *)color;
+(UIImage *)generateQRCode:(NSString *)qrString;
@end
