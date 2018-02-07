//
//  FFVideoFilterCell.m
//  GPUImageProject
//
//  Created by avazuholding on 2017/9/25.
//  Copyright © 2017年 bert. All rights reserved.
//

#import "FFVideoFilterCell.h"
#import "FFVideoFilterModel.h"
#import "FFVideoWaterMarkModel.h"
@implementation FFVideoFilterCell

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.imageView =  ({
            UIImageView *image = [[UIImageView alloc]init];
            [self.contentView addSubview:image];
            image.image = [UIImage imageNamed:@"preview"];
            image.layer.cornerRadius = 2;
            image.layer.masksToBounds = YES;
            image.contentMode = UIViewContentModeScaleAspectFit;
            image.backgroundColor = RGBA(0, 0, 0, 0.5);
            image;
        });
        
        self.nameLab = ({
            UILabel *label = [[UILabel alloc]init];
            [self.contentView addSubview:label];
            label.backgroundColor = RGBA(0, 0, 0, 0.5);
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont systemFontOfSize:14];
            label.textAlignment = NSTextAlignmentCenter;
            label;
        });
        [self setupLayoutSubviews];
    }
    return self;
}

- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    if (selected) {
        //选中时
        self.imageView.layer.borderWidth = 2;
        self.imageView.layer.borderColor = [RGB(39, 191, 250) CGColor];
    }else{
        //非选中
        self.imageView.layer.borderWidth = 0;
        self.imageView.layer.borderColor = [[UIColor clearColor] CGColor];
    }
}
- (void)setupFilterWithModel:(FFVideoFilterModel*)filterModel{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.nameLab.text = filterModel.filterName;
        if ([filterModel.filterName isEqualToString:@"无滤镜"]) {
            self.imageView.image = [UIImage imageNamed:@"no_filter"];
            self.imageView.contentMode = UIViewContentModeCenter;
        }else{
        
            GPUImageOutput<GPUImageInput>* output = filterModel.filter;
            if (output) {
                UIImage *currentFilteredVideoFrame = [output imageByFilteringImage:[UIImage imageNamed:@"preview"]];
                self.imageView.image = currentFilteredVideoFrame;
                self.imageView.contentMode = UIViewContentModeScaleAspectFit;
            }
        }
    });
}

- (void)setupWaterMarkWithModel:(FFVideoWaterMarkModel*)waterMarkModel{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.nameLab.text = waterMarkModel.waterMarkName;
        if ([waterMarkModel.waterMarkName isEqualToString:@"无"]) {
            self.imageView.image = [UIImage imageNamed:@"no_filter"];
            self.imageView.contentMode = UIViewContentModeCenter;
        }else{
            self.imageView.image = [UIImage imageNamed:waterMarkModel.waterMark];
            self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        }
    });
}




- (void)setupLayoutSubviews{
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
        make.center.equalTo(self.contentView);
    }];
    [self.nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.leading.equalTo(self.imageView);
        make.bottom.mas_equalTo(0);
    }];
}
@end
