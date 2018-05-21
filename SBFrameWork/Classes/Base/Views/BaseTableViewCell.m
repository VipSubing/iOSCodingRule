//
//  BaseTableViewCell.m
//  MVVMFrameWork
//
//  Created by qyb on 2018/5/20.
//  Copyright © 2018年 qyb. All rights reserved.
//

#import "BaseTableViewCell.h"

@implementation BaseTableViewCell

- (void)awakeFromNib {
    [self initContent];
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initContent];
    }
    return self;
}

- (void)initContent{
    //初始化视图
}
@end
