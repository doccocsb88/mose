//
//  Room+CoreDataProperties.m
//  
//
//  Created by Ngoc Truong on 7/17/17.
//
//

#import "Room+CoreDataProperties.h"

@implementation Room (CoreDataProperties)

+ (NSFetchRequest<Room *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Room"];
}

@dynamic id;
@dynamic image;
@dynamic name;
@dynamic order;
@dynamic parentid;
@dynamic devices;
@dynamic sceneDetail;
@dynamic code;
@dynamic key;
-(BOOL)hasDeviceOn{
    for (Device *dv in [self.devices allObjects]) {
        if (dv.type == DeviceTypeLightOnOff) {
            NSLog(@"state : %d",dv.state);
            if (dv.state == false) {
                return true;
            }
        }
    }
    return false;
}
@end
