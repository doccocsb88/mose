//
//  APPChildViewController.h
//  SmartHome
//
//  Created by Apple on 3/19/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageContentViewController.h"
#import "Room+CoreDataClass.h"
#import "CoredataHelper.h"
#import "HTKDragAndDropCollectionViewController.h"
//#import "CCMBorderView.h"
#import "MQTTService.h"
@interface APPChildViewController : UIViewController
@property (assign, nonatomic) NSInteger index;
@property (assign, nonatomic) NSInteger roomtype;
@property (strong, nonatomic) NSString *roomname;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) UINavigationController *navController;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

-(void)reloadData:(NSArray *)data;
-(void)reloadData;
@end
