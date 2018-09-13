//
//  GalleryViewController.m
//  SmartHome
//
//  Created by Apple on 3/28/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import "GalleryViewController.h"

@interface GalleryViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
{
    NSMutableArray *dataArray;
    CGSize screenSize;
}
@end

@implementation GalleryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    dataArray = [[NSMutableArray alloc] init];
    screenSize = [UIScreen mainScreen].bounds.size;
    [dataArray addObject:@"1"];
    [dataArray addObject:@"1"];
    [dataArray addObject:@"1"];
    [dataArray addObject:@"1"];
    [dataArray addObject:@"1"];
    [dataArray addObject:@"1"];
    [dataArray addObject:@"1"];
    [dataArray addObject:@"1"];
    [dataArray addObject:@"1"];
    [dataArray addObject:@"1"];
    [dataArray addObject:@"1"];
    [dataArray addObject:@"1"];
    [dataArray addObject:@"1"];
    [self setupNavigator];
}
-(void)setupNavigator{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.text = @"THƯ VIỆN";
    titleLabel.textColor = [Helper colorFromHexString:@"3fb2b5"];
    titleLabel.font = [UIFont systemFontOfSize:25];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:titleLabel];
    self.navigationItem.leftBarButtonItem = leftItem;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return dataArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = (screenSize.width - 40 )/3;
    return CGSizeMake(width, width);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"thumbCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    UIImageView *thumb = [cell viewWithTag:1];
    thumb.image = [UIImage imageNamed:[NSString stringWithFormat:@"ic_room_%ld",indexPath.row]];
    
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    self.room.image = [NSString stringWithFormat:@"ic_room_%ld",indexPath.row];
    [[CoredataHelper sharedInstance] save];
    [[FirebaseHelper sharedInstance] updateRoom:self.room];
    if ([self.delegate respondsToSelector:@selector(didChangeThumbnail)]) {
        [self.delegate didChangeThumbnail];
    }
    [self.navigationController popViewControllerAnimated:true];
}
@end
