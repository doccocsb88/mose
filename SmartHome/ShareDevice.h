//
//  ShareDevice.h
//  SmartHome
//
//  Created by Apple on 1/8/18.
//  Copyright © 2018 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShareDevice : NSObject
@property (strong, nonatomic) NSString *mqttId;
@property (strong, nonatomic) NSString *name;

@property (assign, nonatomic) BOOL isShare;

@end
