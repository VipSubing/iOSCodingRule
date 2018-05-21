//
//  ZJExampleCell.m
//  MVVMFrameWork
//
//  Created by qyb on 2018/5/20.
//  Copyright © 2018年 qyb. All rights reserved.
//

#import "ZJExampleCell.h"
#import "UIImageView+SBUserDisplay.h"

static CGFloat kCellTopSpace = 10;
static CGFloat kCellBottomSpace = 10;

@implementation ZJExampleCell
{
    UIImageView *_headImageView;
    UILabel *_nameLabel;
    UILabel *_contentLabel;
    UILabel *_dateLabel;
}
- (void)initContent{
    self.backgroundColor = [UIColor whiteColor];
    _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, kCellTopSpace, 50, 50)];
    [self.contentView addSubview:_headImageView];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_headImageView.left, _headImageView.bottom+10, _headImageView.width, 20)];
    _nameLabel.font = Content28PxH3Font;
    _nameLabel.textColor = ContentDefaultColor;
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_nameLabel];
    
    _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(_headImageView.right+10, kCellTopSpace, SCREEN_WIDTH-_headImageView.right-20, 0)];
    _contentLabel.font = Content30PxH2Font;
    _contentLabel.textColor = ContentDefaultColor;
    _contentLabel.numberOfLines = 0;
    [self.contentView addSubview:_contentLabel];
    
    _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-80-kCellBottomSpace, 0, 80, 15)];
    _dateLabel.font = Desc24PxH3Font;
    _dateLabel.textColor = DescDefaultColor;
    _dateLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_dateLabel];
}
- (void)setModel:(ZJExampleModel *)model{
    _model = model;
    [_headImageView sb_setName:model.name imageUrl:model.imgUrl];
    _nameLabel.text = model.name;
    _contentLabel.text = model.content;
    _dateLabel.text = model.date;
    
    //layout
    _contentLabel.height = model.layout.contentHeight;
    _dateLabel.top = model.layout.dateTop;
}
@end
