//
//  BaseService.m
//  SmartHome
//
//  Created by Apple on 3/13/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import "BaseServicez.h"
#define device_token @"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE0OTExMzE5MzIsImlhdCI6MTQ5MTEyNDczMiwidXNyIjoiUk9MTEVSVEVDSCJ9.rkBFEuzsoRw7kU_KcaccGcXZ16lBWV1teT1-kLrTo78"
@implementation BaseServicez
+ (instancetype)sharedInstance
{
    static BaseServicez *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BaseServicez alloc] init];
        // Do any other initialisation stuff here
//        NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
//        if ([pref objectForKey:@"pref_token"] == nil) {
//            sharedInstance.deviceToken = device_token;
//        }else{
//            sharedInstance.deviceToken = [pref objectForKey:@"pref_token"];
//        }
        
    });
    return sharedInstance;
}

-(void)getToken{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    AFHTTPRequestSerializer *request = [[AFHTTPRequestSerializer alloc] init];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json, text/plain, */*" forHTTPHeaderField:@"Accept"];
//    [request setValue:@"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE0OTExMDE1ODQsImlhdCI6MTQ5MTA5NDM4NCwidXNyIjoiUk9MTEVSVEVDSCJ9.MVmHBgGCyK1uUFQNTzSahFgaheYhZZoHRwlckTUEKOk" forHTTPHeaderField:@"Authorization"];
    manager.requestSerializer = request;
    
    NSString *url = [NSString stringWithFormat:@"https://api.thinger.io/oauth/token"];
//    ROLLERTECH
    //123456789AH
    NSDictionary *params = @{@"grant_type":@"password",@"username":@"ROLLERTECH",@"password":@"123456789AH"};
    [manager POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        //        <#code#>
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //        <#code#>
        NSLog(@"JSON: %@", responseObject);
        NSDictionary *data = (NSDictionary *)responseObject;
        self.access_token = [data objectForKey:@"access_token"];
        self.refresh_token = [data objectForKey:@"refresh_token"];
        self.token_type = [data objectForKey:@"token_type"];
        self.expires_in = [data objectForKey:@"expires_in"];
        [self getRefreshToken];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //        <#code#>
        NSLog(@"Error: %@", error);
        
    }];
}
-(void)getRefreshToken{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    AFHTTPRequestSerializer *request = [[AFHTTPRequestSerializer alloc] init];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json, text/plain, */*" forHTTPHeaderField:@"Accept"];
    //    [request setValue:@"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE0OTExMDE1ODQsImlhdCI6MTQ5MTA5NDM4NCwidXNyIjoiUk9MTEVSVEVDSCJ9.MVmHBgGCyK1uUFQNTzSahFgaheYhZZoHRwlckTUEKOk" forHTTPHeaderField:@"Authorization"];
    manager.requestSerializer = request;
    
    NSString *url = [NSString stringWithFormat:@"https://api.thinger.io/oauth/token"];
    //    ROLLERTECH
    //123456789AH
    NSDictionary *params = @{@"grant_type":@"refresh_token",@"refresh_token":self.refresh_token};
    [manager POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        //        <#code#>
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //        <#code#>
        NSLog(@"JSON: %@", responseObject);
//        NSDictionary *data = (NSDictionary *)responseObject;
//        self.access_token = [data objectForKey:@"access_token"];
//        self.refresh_token = [data objectForKey:@"refresh_token"];
//        self.token_type = [data objectForKey:@"token_type"];
//        self.expires_in = [data objectForKey:@"expires_in"];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //        <#code#>
        NSLog(@"Error: %@", error);
        
    }];
}
-(void)get{
    NSURL *URL = [NSURL URLWithString:@"https://api.thinger.io/v1/users/ROLLERTECH/devices"];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

    AFHTTPRequestSerializer *request = [[AFHTTPRequestSerializer alloc] init];
    [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json, text/plain, */*" forHTTPHeaderField:@"Accept"];
    [request setValue:@"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE0OTExMDE1ODQsImlhdCI6MTQ5MTA5NDM4NCwidXNyIjoiUk9MTEVSVEVDSCJ9.MVmHBgGCyK1uUFQNTzSahFgaheYhZZoHRwlckTUEKOk" forHTTPHeaderField:@"Authorization"];
    manager.requestSerializer = request;
    
    [manager GET:URL.absoluteString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}
-(void)getDeviceStatus:(NSString *)name complete:(void (^)(bool status))finishBlock{
//    GET https://api.thinger.io/v2/users/ROLLERTECH/devices/ESP8266/led1 status
    NSString *URL = [NSString stringWithFormat:@"https://api.thinger.io/v2/users/ROLLERTECH/devices/ESP8266/%@ status",name];
    URL = [URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    URL = [URL stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.u];

    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    AFHTTPRequestSerializer *request = [[AFHTTPRequestSerializer alloc] init];
    [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json, text/plain, */*" forHTTPHeaderField:@"Accept"];
    [request setValue:[NSString stringWithFormat:@"%@ %@",self.token_type,self.refresh_token] forHTTPHeaderField:@"Authorization"];
    manager.requestSerializer = request;
    NSLog(@"log: %@",[NSString stringWithFormat:@"%@ %@",@"Bearer",self.access_token]);
    [manager GET:URL parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSDictionary *data = (NSDictionary *)responseObject;
        finishBlock([data objectForKey:@"out"]);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        finishBlock(false);
    }];
}
-(void)post:(BOOL)onOff deviceName:(NSString *)deviceName
{
//    NSURL *url = [NSURL URLWithString:@"https://api.thinger.io/v2/users/ROLLERTECH/devices/ESP8266/led2"];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    AFHTTPRequestSerializer *request = [[AFJSONRequestSerializer alloc] init];
    [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json,text/plain" forHTTPHeaderField:@"Accept"];
    [request setValue:[NSString stringWithFormat:@"%@ %@",@"Bearer",self.access_token] forHTTPHeaderField:@"Authorization"];
    manager.requestSerializer = request;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/html", nil];
    /*
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/html",nil];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/plain",nil];
    [respone setValue:@"application/json" forKey:@"Content-Type"];
    [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"application/json"];
    manager.responseSerializer = respone;*/
    NSDictionary *params = @{@"in": onOff ? @false : @true};
    NSString *url = [NSString stringWithFormat:@"https://api.thinger.io/v2/users/ROLLERTECH/devices/ESP8266/%@",deviceName];
    [manager POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
//        <#code#>
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        <#code#>
        NSLog(@"JSON: %@", responseObject);

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        <#code#>
        NSLog(@"Error: %@", error);

    }];
}
@end
