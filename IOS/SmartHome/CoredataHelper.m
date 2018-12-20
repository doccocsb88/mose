//
//  CoredataHelper.m
//  SmartHome
//
//  Created by Apple on 3/27/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import "CoredataHelper.h"
#import <UIKit/UIKit.h>
#import "AppDelegate.h"
@implementation CoredataHelper
+ (instancetype)sharedInstance
{
    static CoredataHelper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CoredataHelper alloc] init];
        // Do any other initialisation stuff here
        sharedInstance.context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] persistentContainer].viewContext;
        
    });
    return sharedInstance;
}
-(void)initRoomData{
//    NSError* err = nil;
//    NSString* dataPath = [[NSBundle mainBundle] pathForResource:@"SmartHome" ofType:@"json"];
//    NSArray* rooms = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:dataPath]
//                                                     options:kNilOptions
//                                                       error:&err];
//    
//    [rooms enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        [[CoredataHelper sharedInstance] addNewRoom:[NSString stringWithFormat:@"%ld",idx] name:[obj objectForKey:@"name"] parentId:[obj objectForKey:@"parentid"] complete:^(BOOL complete,Room *room) {
//            
//        }];
//        NSError *error;
//        if (![self.context save:&error]) {
//            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
//        }
//    }];
}

-(void)addNewController:(NSString *)controllerId name:(NSString *)name order:(NSInteger)order type:(NSInteger)type code:(NSString *)code key:(NSString *)key complete:(void(^)(BOOL complete, Controller * room))complete{
    Controller *newRoom = (Controller *)[NSEntityDescription insertNewObjectForEntityForName:@"Controller" inManagedObjectContext:self.context];
    newRoom.id = controllerId;
    newRoom.name = name;
    newRoom.order = order;
    newRoom.type = type;
    if(code && code.length > 0){
        newRoom.code = code;
    }else{
        newRoom.code = [@"" randomStringWithLength:32];
        
    }
    newRoom.key = key;
    NSError *error;
    if (![self.context save:&error]) {
        // Something's gone seriously wrong
        NSLog(@"Error saving new color: %@", [error localizedDescription]);
        complete(false,nil);
    }
    complete(true, newRoom);
    
}

-(NSArray *)getListcontroller{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Controller" inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    // Fetch the records and handle an error
    NSError *error;
    NSArray *arr  = [[self.context executeFetchRequest:request error:&error] mutableCopy];
    if (!arr) {
        // This is a serious error
        // Handle accordingly
        NSLog(@"Failed to load colors from disk");
    }
    return arr;
    
}
-(NSArray *)getListcontrollerBytype:(NSInteger)type{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Controller" inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.predicate = [NSPredicate predicateWithFormat:@"type == %ld",type];
    [request setEntity:entity];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    // Fetch the records and handle an error
    NSError *error;
    NSArray *arr  = [[self.context executeFetchRequest:request error:&error] mutableCopy];
    if (!arr) {
        // This is a serious error
        // Handle accordingly
        NSLog(@"Failed to load colors from disk");
    }
    return arr;
    
}
-(Controller *)getControllerById:(NSString *)controllerId{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Controller" inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    request.predicate = [NSPredicate predicateWithFormat:@"id == %@", controllerId];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    // Fetch the records and handle an error
    NSError *error;
    NSArray *arr  = [[self.context executeFetchRequest:request error:&error] mutableCopy];
    if (!arr) {
        // This is a serious error
        // Handle accordingly
        return nil;
    }
    return [arr firstObject];
}
-(BOOL)hasController:(NSString *)controllerId{
    return [self getControllerById:controllerId] != nil;
}
-(NSInteger)countController:(NSInteger)type{
    NSArray *arr = [self getListcontrollerBytype:type];
    if (arr) {
        return arr.count;
    }
    return 0;
}
- (Room *)addNewRoom:(NSString *)_id name:(NSString *)name parentId:(NSString *)parentId complete:(void(^)(BOOL complete, Room * room))complete{
    Room *newRoom = (Room *)[NSEntityDescription insertNewObjectForEntityForName:@"Room" inManagedObjectContext:self.context];
    newRoom.id = [_id integerValue];
    newRoom.name = name;
    newRoom.parentid = parentId;
    newRoom.order = [_id integerValue];
    newRoom.image = [NSString stringWithFormat:@"ic_room_%ld",[_id integerValue] % 12];
    newRoom.code = [@"" randomStringWithLength:32];
    NSError *error;
    if (![self.context save:&error]) {
        // Something's gone seriously wrong
        NSLog(@"Error saving new color: %@", [error localizedDescription]);
        complete(false,nil);
        return nil;
    }
    complete(true, newRoom);
    return newRoom;
}
- (Room *)addNewRoomV2:(NSString *)_id key:(NSString *)key name:(NSString *)name code:(NSString *)code order:(NSInteger)order complete:(void(^)(BOOL))complete{
    Room *newRoom = (Room *)[NSEntityDescription insertNewObjectForEntityForName:@"Room" inManagedObjectContext:self.context];
    newRoom.id = [_id integerValue];
    newRoom.name = name;
    newRoom.parentid = @"";
    newRoom.code = code;
    newRoom.order = order;
    newRoom.image = [NSString stringWithFormat:@"ic_room_%ld",[_id integerValue] % 12];
    newRoom.key = key;
    NSError *error;
    if (![self.context save:&error]) {
        // Something's gone seriously wrong
        NSLog(@"Error saving new color: %@", [error localizedDescription]);
        complete(false);
        return nil;
    }
    complete(true);
    return newRoom;
}
- (SHTimer *)addTimer{
    SHTimer *newTimer = (SHTimer *)[NSEntityDescription insertNewObjectForEntityForName:@"SHTimer" inManagedObjectContext:self.context];
    //    newRoom.id = [_id integerValue];
    //    newRoom.name = name;
    //    newRoom.parentid = parentId;
    //    //    newColor.red = [self randomColorComponentValue];
    //    //    newColor.green = [self randomColorComponentValue];
    //    //    newColor.blue = [self randomColorComponentValue];
    //    newRoom.order = [_id integerValue];
    //    newRoom.image = [NSString stringWithFormat:@"ic_room_%ld",[_id integerValue] % 12];
    newTimer.code = [@"" randomStringWithLength:32];
    NSError *error;
    if (![self.context save:&error]) {
        // Something's gone seriously wrong
        NSLog(@"Error saving new color: %@", [error localizedDescription]);
    }
    return newTimer;
}
-(SHTimer *)getTimerByCode:(NSString *)code{
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    fetch.entity = [NSEntityDescription entityForName:@"SHTimer" inManagedObjectContext:self.context];
    fetch.predicate = [NSPredicate predicateWithFormat:@"code == %@", code];
    NSArray *array = [self.context executeFetchRequest:fetch error:nil];
    
    
    if (!array) {
        return nil;
    }
    return [array firstObject];
}
-(NSArray *)getListRoom{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Room" inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    // Fetch the records and handle an error
    NSError *error;
    NSArray *arr  = [[self.context executeFetchRequest:request error:&error] mutableCopy];
    if (!arr) {
        // This is a serious error
        // Handle accordingly
        NSLog(@"Failed to load colors from disk");
    }
    return arr;
}
-(NSArray *)getListScene{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Scene" inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    // Fetch the records and handle an error
    NSError *error;
    NSArray *arr  = [[self.context executeFetchRequest:request error:&error] mutableCopy];
    if (!arr) {
        // This is a serious error
        // Handle accordingly
        NSLog(@"Failed to load colors from disk");
    }
    return arr;
}
-(Scene *)getSceneByCode:(NSString *)code{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Scene" inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"code == %@", code];
    [request setPredicate:predicate];
    // Fetch the records and handle an error
    NSError *error;
    NSArray *arr  = [[self.context executeFetchRequest:request error:&error] mutableCopy];
    if (!arr) {
        // This is a serious error
        // Handle accordingly
        return nil;
    }
    return [arr firstObject];
    
}
-(Scene *)getSceneById:(NSInteger)id{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Scene" inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %d", id];
    [request setPredicate:predicate];
    // Fetch the records and handle an error
    NSError *error;
    NSArray *arr  = [[self.context executeFetchRequest:request error:&error] mutableCopy];
    if (!arr) {
        // This is a serious error
        // Handle accordingly
        return nil;
    }
    return [arr firstObject];
    
}
-(void)addNewScene:(NSInteger)_id name:(NSString *)name complete:(void(^)(Scene * scene))complete{
    Scene *scene = (Scene *)[NSEntityDescription insertNewObjectForEntityForName:@"Scene" inManagedObjectContext:self.context];
    scene.id = _id;
    scene.name = name;
    scene.code = [@"" randomStringWithLength:32];
    NSError *error;
    if (![self.context save:&error]) {
        // Something's gone seriously wrong
        NSLog(@"Error saving new color: %@", [error localizedDescription]);
        complete(nil);
    }
    complete(scene);
}
-(void)addNewSceneV2:(NSInteger)_id name:(NSString *)name code:(NSString *)code complete:(void(^)(Scene * scene))complete{
    Scene *scene = (Scene *)[NSEntityDescription insertNewObjectForEntityForName:@"Scene" inManagedObjectContext:self.context];
    scene.id = _id;
    scene.name = name;
    scene.code = code;
    NSError *error;
    if (![self.context save:&error]) {
        // Something's gone seriously wrong
        NSLog(@"Error saving new color: %@", [error localizedDescription]);
        complete(nil);
    }
    complete(scene);
}
-(SceneDetail *)addSceneDetail:(NSInteger)_id value:(NSInteger) value status:(BOOL)status device:(Device *)device complete:(void(^)(SceneDetail * detail))complete{
    SceneDetail *scene = (SceneDetail *)[NSEntityDescription insertNewObjectForEntityForName:@"SceneDetail" inManagedObjectContext:self.context];
    scene.id = _id;
    scene.value = value;
    scene.status = status;
    scene.device = device;
    scene.code = [@"" randomStringWithLength:32];
    NSError *error;
    if (![self.context save:&error]) {
        // Something's gone seriously wrong
        NSLog(@"Error saving new color: %@", [error localizedDescription]);
        complete(nil);
        return nil;
    }
    complete(scene);
    return scene;
    
}
-(SceneDetail *)addSceneDetailV2:(NSInteger)_id key:(NSString *)key value:(NSInteger) value status:(NSInteger)status device:(Device *)device code:(NSString *)code complete:(void(^)(SceneDetail * detail))complete{
    SceneDetail *scene = (SceneDetail *)[NSEntityDescription insertNewObjectForEntityForName:@"SceneDetail" inManagedObjectContext:self.context];
    scene.id = _id;
    scene.key = key;
    scene.value = value;
    scene.status = status;
    scene.device = device;
    scene.code = code;
    NSError *error;
    if (![self.context save:&error]) {
        // Something's gone seriously wrong
        NSLog(@"Error saving new color: %@", [error localizedDescription]);
        complete(nil);
        return nil;
    }
    complete(scene);
    return scene;
    
}
-(NSArray *)getAllSceneDetail{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SceneDetail" inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    //    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    //    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    //    [request setSortDescriptors:sortDescriptors];
    // Fetch the records and handle an error
    NSError *error;
    NSArray *arr  = [[self.context executeFetchRequest:request error:&error] mutableCopy];
    if (!arr) {
        // This is a serious error
        // Handle accordingly
        NSLog(@"Failed to load colors from disk");
    }
    return arr;
    
}
-(SceneDetail *)getSceneDetailByCode:(NSString *)code{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SceneDetail" inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"code == %@", code];
    [request setPredicate:predicate];
    // Fetch the records and handle an error
    NSError *error;
    NSArray *arr  = [[self.context executeFetchRequest:request error:&error] mutableCopy];
    if (!arr) {
        // This is a serious error
        // Handle accordingly
        NSLog(@"Failed to load colors from disk");
        return nil;
    }
    return [arr firstObject];
    
}
-(void)deleteDetailByDeviceId:(NSInteger)deviceId{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SceneDetail" inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    // Fetch the records and handle an error
    NSError *error;
    NSArray *arr  = [[self.context executeFetchRequest:request error:&error] mutableCopy];
    if (arr != nil ) {
        for (SceneDetail *detail in arr) {
            if (detail.device && detail.device.id == deviceId) {
                [self.context deleteObject:detail];
            }
        }
    }
}
#pragma mark
-(Device *)addNewDevice:(NSString *)token name:(NSString *) name deviceId:(NSInteger )_id state:(BOOL)state value:(NSInteger)value requestId:(NSString *)requestId topic:(NSString *)topic type:(NSInteger)type complete:(void(^)(Device * device))complete{
    Device *device = (Device *)[NSEntityDescription insertNewObjectForEntityForName:@"Device" inManagedObjectContext:self.context];
    device.name = name;
    device.token = token;
    device.id = _id;
    device.state = state;
    device.value = value;
    device.requestId = requestId;
    device.order = _id;
    
//    if (type == DeviceTypeCurtain) {
//        device.topic = [NSString stringWithFormat:@"QA_CC_%@",requestId];
//    }else if(type == DeviceTypeTouchSwitch){
//        device.topic = [NSString stringWithFormat:@"%@",requestId];
//    }else if (type == DeviceTypeLightOnOff ){
//        device.topic = [Utils getTopic];
//    }
    device.topic = topic;
    device.type = type;
    device.image = [NSString stringWithFormat:@"ic_room_%ld",_id - 1];
    [self save];
    complete(device);
    return device;
}
-(Device *)addNewDevice:(NSString *)token name:(NSString *) name deviceId:(NSInteger )_id topic:(NSString *)topic control:(BOOL)control state:(BOOL)state value:(NSInteger)value mqttId:(NSString *)mqttId type:(NSInteger)type order:(NSInteger)order complete:(void(^)(Device * device))complete{
    Device *device = (Device *)[NSEntityDescription insertNewObjectForEntityForName:@"Device" inManagedObjectContext:self.context];
    device.name = name;
    device.token = token;
    device.id = _id;
    device.state = state;
    device.value = value;
    device.requestId = mqttId;
    device.control = control;
    device.topic = topic;
    device.type = type;
    device.order = order;
    device.isOnline = true;
    device.image = [NSString stringWithFormat:@"ic_room_%ld",_id - 1];
    [self save];
    complete(device);
    return device;
}
-(NSArray *)getListDevice{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Device" inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"type" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    // Fetch the records and handle an error
    NSError *error;
    NSArray *arr  = [[self.context executeFetchRequest:request error:&error] mutableCopy];
    if (!arr) {
        // This is a serious error
        // Handle accordingly
        NSLog(@"Failed to load colors from disk");
    }
    return arr;
}
-(NSArray *)getListDeviceByRoom:(NSInteger)roomId{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Device" inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    // Fetch the records and handle an error
    NSError *error;
    NSArray *arr  = [[self.context executeFetchRequest:request error:&error] mutableCopy];
    if (!arr) {
        // This is a serious error
        // Handle accordingly
        NSLog(@"Failed to load colors from disk");
    }
    return arr;
}
-(Room *)getRoomByid:(NSInteger)roomId{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Room" inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %d", roomId];
    [request setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    // Fetch the records and handle an error
    NSError *error;
    NSArray *arr  = [[self.context executeFetchRequest:request error:&error] mutableCopy];
    if (!arr) {
        // This is a serious error
        // Handle accordingly
        NSLog(@"Failed to load colors from disk");
        return nil;
    }
    return [arr firstObject];
}
-(Room *)getRoomByCode:(NSString *)code{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Room" inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"code == %@", code];
    [request setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    // Fetch the records and handle an error
    NSError *error;
    NSArray *arr  = [[self.context executeFetchRequest:request error:&error] mutableCopy];
    if (!arr) {
        // This is a serious error
        // Handle accordingly
        NSLog(@"Failed to load colors from disk");
        return nil;
    }
    return [arr firstObject];
}
-(NSArray *)getListTimerByDeviceId:(NSInteger)deviceId{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SHTimer" inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    //
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deviceId==%ld", deviceId];
    [request setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    // Fetch the records and handle an error
    NSError *error;
    NSArray *arr  = [self.context executeFetchRequest:request error:&error];
    
    return arr;
}
-(NSInteger)countDevice{
    NSArray * arr = [self getListDevice];
    NSInteger max =  0;
    if (arr) {
        for (Device *dv in arr) {
            if (dv.id > max) {
                max =  dv.id;
            }
        }
    }
    return max + 1;
}
-(Device *)getDeviceByTopic:(NSString *)topic type:(NSInteger)type{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Device" inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    //
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"requestId==%@", topic];
    [request setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"type" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    // Fetch the records and handle an error
    NSError *error;
    NSArray *arr  = [[self.context executeFetchRequest:request error:&error] mutableCopy];
    if (!arr) {
        // This is a serious error
        // Handle accordingly
        return nil;
    }
    return [arr firstObject];
    
}
-(Device *)getDeviceById:(NSInteger )id{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Device" inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    //
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id==%d", id];
    [request setPredicate:predicate];
    
    
    // Fetch the records and handle an error
    NSError *error;
    NSArray *arr  = [self.context executeFetchRequest:request error:&error];
    if (!arr) {
        // This is a serious error
        // Handle accordingly
        return nil;
    }
    return [arr firstObject];
    
}
-(Device *)getDeviceBycode:(NSString *)code{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Device" inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    //
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"requestId==%@", code];
    [request setPredicate:predicate];
    
    
    // Fetch the records and handle an error
    NSError *error;
    NSArray *arr  = [self.context executeFetchRequest:request error:&error];
    if (!arr) {
        // This is a serious error
        // Handle accordingly
        return nil;
    }
    return [arr firstObject];
    
}
-(Device *)getDeviceByTopic:(NSString *)topic{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Device" inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    //
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"topic==%@", topic];
    [request setPredicate:predicate];
    
    
    // Fetch the records and handle an error
    NSError *error;
    NSArray *arr  = [self.context executeFetchRequest:request error:&error];
    if (!arr) {
        // This is a serious error
        // Handle accordingly
        return nil;
    }
    return [arr firstObject];
    
}
-(Device *)getDeviceByMqttId:(NSString *)mqttId{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Device" inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    //
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"requestId==%@", mqttId];
    [request setPredicate:predicate];
    
    
    // Fetch the records and handle an error
    NSError *error;
    NSArray *arr  = [self.context executeFetchRequest:request error:&error];
    if (!arr) {
        // This is a serious error
        // Handle accordingly
        return nil;
    }
    return [arr firstObject];
    
}

-(void)deleteDevice:(Device *)device{
    NSLog(@"delete device %@",device.requestId);
    [self.context deleteObject:device];
    [self save];
}
-(void)deleteDetail:(SceneDetail *)detail{
    [self.context deleteObject:detail];
    [self save];
}
-(void)deleteRoom:(Room *)room{
    [self.context deleteObject:room];
    [self save];
}
-(void)deleteTimerByDeviceId:(NSString * )requestId{
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    fetch.entity = [NSEntityDescription entityForName:@"SHTimer" inManagedObjectContext:self.context];
    fetch.predicate = [NSPredicate predicateWithFormat:@"requestId == %@", requestId];
    NSArray *array = [self.context executeFetchRequest:fetch error:nil];
    for (NSManagedObject *managedObject in array) {
        [self.context deleteObject:managedObject];
    }
}
-(void)deleteTimerByCode:(NSString *)code{
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    fetch.entity = [NSEntityDescription entityForName:@"SHTimer" inManagedObjectContext:self.context];
    fetch.predicate = [NSPredicate predicateWithFormat:@"code == %@", code];
    NSArray *array = [self.context executeFetchRequest:fetch error:nil];
    for (NSManagedObject *managedObject in array) {
        [self.context deleteObject:managedObject];
    }
    
}
-(void)deleteRoomByCode:(NSString *)code{
    [self deleteObject:@"Room" byCode:code];
}
-(void)deleteSceneCode:(NSString *)code{
    [self deleteObject:@"Scene" byCode:code];
}
-(void)deleteSceneDetailByCode:(NSString *)code{
    [self deleteObject:@"SceneDetail" byCode:code];
}
-(void)deleteObject:(NSString *)objName byCode:(NSString * )code{
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    fetch.entity = [NSEntityDescription entityForName:objName inManagedObjectContext:self.context];
    fetch.predicate = [NSPredicate predicateWithFormat:@"code == %@", code];
    NSArray *array = [self.context executeFetchRequest:fetch error:nil];
    
    
    
    
    for (NSManagedObject *managedObject in array) {
        [self.context deleteObject:managedObject];
    }
}
/**/
-(BOOL)hasDevice:(NSString *)mqttId{
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Device" inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    //
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"requestId==%@", mqttId];
    [request setPredicate:predicate];
    NSError *error;
    NSArray *arr  = [[self.context executeFetchRequest:request error:&error] mutableCopy];
    if (!arr) {
        // This is a serious error
        // Handle accordingly
        return NO;
    }
    if(arr && arr.count > 0){
        return YES;
    }
    return NO;
}
-(BOOL)hasObject:(NSString *)name code:(NSString *)code{
    NSEntityDescription *entity = [NSEntityDescription entityForName:name inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    //
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"code==%@", code];
    [request setPredicate:predicate];
    NSError *error;
    NSArray *arr  = [[self.context executeFetchRequest:request error:&error] mutableCopy];
    if (!arr) {
        // This is a serious error
        // Handle accordingly
        return NO;
    }
    if(arr && arr.count > 0){
        return YES;
    }
    return NO;
}
-(void)clearData{
    [self removeData:@"SHTimer"];
    [self removeData:@"SceneDetail"];
    [self removeData:@"Scene"];
    [self removeData:@"Device"];
    [self removeData:@"Room"];
    [self removeData:@"Controller"];

}
-(void)removeData:(NSString *)tableName{
    NSFetchRequest *allCars = [[NSFetchRequest alloc] init];
    [allCars setEntity:[NSEntityDescription entityForName:tableName inManagedObjectContext:self.context]];
    [allCars setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError *error = nil;
    NSArray *cars = [self.context executeFetchRequest:allCars error:&error];
    //error handling goes here
    for (NSManagedObject *car in cars) {
        [self.context deleteObject:car];
    }
    NSError *saveError = nil;
    [self.context save:&saveError];
}
-(void)save{
    AppDelegate *delegate =  (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate saveContext];
}
@end

