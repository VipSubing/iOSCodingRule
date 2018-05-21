//
//  ZJExampleController.m
//  MVVMFrameWork
//
//  Created by qyb on 2018/5/18.
//  Copyright © 2018年 qyb. All rights reserved.
//

#import "ZJExampleController.h"
#import "ZJExampleCell.h"

@interface ZJExampleController ()
@property (nonatomic) NSArray *datas;
@end

@implementation ZJExampleController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Example";
    [self initContent];
}
- (NSArray *)datas{
    if (_datas == nil) {
        _datas = [NSArray new];
    }
    return _datas;
}
- (void)initContent{
    self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-StatusAndNaviBarHeight);
    [self.tableView registerClass:ZJExampleCell.class forCellReuseIdentifier:@"ZJExampleCell"];
}
#pragma mark - Request
//模拟的网络数据
- (NSArray *)simulateRequestDatas{
    NSMutableArray *datas = [NSMutableArray new];
    NSDictionary *json = @{@"name":@"subing",
                           @"content":@"MySQL是一个关系型数据库管理系统，由瑞典MySQL AB公司开发，目前属于Oracle公司。MySQL是一种关联数据库管理系统，关联数据库将数据保存在不同的表中，而不是将所有数据放在一个大仓库内，这样就增加了速度并提高了灵活性。",
                           @"date":@"2018-05-20 14:12:10"
                           };
    NSInteger count = 10;
    for (int i = 0; i < count; i ++) {
        ZJExampleModel *model = [ZJExampleModel modelWithDictionary:json];
        [datas addObject:model];
    }
    return datas.copy;
}
- (void)requestList{
    SBHttpRequest *reqeust = [SBHttpRequest defaultRequest];
    NSMutableDictionary *param = [SBHttpRequest defaultParam];
    [param setObject:@"" forKey:@"userId"];
    [param setObject:@"12345" forKey:@"ids"];
    [reqeust sendRequestUrl:@"" requestParameter:param completionWithSuccess:^(YTKRequest * _Nonnull request, id  _Nonnull responseObject) {
        //数据操作
        if (responseObject) {
            //返回成功，并且pageindex == 1，表示首次请求或者下拉刷新
            if (self.pageIndex == 1) {
                //清空数据
                self.datas = nil;
            }
            NSArray *datas = responseObject[@"datas"];
            NSMutableArray *sources = [NSMutableArray new];
            for (NSDictionary *json in datas) {
                ZJExampleModel *model = [ZJExampleModel modelWithDictionary:json];
                [sources addObject:model];
            }
            self.datas = [self.datas arrayByAddingObjectsFromArray:sources];
        }else{
            SBShowStatus(responseObject[@"msg"]);
        }
        //停止加载 调用父类的方法
        [self endRefresh];
        //当反馈没有更多数据时 关闭上拉加载
        if ([responseObject[@"hasmore"] isEqualToString:@"1"]) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
        //根据数据 判断是否显示占位图
        if (self.datas.count) {
            //有数据需要关闭占位图
            self.emptyServices.style.shouldDisplay = NO;
        }else{
            //无数据
            [self.emptyServices configEmptyForStyle:SBPlaceHolderStyleWithNotData];
        }
        //在末尾固定调用reloaddata 会根据self.emptyServices判断如何显示空的占位图
        [self.tableView reloadData];
    } failure:^(YTKRequest * _Nonnull request, NSError * _Nonnull error) {
        SBShowStatus(error.userInfo[SBRequestFailureErrorDescKey]);
        //没有数据
        if (!self.datas.count) {
            //链接失败 显示网络异常的占位图
            [self.emptyServices configEmptyForStyle:SBPlaceHolderStyleWithLostNet];
            self.emptyServices.style.title = error.userInfo[SBRequestFailureErrorDescKey];
        }
        
        //在末尾固定调用reloaddata 会根据self.emptyServices判断如何显示空的占位图
        [self.tableView reloadData];
    }];
#if DEBUG
    //模拟数据
    self.datas = [self simulateRequestDatas];
    [self endRefresh];
    [self.tableView.mj_footer endRefreshingWithNoMoreData];
#endif
}
#pragma mark - Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZJExampleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZJExampleCell"];
    cell.model = self.datas[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZJExampleModel *model = self.datas[indexPath.row];
    return model.layout.cellHeight;
}
@end
