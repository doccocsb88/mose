//
//  SceneDetailViewController.h
//  SmartHome
//
//  Created by Apple on 4/6/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "LightStateViewCell.h"
#import "LightValueViewCell.h"
#import "RemViewCell.h"
#import "FirebaseHelper.h"
#import "Scene.h"
#import "TouchSwitchViewCell.h"
@interface SceneDetailViewController : BaseViewController
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) Scene *scene;
@end
