//
//  Room+CoreDataClass.h
//  
//
//  Created by Ngoc Truong on 7/17/17.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Device.h"
#import "ShareDevice.h"
@class SceneDetail;
NS_ASSUME_NONNULL_BEGIN

@interface Room : NSManagedObject
-(NSInteger)countAutocontrolDevice;
-(BOOL)hasDevice:(NSString *)mqttId;
-(NSInteger)countDevices;
-(NSArray *)getDeviceForShared;
-(NSArray *)getSharedDevices;
@end

NS_ASSUME_NONNULL_END

#import "Room+CoreDataProperties.h"
