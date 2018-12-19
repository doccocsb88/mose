//
//  AddMenuViewController.h
//  SmartHome
//
//  Created by Apple on 3/23/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddMenuViewCell.h"
@protocol AddMenuDelegate <NSObject>
-(void)didShowAddDevice;
-(void)didShowQRCode;
-(void)didReadQRCode:(NSString *)message;
    
-(void)openSortRoom;
@end
@interface AddMenuViewController : UIViewController
@property (weak, nonatomic) id<AddMenuDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
