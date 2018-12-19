//
//  Device.m
//  SmartHome
//
//  Created by Apple on 3/30/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import "Device.h"
#import "Utils.h"
#import "User.h"
@implementation Device
@dynamic id;
@dynamic name;
@dynamic state;
@dynamic value;
@dynamic type;
@dynamic token;
@dynamic requestId;
@dynamic topic;
@dynamic image;
@dynamic order;
@dynamic control;
@synthesize isSubcrible;
@synthesize isGetStatus;
@synthesize isOnline;
@synthesize key;
@dynamic chanelInfo;

-(void)awakeFromFetch{
    isOnline = true;
    isGetStatus = false;
    NSLog(@"cleardata 2");

}
-(NSString *)getAddMessage{
    return [NSString stringWithFormat:@"id='%@' cmd='ADDDEV'",self.requestId];
}
-(NSString *)getDelMessage{
    return [NSString stringWithFormat:@"id='%@' cmd='DELDEV'",self.requestId];
}
-(NSString *)getTopic{
    return self.requestId;
}

-(NSInteger )numberOfSwitchChannel{
    if (self.type == DeviceTypeTouchSwitch) {
        NSString *prefix = [self.requestId componentsSeparatedByString:@"-"][0];
        if ([prefix isEqualToString:@"WT3"]) {
            return 3;
        }else  if ([prefix isEqualToString:@"WT2"]) {
            return 2;
        }else if ([prefix isEqualToString:@"WT1"]) {
            return 1;
        }
        
    }
    return 0;
}
-(NSInteger)numberofSharedChanel{
    if ([[User sharedInstance] isAdmin]) {
        return [self numberOfSwitchChannel];
    }
    NSInteger numberOfChanel = 0;
    for (int i = 0; i < [self numberOfSwitchChannel]; i++) {
        NSString *requestId = [NSString stringWithFormat:@"%@/%d",self.requestId,(i + 1)];
        if ([[User sharedInstance].devices containsObject:requestId]) {
            numberOfChanel ++;
        }
    }
    return numberOfChanel;
}
-(NSString *)switchChancelMessage:(int)chanel status:(Boolean)status{
//    id=’WT3-0000000003/1’ cmd=’ON’ value=’W3,2,1’
//    id=’WT3-0000000003/1’ cmd=’OFF value=’W3,2,0’
    NSString *stageString = status?@"ON":@"OFF";
    NSString *valueString = @"";
    NSString *prefix = [self.requestId componentsSeparatedByString:@"-"][0];
    if ([prefix isEqualToString:@"WT3"]) {
        valueString = status?@"W3,2,1":@"W3,2,0";
    }else if ([prefix isEqualToString:@"WT2"]) {
        valueString = status?@"W2,2,1":@"W2,2,0";

    }else if ([prefix isEqualToString:@"WT1"]) {
        valueString = status?@"W1,2,1":@"W1,2,0";
    }
    NSString *message =  [NSString stringWithFormat:@"id='%@/%d' cmd='%@' value='%@'",self.requestId,chanel,stageString,valueString];
    return message;
}

-(void)updateStatusForChanel:(int)chanel value :(NSString *)value{
    NSArray * values = [value componentsSeparatedByString:@","];
    NSLog(@"updateStatusForChanel %@ %d %f",self.requestId,chanel,self.value);
    Boolean isON = [values.lastObject intValue] == 1;
    if (isON) {
        //        id=’WT3-0000000003/1’ cmd=’ON’ value=’W3,2,1’
        if (chanel == 1) {
            //chenal 1
            if (self.value == 0 ||  self.value == 2 ||  self.value == 4 ||  self.value == 6){
                //off
                self.value += 1;
            }else{
//                self.value -= 1;
            }
        }else if (chanel == 2){
            //chenal 2
            if (self.value == 0 || self.value == 1 || self.value == 4 || self.value == 5) {
//
                self.value += 2;
                
            }
        }else if (chanel == 3){
            //chenal 3
            if (self.value < 4) {
                //off
                self.value += 4;
            }
        }
        
    }else{
        if (chanel == 1) {
            //chenal 1
            if (self.value == 1 || self.value == 3 || self.value == 5 || self.value == 7) {
                //on
                self.value -= 1;
            }
        }else if (chanel == 2){
            //chenal 2
            if (self.value == 2 || self.value == 3 || self.value == 6 || self.value == 7) {
                //on
                self.value -= 2;
            }
        }else if (chanel == 3){
            //chenal 3
            if (self.value == 4 || self.value == 5 || self.value == 6 || self.value == 7) {
                //on
                self.value -= 4;
            }
        }
    }
    NSInteger maxPoint = [self maxPoint];
    if (self.value < 0) {
        self.value = 0;
    }else if (self.value > maxPoint){
        self.value = maxPoint;
    }
//    NSLog(@"updateStatusForChanel 2 %f",self.value);

}

-(BOOL)isChanelOn:(int)chanel{
    if ([self numberOfSwitchChannel] > 0 && chanel > 0) {
        if (chanel == 1) {
            if ((int)self.value % 2 == 0) {
                return false;
            }else{
                return true;
            }
        }else if (chanel == 2){
            if (self.value == 2 || self.value == 3 || self.value == 6 || self.value == 7) {
                return true;
            }else{
                return false;
            }
        }else if (chanel == 3){
            if (self.value == 4 || self.value == 5 || self.value == 6 || self.value == 7) {
                return true;
            }else{
                return false;
            }
        }
    }
    return false;
}
-(BOOL)isAutoControl:(int)chanel{
    if ([self numberOfSwitchChannel] > 0 && chanel > 0) {
        NSString *jsonString = self.chanelInfo;
        NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if (json) {
            NSString *autoKey = [NSString stringWithFormat:@"control%d",chanel];
            if ([json objectForKey:autoKey]) {
                return [[json objectForKey:autoKey] boolValue];
            }
            
        }
        return false;
    }
    return self.control;
}
-(NSInteger)maxPoint{
    NSInteger numberOfSwitch = [self numberOfSwitchChannel];
    switch (numberOfSwitch) {
        case 1:
            return 1;
            break;
        case 2:
            return 3;
            break;
        case 3:
            return 7;
            break;
        default:
            return 0;
            break;
    }
}

-(void)updateAutoControlForChanel:(int)chanel status:(Boolean)status{
    NSMutableDictionary *info  = [NSMutableDictionary new];

    NSString *jsonString = self.chanelInfo;
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    for (int i = 1; i <= [self numberOfSwitchChannel]; i++) {
        NSString *key = [NSString stringWithFormat:@"name%d",i];
        NSString *controlKey = [NSString stringWithFormat:@"control%d",i];
        if([json objectForKey:key]){
            [info setObject:[json objectForKey:key] forKey:key];
        }
        if([json objectForKey:controlKey]){
            [info setObject:[json objectForKey:controlKey] forKey:controlKey];
        }
        
    }
    NSString *autoKey = [NSString stringWithFormat:@"control%d",chanel];
    if ([json objectForKey:autoKey]) {
        
        [info setObject:[NSNumber  numberWithBool:![[json objectForKey:autoKey] boolValue]] forKey:autoKey];
    }else{
        [info setObject:[NSNumber  numberWithBool:status] forKey:autoKey];
    }
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:info
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        self.chanelInfo = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}
-(void)updateNameForChanel:(int)chanel name:(NSString *)name{
    NSMutableDictionary *info  = [NSMutableDictionary new];
    
    NSString *jsonString = self.chanelInfo;
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    for (int i = 1; i <= [self numberOfSwitchChannel]; i++) {
        NSString *key = [NSString stringWithFormat:@"name%d",i];
        NSString *controlKey = [NSString stringWithFormat:@"control%d",i];
        if([json objectForKey:key]){
            [info setObject:[json objectForKey:key] forKey:key];
        }
        if([json objectForKey:controlKey]){
            [info setObject:[json objectForKey:controlKey] forKey:controlKey];
        }
        
    }
    NSString *nameKey = [NSString stringWithFormat:@"name%d",chanel];
    [info setObject:name forKey:nameKey];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:info
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        self.chanelInfo = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

-(NSString *)getChanelName:(int)chanel{
    NSString *jsonString = self.chanelInfo;
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSString *nameKey = [NSString stringWithFormat:@"name%d",chanel];
    if ([json objectForKey:nameKey]) {
        return [json objectForKey:nameKey];
    }
    return [NSString stringWithFormat:@"Kênh %d",chanel];
}
-(void)reset{
//    isOnline = true;
    isSubcrible = false;
    isGetStatus = false;
}
@end
