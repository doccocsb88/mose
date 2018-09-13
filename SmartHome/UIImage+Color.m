//
//  UIImage+Color.m
//  SmartHome
//
//  Created by Apple on 4/22/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import "UIImage+Color.h"

@implementation UIImage (Color)
- (UIImage *)imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end
