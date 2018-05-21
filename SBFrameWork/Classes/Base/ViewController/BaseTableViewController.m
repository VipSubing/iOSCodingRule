//
//  BaseTableViewController.m
//  MVVMFrameWork
//
//  Created by qyb on 2017/12/11.
//  Copyright © 2017年 qyb. All rights reserved.
//

#import "BaseTableViewController.h"
#import "MJRefresh.h"
@interface BaseTableViewController ()
/// tableView
@property (nonatomic, readwrite, strong)  SBTableView *tableView;
@end

@implementation BaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _pageIndex = 1;
    _autoRequestFirstPageDatas = YES;
    _needEmptyPlaceHold = YES;
    _tableViewStyle = UITableViewStylePlain;
    self.shouldPullDownToRefresh = YES;
    self.shouldPullUpToLoadMore = YES;
    //设置tableview
    [self.view addSubview:self.tableView];
    
    @weakify(self);
    //无数据时候点击占位图view
    self.emptyServices.didEmptyViewBlock = ^(UIScrollView *scrollView, UIView *tapView) {
        @strongify(self);
        self.emptyServices.style.isLoading = YES;
        [self requestList];
    };
    //无数据时候点击占位图button
    self.emptyServices.didTouchButtonBlock = ^(UIScrollView *scrollView, UIButton *button) {
        @strongify(self);
        self.emptyServices.style.isLoading = YES;
       
    };
    //开启自动加载数据
    if (self.autoRequestFirstPageDatas) {
        [self.emptyServices configEmptyForStyle:SBPlaceHolderStyleWithLoading];
        [self requestList];
    }
    //需要设置才能自动刷新dataSet
    self.emptyServices.updateEmptyLayoutBlock = ^{
        @strongify(self);
        [self.tableView reloadEmptyDataSet];
    };
    
//    if (x.count == 0 && self.pageIndex == 1) {
//        [self.emptyServices configEmptyForStyle:SBPlaceHolderStyleWithNotData];
//    }else{
//        self.emptyServices.style.shouldDisplay = NO;
//    }
//    //无数据时候提示网络异常
//    if (self.pageIndex == 1 && self.datas.count == 0) {
//        [self.emptyServices configEmptyForStyle:SBPlaceHolderStyleWithLostNet];
//    }
}



- (void)endRefresh{
    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];
}
#pragma mark   SubClass Should Override{
- (void)requestList{
    
}

#pragma mark   -  Override
- (void)setShouldPullDownToRefresh:(BOOL)shouldPullDownToRefresh{
    _shouldPullDownToRefresh = shouldPullDownToRefresh;
    if (shouldPullDownToRefresh == YES) {
        __weak typeof(self) weak = self;
        self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            weak.pageIndex = 1;
            [weak requestList];
        }];
    }else{
        [self.tableView.mj_header endRefreshing];
        self.tableView.mj_header = nil;
    }
}
- (void)setShouldPullUpToLoadMore:(BOOL)shouldPullUpToLoadMore{
    _shouldPullUpToLoadMore = shouldPullUpToLoadMore;
    if (shouldPullUpToLoadMore == YES) {
        __weak typeof(self) weak = self;
        if (!self.tableView.mj_footer) {
            self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
                weak.pageIndex ++;
                [weak requestList];
            }];
        }else{
            self.tableView.mj_footer.hidden = NO;
            self.tableView.mj_footer.userInteractionEnabled = YES;
        }
    }else {
        if (self.tableView.mj_footer) {
            self.tableView.mj_footer.hidden = YES;
            self.tableView.mj_footer.userInteractionEnabled = NO;
        }
    }
}
- (SBTableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[SBTableView alloc] initWithFrame:CGRectZero style:self.tableViewStyle];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.emptyDataSetSource = self.emptyServices;
        _tableView.emptyDataSetDelegate = self.emptyServices;
    }
    return _tableView;
}
- (EmptyDataSetServices *)emptyServices{
    if (_emptyServices == nil) {
        _emptyServices = [[EmptyDataSetServices alloc] init];
    }
    return _emptyServices;
}
@end
