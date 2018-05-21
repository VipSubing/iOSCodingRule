//
//  ZJExampleModel.m
//  MVVMFrameWork
//
//  Created by qyb on 2018/5/20.
//  Copyright © 2018年 qyb. All rights reserved.
//

#import "ZJExampleModel.h"

@implementation ZJExampleModel

- (void)modelingCompleted{
    [super modelingCompleted];
    _layout = [ZJExampleCellLayout new];
    _layout.contentHeight = [_content boundingRectWithSize:CGSizeMake(SCREEN_WIDTH-80, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:Content30PxH2Font} context:nil].size.height+1;
    _layout.dateTop = 10+_layout.contentHeight+10;
    _layout.cellHeight = _layout.dateTop + 15 + 10;
}
@end
