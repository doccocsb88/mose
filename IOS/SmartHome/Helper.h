//
//  Helper.h
//  SmartHome
//
//  Created by Apple on 3/23/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Helper : NSObject
+ (UIColor *)colorFromHexString:(NSString *)hexString ;
+ (UIImage *)imageFromColor:(UIColor *)color ;
+ (UIImage *)createDimImage:(UIImage *)image;

@end
