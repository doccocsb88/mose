//
//  User.h
//  SmartHome
//
//  Created by Apple on 1/8/18.
//  Copyright © 2018 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@import Firebase;
typedef enum AccountType:NSInteger{
    AccountTypeUnknow,
    AccountTypeAdmin,
    AccountTypeMember
}AccountType;
@interface User : NSObject /*NSManagedObject*/
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *displayName;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *node;
@property (assign, nonatomic) BOOL active;
@property (assign, nonatomic) BOOL isShared;

@property (assign, nonatomic) AccountType accountType;
//
@property (strong, nonatomic) NSArray *devices;
+ (instancetype)sharedInstance;
-(void)setData:(FIRDataSnapshot *)snapshot;
-(void)setDevicesData:(FIRDataSnapshot *)snapshot;
-(BOOL)isAdmin;
-(BOOL)isAuthentication;
-(BOOL)canControlDevice:(NSString *)mqttId;
-(void)loadObjectFromLocal;
-(void)clearData;
-(NSString *)getNode;
@end

