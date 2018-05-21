//
//  ZJExampleModel.h
//  MVVMFrameWork
//
//  Created by qyb on 2018/5/20.
//  Copyright © 2018年 qyb. All rights reserved.
//

#import "BaseModel.h"
#import "ZJExampleCellLayout.h"

@interface ZJExampleModel : BaseModel
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *imgUrl;
@property (nonatomic) NSString *content;
@property (nonatomic) NSString *date;
//布局信息相关
@property (nonatomic) ZJExampleCellLayout *layout;
@end
