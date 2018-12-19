//
//  Member.m
//  SmartHome
//
//  Created by Apple on 1/8/18.
//  Copyright © 2018 Apple. All rights reserved.
//

#import "SHMember.h"
#import "FirebaseHelper.h"

@implementation SHMember
-(void)shareDevice:(NSString *)mqttId{
    NSLog(@"shareDevice : %@",mqttId);
    if (!self.devices) {
        self.devices =@"";
    }
    if (![self.devices containsString:mqttId]) {
        self.devices = [NSString stringWithFormat:@"%@;%@",self.devices,mqttId];
    }
    [[FirebaseHelper sharedInstance] shareDevice:self.devices forUser:self.key];
}
-(void)unShareDevice:(NSString *)mqttId{
    if (!self.devices) {
        self.devices =@"";
    }
    NSMutableArray *arr = [[self.devices componentsSeparatedByString:@";"] mutableCopy];
    NSArray *deviceArr = [arr copy];
    for (NSString *obj in deviceArr) {
        if ([mqttId isEqualToString:obj]) {
            [arr removeObject:obj];
            break;
        }
    }
    self.devices = [arr componentsJoinedByString:@";"];
    if (self.devices && self.devices.length > 0) {
        [[FirebaseHelper sharedInstance] shareDevice:self.devices forUser:self.key];

    }
}

-(void)updateShareDeviceForMember{
    [[FirebaseHelper sharedInstance] shareDevice:self.devices forUser:self.key];
}
-(void)updateShareStatus{
    [[FirebaseHelper sharedInstance] updateMemberShareStatus:self.accept name:self.displayname devices:self.accept? self.devices : @"" uid:self.uid key:self.key];

}
@end
