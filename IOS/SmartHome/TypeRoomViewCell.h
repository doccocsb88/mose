//
//  TypeRoomViewCell.h
//  SmartHome
//
//  Created by Apple on 3/19/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Room+CoreDataClass.h"
#import "HTKDraggableCollectionViewCell.h"
@protocol RoomCellDelegate <NSObject>
-(void)didControlRoom:(NSInteger )roomId status:(BOOL)turnOn;
@end
@interface TypeRoomViewCell : HTKDraggableCollectionViewCell
@property (weak, nonatomic) id<RoomCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnail;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (assign, nonatomic) NSInteger roomId;
@property (weak, nonatomic) IBOutlet UIView *roomStatusView;
-(void)setContentView:(Room *)room;
@end
