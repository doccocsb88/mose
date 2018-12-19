//
//  Timer+CoreDataClass.h
//  
//
//  Created by Ngoc Truong on 7/28/17.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Device.h"
NS_ASSUME_NONNULL_BEGIN

@interface SHTimer : NSManagedObject
@property (nonatomic, assign) BOOL isSlide;

-(void)resetRepeat;

-(BOOL)isRepeat;

-(NSString *)getCommandString:(DeviceType)type goto:(BOOL)gto;

-(NSString *)getStatusCommandString;
-(NSString *)getDays;
@end

NS_ASSUME_NONNULL_END

#import "SHTimer+CoreDataProperties.h"
