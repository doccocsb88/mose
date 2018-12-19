//
//  GalleryViewController.h
//  SmartHome
//
//  Created by Apple on 3/28/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "Room+CoreDataClass.h"
#import "FirebaseHelper.h"
@protocol GalleryDelegate <NSObject>
-(void)didChangeThumbnail;
@end
@interface GalleryViewController : BaseViewController
@property (weak, nonatomic) id<GalleryDelegate> delegate;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) Room *room;

@end
