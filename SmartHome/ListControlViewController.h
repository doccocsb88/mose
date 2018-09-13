//
//  ListControlViewController.h
//  SmartHome
//
//  Created by Apple on 3/20/18.
//  Copyright © 2018 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Controller.h"
@interface ListControlViewController : UIViewController
@property (strong, nonatomic)  void(^handleAddControl)(void);
@property (strong, nonatomic)  void(^handleSelectControl)(Controller *);
-(void)reloadData;
@end
