//
//  Timer+CoreDataProperties.m
//  
//
//  Created by Ngoc Truong on 7/28/17.
//
//

#import "SHTimer+CoreDataProperties.h"

@implementation SHTimer (CoreDataProperties)

+ (NSFetchRequest<SHTimer *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"SHTimer"];
}

@dynamic enable;
@dynamic deviceId;
@dynamic order;
@dynamic status;
@dynamic t2;
@dynamic t3;
@dynamic t4;
@dynamic t5;
@dynamic t6;
@dynamic t7;
@dynamic t8;
@dynamic value;
@dynamic timer;
@dynamic requestId;
@dynamic topic;
@dynamic type;
@dynamic code;
//@dynamic chanel;
@end
