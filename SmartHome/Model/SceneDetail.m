//
//  SceneDetail.m
//  SmartHome
//
//  Created by Apple on 4/6/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import "SceneDetail.h"

@implementation SceneDetail
@dynamic id;
@dynamic value;
@dynamic status;
@dynamic device;
@dynamic code;
@dynamic key;
@dynamic chanels;
@synthesize isSelected;
@synthesize chanelSelected;
-(BOOL)isChanelOn:(NSInteger)chanel{
    if ([self.device numberOfSwitchChannel] > 0 && chanel > 0) {
        if (chanel == 1) {
            if ((int)self.value % 2 == 0) {
                return false;
            }else{
                return true;
            }
        }else if (chanel == 2){
            if (self.value == 2 || self.value == 3 || self.value == 6 || self.value == 7) {
                return true;
            }else{
                return false;
            }
        }else if (chanel == 3){
            if (self.value == 4 || self.value == 5 || self.value == 6 || self.value == 7) {
                return true;
            }else{
                return false;
            }
        }
    }
    return false;
}
-(void)addSelectedChanel:(NSInteger)chanel{
    NSMutableArray *arrs = [[self.chanels componentsSeparatedByString:@";"] mutableCopy];
    NSString *strChanel = [NSString stringWithFormat:@"%ld",chanel];
    if ([arrs containsObject:strChanel] == false) {
        [arrs addObject:[NSString stringWithFormat:@"%ld",chanel]];

    }
    NSArray *sortedArray;
    sortedArray = [arrs sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSNumber *first = a;
        NSNumber *second = b;
        return [first integerValue] > [second integerValue];
    }];
    self.chanels = @"";
    for (NSString *value in sortedArray){
        if (self.chanels.length == 0) {
            self.chanels = [NSString stringWithFormat:@"%@",value];
        }else{
            self.chanels = [NSString stringWithFormat:@"%@;%@",self.chanels,value];
        }
    }
    NSLog(@"chanel : %@",self.chanels);
}
-(void)setSelectedChanel:(NSInteger)chanel{
    if (!self.chanelSelected){
        self.chanelSelected = [NSMutableArray new];
    }
    if ([self.chanelSelected containsObject:@(chanel)]) {
        [self.chanelSelected removeObject:@(chanel)];
    }else{
        [self.chanelSelected addObject:@(chanel)];
    }
    NSArray *sortedArray;
    sortedArray = [self.chanelSelected sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSNumber *first = a;
        NSNumber *second = b;
        return [first integerValue] > [second integerValue];
    }];
    self.chanels = @"";
    for (NSString *value in sortedArray){
        if (self.chanels.length == 0) {
            self.chanels = [NSString stringWithFormat:@"%@",value];
        }else{
            self.chanels = [NSString stringWithFormat:@"%@;%@",self.chanels,value];
        }
    }
}

-(BOOL)isChanelSelected:(NSInteger)chanel{
    if (self.chanelSelected != NULL) {
        return  [self.chanelSelected containsObject:@(chanel)];
    }
    return false;
}

-(BOOL)hasSelectedDevicel{
    return self.chanelSelected.count > 0;
}

-(NSInteger)numberOfChanel{
    return [self.chanels componentsSeparatedByString:@";"].count;
}
-(NSInteger)getChanelIndex:(NSInteger)index{
    NSArray *arrs = [self.chanels componentsSeparatedByString:@";"];
    if (arrs && index < arrs.count) {
        if (index < arrs.count) {
            return [arrs[index] integerValue];
        }
    }
    return NSNotFound;
}
@end

