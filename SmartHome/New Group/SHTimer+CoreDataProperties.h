//
//  Timer+CoreDataProperties.h
//  
//
//  Created by Ngoc Truong on 7/28/17.
//
//

#import "SHTimer+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface SHTimer (CoreDataProperties)

+ (NSFetchRequest<SHTimer *> *)fetchRequest;

@property (nonatomic) BOOL enable;
@property (nonatomic) NSInteger deviceId;
@property (nonatomic) NSInteger order;
@property (nonatomic) NSInteger value;
@property (nonatomic) BOOL status;
@property (nonatomic) BOOL t2;
@property (nonatomic) BOOL t3;
@property (nonatomic) BOOL t4;
@property (nonatomic) BOOL t5;
@property (nonatomic) BOOL t6;
@property (nonatomic) BOOL t7;
@property (nonatomic) BOOL t8;
@property (nonatomic, strong) NSString *timer;
@property (nonatomic, strong) NSString *requestId;
@property (nonatomic, strong) NSString *topic;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, assign) NSInteger type;
//@property (nonatomic, assign) NSInteger chanel;

@end

NS_ASSUME_NONNULL_END
