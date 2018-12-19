//
//  CameraPermissionViewController.h
//  SmartHome
//
//  Created by Macintosh HD on 9/14/18.
//  Copyright © 2018 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@interface CameraPermissionViewController : UIViewController
@property (assign, nonatomic) BOOL isDenie;
@property (nonatomic, copy, ) void (^completion)(BOOL finished);

@end
