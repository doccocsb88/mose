//
//  User.m
//  SmartHome
//
//  Created by Apple on 1/8/18.
//  Copyright © 2018 Apple. All rights reserved.
//

#import "User.h"

@implementation User
//@dynamic username;
//@dynamic displayName;
//@dynamic email;
//@dynamic password;
//@dynamic node;
//@dynamic active;
//@dynamic isShared;
//@dynamic accountType;
//@synthesize devices;
+ (instancetype)sharedInstance
{
    static User *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[User alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}
-(void)loadObjectFromLocal{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:@"user_local"];
    id object =    [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    if (object != NULL && [object isKindOfClass:self.class]) {
        User *localUser = ((User *)object);
        self.username = ((User *)object).username;
        self.password = ((User *)object).password;
        self.displayName = localUser.displayName;
        self.isShared = localUser.isShared;
        self.active = localUser.active;
        self.devices = localUser.devices;
        self.node = localUser.node;
        self.email = localUser.email;
        self.accountType = localUser.accountType;
    }
}
- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:[NSNumber numberWithBool:self.isShared] forKey:@"isShared"];
    [encoder encodeObject:[NSNumber numberWithBool:self.active] forKey:@"active"];

    [encoder encodeObject:self.devices forKey:@"devices"];
    [encoder encodeObject:self.username forKey:@"username"];
    [encoder encodeObject:self.password forKey:@"password"];

    [encoder encodeObject:self.email forKey:@"email"];
    [encoder encodeObject:self.displayName forKey:@"displayName"];
    [encoder encodeObject:self.node forKey:@"node"];
    [encoder encodeObject:[NSNumber numberWithInt:self.accountType] forKey:@"accountType"];


}
- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.isShared = [[decoder decodeObjectForKey:@"isShared"] boolValue];
        self.active = [[decoder decodeObjectForKey:@"active"] boolValue];
        self.devices = [decoder decodeObjectForKey:@"devices"];
        self.username = [decoder decodeObjectForKey:@"username"];
        self.password = [decoder decodeObjectForKey:@"password"];
        self.email = [decoder decodeObjectForKey:@"email"];
        self.displayName = [decoder decodeObjectForKey:@"displayName"];
        self.node = [decoder decodeObjectForKey:@"node"];
        self.accountType = [[decoder decodeObjectForKey:@"accountType"] intValue];

    }
    return self;
}


//    accountType = 1;
//    active = 1;
//    displayName = "Anh Hai";
//    email = "anhhai@a.com";
//    passwordShare = 123456;
//    qrCodeUrl = "/v0/b/smarthome-20aeb.appspot.com/o/aajJN4gK0NSfnMdhQfIiGICTmbS2.jpg";
//    sharepassword = "";
//    username = anhhai;
-(void)setData:(FIRDataSnapshot *)snapshot{
    if(snapshot && snapshot.value){
        NSDictionary *info = snapshot.value;
        if (!info) {
            return;
        }
        if([info objectForKey:@"displayName"]){
            self.displayName = [info objectForKey:@"displayName"];
        }
        if([info objectForKey:@"email"]){
            self.email = [info objectForKey:@"email"];
        }
        if([info objectForKey:@"username"]){
            self.username =  [info objectForKey:@"username"];
        }
        if([info objectForKey:@"active"]){
            self.active = [[info objectForKey:@"active"] boolValue];
        }else{
            self.active = false;
        }
        if([info objectForKey:@"accountType"]){
            self.accountType = [[info objectForKey:@"accountType"] intValue];
        }else{
            self.accountType = 0;
        }
        if([info objectForKey:@"node"]){
            self.node = [info objectForKey:@"node"];
        }
        NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:self];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:encodedObject forKey:@"user_local"];
        [defaults synchronize];

    }
}
-(void)setDataWithGoogle:(User *)snapshot{
}
-(void)setDevicesData:(FIRDataSnapshot *)snapshot{
    NSDictionary *dict = snapshot.value;
    self.devices = [NSArray new];
    if ([dict objectForKey:@"device"]) {
        NSString *deviceList = [dict objectForKey:@"device"];
        self.devices = [deviceList componentsSeparatedByString:@";"];
    }else{
       // self.devices = [NSArray new];
    }
    if([dict objectForKey:@"accept"]){
        self.isShared = [[dict objectForKey:@"accept"] boolValue];
    }
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:self];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:@"user_local"];
    [defaults synchronize];

}
-(BOOL)isAdmin{
    if (self.accountType == AccountTypeAdmin) {
        return true;
    }
    return false;
}
-(BOOL)isAuthentication{
    if (self.accountType != AccountTypeUnknow) {
        return YES;
    }
    return NO;
}
-(BOOL)canControlDevice:(NSString *)mqttId{
    if (self.accountType == AccountTypeAdmin) {
        return true;
    }else if (self.accountType == AccountTypeMember){
        if (mqttId && mqttId.length > 0) {
            
            return [self.devices containsObject:mqttId];
        }
    }
    return false;
}
-(NSString *)getNode{
    if (_node) {
        return _node;
    }
    return @"";
}
-(void)clearData{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"user_local"];
    [defaults synchronize];
    [self setDevices:[NSArray new]];
    
}
@end

