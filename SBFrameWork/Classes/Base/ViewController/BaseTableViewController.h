//
//  BaseTableViewController.h
//  MVVMFrameWork
//
//  Created by qyb on 2017/12/11.
//  Copyright © 2017年 qyb. All rights reserved.
//
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "BaseViewController.h"
#import "SBTableView.h"
#import "EmptyDataSetServices.h"

//请求状态
typedef NS_ENUM(NSInteger,SBRequestStatus){
    SBRequestWithNomal, //正常状态
    SBRequestWithDoing //请求中
};
@interface BaseTableViewController : BaseViewController<UITableViewDelegate ,UITableViewDataSource>

/// The table view for tableView controller.

@property (nonatomic, readonly, strong) SBTableView *tableView;

/// 需要支持下来刷新 defalut is YES
@property (nonatomic, readwrite, assign) BOOL shouldPullDownToRefresh;
/// 需要支持上拉加载 defalut is YES
@property (nonatomic, readwrite, assign) BOOL shouldPullUpToLoadMore;
/// 当前页 defalut is 1
@property (nonatomic, readwrite, assign) NSUInteger pageIndex;
//自动请求第一页数据 default YES  需要 YES
@property (nonatomic,assign) BOOL autoRequestFirstPageDatas;
//是否需要暂位图 在没有数据时候
@property (nonatomic,assign) BOOL needEmptyPlaceHold;
//tableview style 默认 UITableViewStylePlain;
@property (nonatomic,assign) UITableViewStyle tableViewStyle;
//无数据时候占位代理服务
@property (strong,nonatomic) EmptyDataSetServices *emptyServices;
//没有数据时是否加载缓存数据 默认 no
@property (nonatomic) BOOL loadCacheDatas;
//默认请求方法 子类需覆盖
- (void)requestList;
//结束刷新状态
- (void)endRefresh;
@end
