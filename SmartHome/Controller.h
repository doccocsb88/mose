//
//  Controller.h
//  SmartHome
//
//  Created by Apple on 3/20/18.
//  Copyright © 2018 Apple. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface Controller : NSManagedObject
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, assign) NSInteger order;
@property (nonatomic, assign) NSInteger type;

@end
