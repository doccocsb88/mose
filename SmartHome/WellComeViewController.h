//
//  WellComeViewController.h
//  SmartHome
//
//  Created by Apple on 1/13/18.
//  Copyright © 2018 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@interface WellComeViewController : BaseViewController
@property (nonatomic, assign) Boolean isNew;
@property (nonatomic, copy, ) void (^completion)(BOOL finished);
@end
