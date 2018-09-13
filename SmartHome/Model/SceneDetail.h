//
//  SceneDetail.h
//  SmartHome
//
//  Created by Apple on 4/6/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "Device.h"
@interface SceneDetail : NSManagedObject
@property (assign, nonatomic) NSInteger id;
@property (assign, nonatomic) NSInteger value;
@property (assign, nonatomic) NSInteger status;
@property (assign, nonatomic) NSString *code;
@property (assign, nonatomic) NSString *key;

@property (assign, nonatomic) BOOL isSelected;
@property (strong, nonatomic) Device *device;
@property (strong, nonatomic) NSString *chanels;
@property (strong, nonatomic) NSMutableArray *chanelSelected;

-(BOOL)isChanelOn:(NSInteger)chanel;
-(void)addSelectedChanel:(NSInteger)chenel;
-(void)setSelectedChanel:(NSInteger)chanel;
-(BOOL)isChanelSelected:(NSInteger)chanel;
-(BOOL)hasSelectedDevicel;
-(NSInteger)numberOfChanel;
-(NSInteger)getChanelIndex:(NSInteger)index;

@end
