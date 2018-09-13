//
//  Scene.h
//  SmartHome
//
//  Created by Apple on 4/6/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "AbtractObject.h"
#import "SceneDetail.h"
@interface Scene : AbtractObject
@property (nonatomic, assign) NSInteger order;

@property (nullable, nonatomic, retain) NSSet<SceneDetail *> *sceneDetail;
-(CGFloat)getLoadingTime;
-(NSArray *)getListSceneDetail;
-(SceneDetail *)getDetailByRequestId:(NSString *)requestId;
@end
@interface Scene (CoreDataGeneratedAccessors)

- (void)addSceneDetailObject:(SceneDetail *)value;
- (void)removeSceneDetailObject:(SceneDetail *)value;
- (void)addSceneDetail:(NSSet<SceneDetail *> *)values;
- (void)removeSceneDetail:(NSSet<SceneDetail *> *)values;

@end
