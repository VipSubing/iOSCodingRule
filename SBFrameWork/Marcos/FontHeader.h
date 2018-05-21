//
//  FontHeader.h
//  MVVMFrameWork
//
//  Created by qyb on 2017/12/6.
//  Copyright © 2017年 qyb. All rights reserved.
//

#ifndef FontHeader_h
#define FontHeader_h

//字号列举
#define AdaptiveFont(fontFloat) [UIFont systemFontOfSize:fontFloat*AdaptiveScreen]

/* 苹方 - 简体  H1 中黑体 H2 常规体  H3 细体 */

// 标题 title
#define Title36PxH1Font [UIFont fontWithName:@"PingFangSC-Medium" size:14] //H1标题 36Px

#define Title34PxH2Font [UIFont fontWithName:@"PingFangSC-Regular" size:13] //H2标题 34Px

#define Title32PxH2Font [UIFont fontWithName:@"PingFangSC-Regular" size:12] //H3标题 32Px

//内容 content
#define Content30PxH2Font [UIFont fontWithName:@"PingFangSC-Regular" size:11] //H2正文 30Px

#define Content30PxH3Font [UIFont fontWithName:@"PingFangSC-Light" size:11] //H2正文 30Px

#define Content28PxH3Font [UIFont fontWithName:@"PingFangSC-Light" size:10.5] //H2正文 30Px

// 描述 Desc
#define Desc24PxH3Font [UIFont fontWithName:@"PingFangSC-Light" size:9] //H2正文 30Px

#endif /* FontHeader_h */
