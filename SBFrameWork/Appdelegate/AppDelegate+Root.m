//
//  AppDelegate+Root.m
//  MVVMFrameWork
//
//  Created by qyb on 2018/5/21.
//  Copyright © 2018年 qyb. All rights reserved.
//

#import "AppDelegate+Root.h"
#import "ZJExampleController.h"
#import "SBNavigationController.h"

@implementation AppDelegate (Root)
+ (UIViewController *)applicationRoot{
    CYLTabBarController *tab = [[CYLTabBarController alloc] init];
    NSDictionary * dict1 = @{CYLTabBarItemTitle:@"首页",
                             CYLTabBarItemImage:@"home_normal",
                             CYLTabBarItemSelectedImage:@"home_highlight"};
    
    NSArray * tabBarItemsAttributes = @[dict1];
    tab.tabBarItemsAttributes = tabBarItemsAttributes;
    [tab setViewControllers:[self tabItems]];
    
    return tab;
}

+ (NSArray *)tabItems{
    ZJExampleController *example = [[ZJExampleController alloc] init];
    SBNavigationController *exampleNavi = [[SBNavigationController alloc] initWithRootViewController:example];
    return @[exampleNavi];
}
@end