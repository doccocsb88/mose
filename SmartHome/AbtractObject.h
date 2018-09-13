//
//  AbtractObject.h
//  SmartHome
//
//  Created by Apple on 4/6/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface AbtractObject : NSManagedObject
@property (nonatomic, assign) NSInteger id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *code;

@end
