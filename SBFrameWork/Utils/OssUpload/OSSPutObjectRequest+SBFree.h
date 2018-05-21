//
//  OSSPutObjectRequest+SBFree.h
//  www.qyb.QuanYouBaoParents
//
//  Created by qyb on 2017/8/2.
//  Copyright © 2017年 qyb. All rights reserved.
//

#import <AliyunOSSiOS/AliyunOSSiOS.h>

@interface OSSPutObjectRequest (SBFree)
@property (copy,nonatomic) NSString *endpoint;
@property (assign,nonatomic) NSUInteger flag;
@end
