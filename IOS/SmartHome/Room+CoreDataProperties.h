//
//  Room+CoreDataProperties.h
//  
//
//  Created by Ngoc Truong on 7/17/17.
//
//

#import "Room+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Room (CoreDataProperties)

+ (NSFetchRequest<Room *> *)fetchRequest;

@property (nonatomic) NSInteger id;
@property (nullable, nonatomic, copy) NSString *image;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *code;
@property (nullable, nonatomic, copy) NSString *key;

@property (nonatomic) NSInteger order;
@property (nullable, nonatomic, copy) NSString *parentid;
@property (nullable, nonatomic, retain) NSSet<Device *> *devices;
@property (nullable, nonatomic, retain) NSSet<SceneDetail *> *sceneDetail;
-(BOOL)hasDeviceOn;
@end

@interface Room (CoreDataGeneratedAccessors)

- (void)addDevicesObject:(Device *)value;
- (void)removeDevicesObject:(Device *)value;
- (void)addDevices:(NSSet<Device *> *)values;
- (void)removeDevices:(NSSet<Device *> *)values;



- (void)addSceneDetailObject:(SceneDetail *)value;
- (void)removeSceneDetailObject:(SceneDetail *)value;
- (void)addSceneDetail:(NSSet<SceneDetail *> *)values;
- (void)removeSceneDetail:(NSSet<SceneDetail *> *)values;
@end
NS_ASSUME_NONNULL_END
