//
//  NSString+Utils.m
//  SmartHome
//
//  Created by Ngoc Truong on 7/10/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import "NSString+Utils.h"

@implementation NSString (Utils)
-(BOOL)isNumber{
    NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    if ([self rangeOfCharacterFromSet:notDigits].location == NSNotFound)
    {
        // newString consists only of the digits 0 through 9
        return true;
    }
    return false;
}
    
-(NSString *) randomStringWithLength: (int) len {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
    
    return randomString;
}
@end
