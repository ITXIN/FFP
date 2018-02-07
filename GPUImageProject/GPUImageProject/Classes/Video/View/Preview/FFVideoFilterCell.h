//
//  FFVideoFilterCell.h
//  GPUImageProject
//
//  Created by avazuholding on 2017/9/25.
//  Copyright © 2017年 bert. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FFVideoFilterModel;
@class FFVideoWaterMarkModel;
@interface FFVideoFilterCell : UICollectionViewCell
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UILabel *nameLab;
- (void)setSelected:(BOOL)selected;
- (void)setupFilterWithModel:(FFVideoFilterModel*)filterModel;
- (void)setupWaterMarkWithModel:(FFVideoWaterMarkModel*)waterMarkModel;
@end
