//
//  HTKSampleCollectionViewController.m
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

#import "HTKSampleCollectionViewController.h"
#import "HTKSampleCollectionViewCell.h"

@interface HTKSampleCollectionViewController ()
{
    CGFloat cellWidth;
    CGFloat cellHeight;
}
/**
 * Sample data array we're reordering
 */
//@property (strong, nonatomic) UIButton *rightButton;
@property (strong, nonatomic) UIButton *leftButton;
@end

@implementation HTKSampleCollectionViewController

//- (instancetype)init {
//    self = [super init];
//    if (self) {
//        // Create Array for Demo data and fill it with some items
//        _dataArray = [NSMutableArray array];
//        for (NSUInteger i = 0; i < 15; i++) {
//            [_dataArray addObject:[NSString stringWithFormat:@"%lu", i]];
//        }
//        [self setup];
//    }
//    return self;
//}

- (void)setup {
    // basic setup
    self.title = @"Drag & Drop Demo";
    // Add button that will "add" item to demo
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(userDidTapAddButton:)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigator];
    // Register cell
    // If you are using Storyboards/Nibs, make sure you "registerNib:" instead.
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64)];
    bgView.image = [UIImage imageNamed:@"ic_background"];
    [self.view addSubview:bgView];
    [self.collectionView registerClass:[HTKSampleCollectionViewCell class] forCellWithReuseIdentifier:HTKDraggableCollectionViewCellIdentifier];
    
    // Setup item size
    HTKDragAndDropCollectionViewLayout *flowLayout = (HTKDragAndDropCollectionViewLayout *)self.collectionView.collectionViewLayout;
    cellWidth = (self.view.frame.size.width - 40 )/3;
    cellHeight = (self.view.frame.size.height - 114 - 90) / 4;
//    CGFloat itemWidth = CGRectGetWidth(self.collectionView.bounds) / 3 - 60;
    flowLayout.itemSize = CGSizeMake(cellWidth, cellHeight);
//    flowLayout.minimumInteritemSpacing = 20;
    flowLayout.lineSpacing = 20;
//    flowLayout.sectionInset = UIEdgeInsetsMake(20, 20, 20, 20);
    self.collectionView.contentInset = UIEdgeInsetsMake(5, 5, 5, 5);
    [self.collectionView removeFromSuperview];
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.collectionView];
}
-(void)setupNavigator{
    //
    self.leftButton = [[UIButton alloc] init];
    self.leftButton.frame = CGRectMake(0, 0, 40, 40);
    self.leftButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.leftButton setImage:[UIImage imageNamed:@"ic_back"] forState:UIControlStateNormal];
    [self.leftButton addTarget:self action:@selector(pressedLeft:) forControlEvents:UIControlEventTouchUpInside];
    self.leftButton.backgroundColor = [UIColor clearColor];
    self.leftButton.layer.cornerRadius = 3;
    self.leftButton.layer.masksToBounds = YES;
    self.leftButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:self.leftButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    self.navigationItem.title = @"Sắp xếp phòng";
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
}
#pragma mark - User Actions

- (void)userDidTapAddButton:(id)sender {
    // Called when user taps the "+" button in nav bar
    // Add another item to the demo
    NSUInteger count = self.dataArray.count;
    NSString *newItem = [NSString stringWithFormat:@"%lu", count];
    [self.dataArray addObject:newItem];
    [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:count inSection:0]]];
}

#pragma mark - UICollectionView Datasource/Delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HTKSampleCollectionViewCell *cell = (HTKSampleCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:HTKDraggableCollectionViewCellIdentifier forIndexPath:indexPath];
    Room *room = self.dataArray[indexPath.row];

    // Set number on cell
    cell.numberLabel.text = room.name;
    cell.thumbView.image = [UIImage imageNamed:room.image];
    // Set our delegate for dragging
    cell.draggingDelegate = self;
    [cell layoutView:CGSizeMake(cellWidth, cellHeight)];
    return cell;
}

#pragma mark - HTKDraggableCollectionViewCellDelegate

- (BOOL)userCanDragCell:(UICollectionViewCell *)cell {
    // All cells can be dragged in this demo
    return YES;
}

- (void)userDidEndDraggingCell:(UICollectionViewCell *)cell {
    
    HTKDragAndDropCollectionViewLayout *flowLayout = (HTKDragAndDropCollectionViewLayout *)self.collectionView.collectionViewLayout;

    // Save our dragging changes if needed
    if (flowLayout.finalIndexPath != nil) {
        // Update datasource
        Room *objectToMove = [self.dataArray objectAtIndex:flowLayout.draggedIndexPath.row];
//        NSInteger order = objectToMove.order;
//        Room *objectMoveTo = [self.dataArray objectAtIndex:flowLayout.finalIndexPath.row];
//        objectToMove.order = objectMoveTo.order;
//        objectMoveTo.order = order;
        [self.dataArray removeObjectAtIndex:flowLayout.draggedIndexPath.row];
        [self.dataArray insertObject:objectToMove atIndex:flowLayout.finalIndexPath.row];
        for (NSInteger index = 0; index < self.dataArray.count; index ++) {
            Room *room = [self.dataArray objectAtIndex:index];
            room.order = index;
        }
        [[CoredataHelper sharedInstance] save];
    }
    
    // Reset
    [flowLayout resetDragging];
}


-(void)pressedLeft:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSortRoom)]) {
        [self.delegate didSortRoom];
    }
    [[CoredataHelper sharedInstance] save];

    [self.navigationController popViewControllerAnimated:YES];
}
@end
