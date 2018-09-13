//
//  Device.h
//  SmartHome
//
//  Created by Apple on 3/30/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef enum:NSInteger{
    DeviceTypeLightAdjust = 1,
    DeviceTypeLightOnOff,
    DeviceTypeCurtain,
    DeviceTypeTouchSwitch,
    DeviceTypeUnknow
}DeviceType;
@interface Device : NSManagedObject
@property (nonatomic, assign) NSInteger id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *requestId;
@property (nonatomic, strong) NSString *topic;

@property (nonatomic, strong) NSString *image;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) NSInteger order;
@property (nonatomic, assign) BOOL state;

@property (nonatomic, assign) BOOL control;
@property (nonatomic, assign) float value;
@property (nonatomic, assign) BOOL isSubcrible;
@property (nonatomic, assign) BOOL isGetStatus;
@property (nonatomic, assign) BOOL isOnline;

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *chanelInfo;

//@property (nonatomic, assign) BOOL isSelected;
-(NSString *)getAddMessage;
-(NSString *)getDelMessage;
-(NSString *)getTopic;
-(NSInteger)numberOfSwitchChannel;
-(NSInteger)numberofSharedChanel;
-(NSString *)switchChancelMessage:(int)chanel status:(Boolean)status;
-(void)updateStatusForChanel:(int)chanel value:(NSString *)value;
-(BOOL)isChanelOn:(int)chanel;
-(BOOL)isAutoControl:(int)chanel;
-(void)updateAutoControlForChanel:(int)chanel status:(Boolean)status;
-(void)updateNameForChanel:(int)chanel name:(NSString *)name;
-(NSString *)getChanelName:(int)chanel;

-(void)reset;
@end
