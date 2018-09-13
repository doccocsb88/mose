//
//  MemberDetailViewController.h
//  SmartHome
//
//  Created by Apple on 1/8/18.
//  Copyright © 2018 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MemberDetailViewCell.h"
#import "CoredataHelper.h"
#import "SHMember.h"
#import "BaseViewController.h"
@interface MemberDetailViewController : BaseViewController
@property (strong, nonatomic) SHMember *member;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
