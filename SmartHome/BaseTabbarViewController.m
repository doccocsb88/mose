//
//  BaseTabbarViewController.m
//  SmartHome
//
//  Created by Apple on 3/30/17.
//  Copyright © 2017 Apple. All rights reserved.
//

#import "BaseTabbarViewController.h"

@interface BaseTabbarViewController ()

@end

@implementation BaseTabbarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    for (UITabBarItem *tbi in self.tabBar.items) {
        tbi.image = [tbi.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeToHomePage) name:@"kNotificationbackToHome" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)changeToHomePage{
    [self selectedPageAtIndex:0];
}
-(void)selectedPageAtIndex:(NSInteger)index{
    self.selectedViewController=[self.viewControllers objectAtIndex:0];//or whichever index you want

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
