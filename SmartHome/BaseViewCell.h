//
//  BaseViewCell.h
//  SmartHome
//
//  Created by Apple on 3/31/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Device.h"
#import "Helper.h"
typedef enum {
    ButtonTypeOpen = 1,
    ButtonTypeClose,
    ButtonTypeStop
}ButtonType;
@protocol DeviceCellDelegate <NSObject>
-(void)didChangeCell:(NSInteger )deviceId value:(CGFloat )value;
@optional
-(void)didChangeCellState:(NSInteger)deviceId value:(BOOL)value;
-(void)didPressedButton:(NSInteger)deviceId value:(ButtonType)value;
-(void)didPressedControl:(NSInteger)deviceId;
@end
@interface BaseViewCell : UITableViewCell
@property (assign, nonatomic) BOOL isScene;
@property (weak, nonatomic) id<DeviceCellDelegate> delegate;
@property (strong, nonatomic) Device *device;
@end
