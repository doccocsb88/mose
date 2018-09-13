//
//  NewSlider.m
//  SmartHome
//
//  Created by Apple on 9/6/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import "NewSlider.h"

@implementation NewSlider

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (CGRect)trackRectForBounds:(CGRect)bounds{
//    let customBounds = CGRect(origin: bounds.origin, size: CGSize(width: bounds.size.width, height: 5.0))
//    super.trackRect(forBounds: customBounds)
//    return customBounds
    CGRect customBounds =  CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, 8);
    return customBounds;
}
@end
