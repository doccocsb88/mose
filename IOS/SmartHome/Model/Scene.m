//
//  Scene.m
//  SmartHome
//
//  Created by Apple on 4/6/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import "Scene.h"
#import "Utils.h"
@implementation Scene
@dynamic order;
@dynamic sceneDetail;
-(CGFloat)getLoadingTime{
    NSInteger count = 0;
    for (SceneDetail *dv in [self.sceneDetail allObjects]) {
        if ([Utils getDeviceType:dv.device.topic] == DeviceTypeLightOnOff) {
            count++;
        }
    }
    return count * 0.5;
}
-(NSArray *)getListSceneDetail{
    NSMutableArray *arr = [NSMutableArray new];
    for (SceneDetail *detail in [self.sceneDetail allObjects]) {
        if (detail.device != nil) {
            [arr addObject:detail];
        }
    }
    return arr;
}

-(SceneDetail *)getDetailByRequestId:(NSString *)requestId{
    for (SceneDetail *detail in [self.sceneDetail allObjects]) {
        if (detail.device && [detail.device.requestId isEqualToString:requestId]) {
            return detail;
        }
    }
    return nil;
}
@end
