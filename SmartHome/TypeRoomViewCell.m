//
//  TypeRoomViewCell.m
//  SmartHome
//
//  Created by Apple on 3/19/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import "TypeRoomViewCell.h"

@implementation TypeRoomViewCell
-(void)awakeFromNib{
    [super awakeFromNib];
    self.containerView.layer.cornerRadius = 10;
    self.containerView.layer.masksToBounds = YES;
    self.containerView.layer.borderWidth = 0.1;
    self.containerView.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.4].CGColor;
    self.roomStatusView.layer.cornerRadius = self.roomStatusView.frame.size.width * 0.5;
    self.roomStatusView.layer.masksToBounds = true;
    self.roomStatusView.backgroundColor = [UIColor redColor];
    //
    UIPanGestureRecognizer * panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    //UIPanGestureRecognizer(target: self, action: #selector(self.pagesCollectionViewItemPanEvent(_:)))
    [self addGestureRecognizer:panGesture];
    if ([[UIScreen mainScreen ] bounds].size.height <= 568) {
        self.nameLabel.font = [UIFont systemFontOfSize:13];
    }

}
-(void)setContentView:(Room *)room{
    self.roomId = room.id;
    self.nameLabel.text = room.name;
    self.thumbnail.image = [UIImage imageNamed:room.image];
    if ([room hasDeviceOn]) {
        self.roomStatusView.backgroundColor = [UIColor redColor];

    }else{
        self.roomStatusView.backgroundColor = [UIColor lightGrayColor];

    }
}

-(void)handlePan:(UIPanGestureRecognizer *)recognizer{
//    NSLog(@"panGesture");
    CGPoint translation = [recognizer translationInView:self.contentView];
//    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
//                                         recognizer.view.center.y + translation.y);
//    [recognizer setTranslation:CGPointMake(0, 0) inView:self.contentView];
    if (recognizer.state == UIGestureRecognizerStateBegan) {
//        CGPoint velocity = [recognizer velocityInView:self.contentView];
        NSLog(@"begin : %f -- %f",translation.x, translation.y);
    }else if (recognizer.state == UIGestureRecognizerStateEnded) {

        CGPoint zzz = [recognizer translationInView:self.contentView];
        if (zzz.y < -20) {
            NSLog(@"go up");
            if (self.delegate && [self.delegate respondsToSelector:@selector(didControlRoom:status:)]) {
                [self.delegate didControlRoom:_roomId status:NO];
            }
        }else if(zzz.y > 20){
            NSLog(@"go down");
            if (self.delegate && [self.delegate respondsToSelector:@selector(didControlRoom:status:)]) {
                [self.delegate didControlRoom:_roomId status:YES];
            }
        }

    }
}
@end
