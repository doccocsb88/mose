//
//  PageContentViewController.h
//  SmartHome
//
//  Created by Apple on 3/19/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APPChildViewController.h"
#import "Helper.h"
#import "AddMenuViewController.h"
#import "CoredataHelper.h"
#import "SortRoomViewController.h"
#import "HTKSampleCollectionViewController.h"
#import "BaseViewController.h"
#import "FirebaseHelper.h"
#import "User.h"
#import <Reachability.h>
@interface PageContentViewController : BaseViewController
@property (assign, nonatomic) NSInteger roomtype;
@property (strong, nonatomic) NSString *roomname;
@property (weak, nonatomic) IBOutlet UIView *stageView;
@property (weak, nonatomic) IBOutlet UILabel *connectionMessageLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *connectionLoading;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
//@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end
