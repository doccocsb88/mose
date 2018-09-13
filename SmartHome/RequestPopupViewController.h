//
//  RequestPopupViewController.h
//  SmartHome
//
//  Created by Apple on 1/13/18.
//  Copyright © 2018 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@protocol RequestPopupDelegate <NSObject>
-(void)didSelectNext;
@end
@interface RequestPopupViewController : BaseViewController
@property (weak, nonatomic) id<RequestPopupDelegate> delegate;
@end
