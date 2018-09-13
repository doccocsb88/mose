//
//  NSString+Utils.h
//  SmartHome
//
//  Created by Ngoc Truong on 7/10/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Utils)
-(BOOL)isNumber;
-(NSString *) randomStringWithLength: (int) len ;
@end
