//
//  HTKSampleCollectionViewCell.m
//  HTKDragAndDropCollectionView
//
//  Created by Henry T Kirk on 11/9/14.
//  Copyright (c) 2014 Henry T. Kirk (http://www.henrytkirk.info)
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "HTKSampleCollectionViewCell.h"

@implementation HTKSampleCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupCell];
    }
    return self;
}

- (void)setupCell {
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    // Create random background color
//    CGFloat hue = ( arc4random() % 256 / 256.0 );
//    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;
//    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;
//    UIColor *randomColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
//    self.backgroundColor = randomColor;
    self.bgView = [[UIView alloc]initWithFrame:CGRectZero];
    self.bgView.layer.cornerRadius = 10;
    self.bgView.layer.masksToBounds = YES;
    self.bgView.layer.borderWidth = 0.1;
    self.bgView.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.4].CGColor;
    self.bgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    [self.contentView addSubview:self.bgView];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_bgView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_bgView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_bgView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_bgView)]];
    //
    self.thumbView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.thumbView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.thumbView];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[_thumbView]-25-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_thumbView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[_thumbView]-15-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_thumbView)]];
    // create label
    self.numberLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.numberLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.numberLabel.textAlignment = NSTextAlignmentCenter;
    self.numberLabel.textColor = [UIColor whiteColor];
    self.numberLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
    [self.contentView addSubview:self.numberLabel];
    
    // Constrain it
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_numberLabel(20)]-5-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_numberLabel)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_numberLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_numberLabel)]];
}
-(void)layoutView:(CGSize)size{
    CGRect frame = self.bgView.frame;
    frame.size = CGSizeMake(size.width, size.height);
    self.bgView.frame = frame;
    
    CGRect frameThumbView = self.thumbView.frame;
    frameThumbView.size = CGSizeMake(size.width - 10, size.height - 30);
    self.thumbView.frame = frameThumbView;
}
@end
