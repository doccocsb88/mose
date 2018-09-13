//
//  Utils.m
//  SmartHome
//
//  Created by Ngoc Truong on 7/10/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import "Utils.h"
#import "CoredataHelper.h"
#import "Controller.h"
@implementation Utils
#define preft_topic @"pref_topic"
+(DeviceType)getDeviceType:(NSString *)topic{
//    if ([topic containsString:@"QA_CC_CT"] || [topic containsString:@"WC"]) {
//        return DeviceTypeCurtain;
//    }else if ([topic containsString:@"WT"]){
//        return DeviceTypeTouchSwitch;
//    }else if ([topic containsString:[Utils getTopic]]){
//        return DeviceTypeLightOnOff;
//    }
    Controller *controller = [[CoredataHelper sharedInstance] getControllerById:topic];
    if (controller) {
        return controller.type;
    }
    return DeviceTypeUnknow;
}

//+(BOOL)hasTopic:(NSString *)topic{
//    if([[CoredataHelper sharedInstance] getControllerById:topic]){
//        return true;
//    }
//    return false;
//    
//}
//
//+(void)setTopic:(NSString *)topic{
////    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
////    [pref setObject:topic forKey:preft_topic];
////    [pref synchronize];
//}
//+(NSString *)getTopic{
//    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
//    NSString *topic = [pref objectForKey:preft_topic];
//    return topic;
//}
+(Room *)getRoomWithId:(NSInteger)roomid in:(NSArray *)arrs{
    for (Room *room in arrs) {
        if (room.id   == roomid) {
            return room;
        }
    }
    return nil;
}
+(Room *)getRoomWithcode:(NSString *)code inData:(NSArray *)arrs{
    for (Room *room in arrs) {
        if ([room.code  isEqualToString:code]) {
            return room;
        }
    }
    return nil;
}
+ (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}
+ (UIImage *)imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
+(UIImage *)generateQRCode:(NSString *)qrString{
//    NSData *stringData = [qrString dataUsingEncoding: NSUTF8StringEncoding];
//
//    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
//    [qrFilter setValue:stringData forKey:@"inputMessage"];
//    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
//
//    CIImage *qrImage = qrFilter.outputImage;
//    return [UIImage imageWithCIImage:qrImage
//                                                 scale:[UIScreen mainScreen].scale
//                                           orientation:UIImageOrientationUp];
    
    // Generation of QR code image
    NSData *qrCodeData = [qrString dataUsingEncoding:NSISOLatin1StringEncoding]; // recommended encoding
    CIFilter *qrCodeFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrCodeFilter setValue:qrCodeData forKey:@"inputMessage"];
    [qrCodeFilter setValue:@"M" forKey:@"inputCorrectionLevel"]; //default of L,M,Q & H modes
    
    CIImage *qrCodeImage = qrCodeFilter.outputImage;
    
    CGRect imageSize = CGRectIntegral(qrCodeImage.extent); // generated image size
    CGSize outputSize = CGSizeMake(240.0, 240.0); // required image size
    CIImage *imageByTransform = [qrCodeImage imageByApplyingTransform:CGAffineTransformMakeScale(outputSize.width/CGRectGetWidth(imageSize), outputSize.height/CGRectGetHeight(imageSize))];
    
    UIImage *qrCodeImageByTransform = [UIImage imageWithCIImage:imageByTransform];
    return qrCodeImageByTransform;
    
    // Generation of bar code image
//    CIFilter *barCodeFilter = [CIFilter filterWithName:@"CICode128BarcodeGenerator"];
//    NSData *barCodeData = [qrString dataUsingEncoding:NSASCIIStringEncoding]; // recommended encoding
//    [barCodeFilter setValue:barCodeData forKey:@"inputMessage"];
//    [barCodeFilter setValue:[NSNumber numberWithFloat:7.0] forKey:@"inputQuietSpace"]; //default whitespace on sides of barcode
//    
//    CIImage *barCodeImage = barCodeFilter.outputImage;
//    self.imgViewBarCode.image = [UIImage imageWithCIImage:barCodeImage];
}
@end
