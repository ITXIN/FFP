//
//  FFWaterView.h
//  GPUImageProject
//
//  Created by avazuholding on 2017/9/29.
//  Copyright © 2017年 bert. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FFVideoWaterMarkModel;
@interface FFWaterView : UIView
@property (nonatomic,strong) UIView *bgView;
@property (nonatomic,strong) UIImageView *waterImage;
@property (nonatomic,strong) UILabel *waterDesLab;


- (void)setupWaterMarkWithModel:(FFVideoWaterMarkModel*)waterMarkModel;

@end
