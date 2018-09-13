//
//  Timer+CoreDataClass.m
//  
//
//  Created by Ngoc Truong on 7/28/17.
//
//

#import "SHTimer+CoreDataClass.h"


@implementation SHTimer
@synthesize isSlide;

-(void)resetRepeat{
    self.t2 = NO;
    self.t3 = NO;
    self.t4 = NO;
    self.t5 = NO;
    self.t6 = NO;
    self.t7 = NO;
    self.t8 = NO;
    
}

-(BOOL)isRepeat{
    return self.t2 ||  self.t3 || self.t4 || self.t5 || self.t6 || self.t7 || self.t8; 

}
-(NSString *)getRepeatString{
    NSString *str = @"";
    if ([self isRepeat]) {
        str =  [NSString stringWithFormat:@"0%d%d%d%d%d%d%d",self.t2?1:0,self.t3?1:0,self.t4?1:0,self.t5?1:0,self.t6?1:0,self.t7?1:0,self.t8?1:0];
    }else{
        str =  @"1";
    }
    return str;
}
-(NSString *)getCommandString:(DeviceType)typezzz goto:(BOOL)gto{
    if(self.type == DeviceTypeCurtain){
        if (self.enable) {
            NSString *cmd = @"";
            if (gto) {
                cmd = [NSString stringWithFormat:@"%ld",self.value];
            }else{
                cmd = self.status? @"OPEN":@"CLOSE";
            }
            return [NSString stringWithFormat:@"id='%@' cmd='SETTIMER' value='%ld,UNABLE, %@/%@, %@'",self.requestId,self.order + 1,self.timer,cmd,[self getRepeatString]];
        }
        return [NSString stringWithFormat:@"id='%@' cmd='SETTIMER' value='%ld,DISABLE'",self.requestId,self.order + 1];
    }else if(self.type == DeviceTypeTouchSwitch){
        NSInteger chanel = 0;
        if([self.requestId containsString:@"/"]){
            chanel =  [[self.requestId componentsSeparatedByString:@"/"][1] intValue];
        }
        if (self.enable) {
            NSString *message =  [NSString stringWithFormat:@"id='%@' cmd='SETTIMER' value='%ld,%@,%@,%@,%@'",self.requestId,self.order ,self.enable ? @"1":@"0",self.timer,self.status? @"1":@"0",[self getRepeatString]];
            return message;
        }
        return [NSString stringWithFormat:@"id='%@' cmd='SETTIMER' value='%ld,0'",self.requestId,self.order];
    }else {
        if (self.enable) {
            return [NSString stringWithFormat:@"id='%@' cmd='SETTIMER' value='%ld,UNABLE, %@/%@, %@'",self.requestId,self.order + 1,self.timer,self.status? @"ON":@"OFF",[self getRepeatString]];
        }
        return [NSString stringWithFormat:@"id='%@' cmd='SETTIMER' value='%ld,DISABLE'",self.requestId,self.order + 1];
        
    }
}

-(NSString *)getStatusCommandString{
    return [NSString stringWithFormat:@"id='%@' cmd='GETTIMER' value='%ld'",self.requestId,self.order];
}
-(NSString *)getDays{
    NSString *str  =  [NSString stringWithFormat:@"%d:%d:%d:%d:%d:%d:%d",self.t2?1:0,self.t3?1:0,self.t4?1:0,self.t5?1:0,self.t6?1:0,self.t7?1:0,self.t8?1:0];
 
    return str;
}
@end
