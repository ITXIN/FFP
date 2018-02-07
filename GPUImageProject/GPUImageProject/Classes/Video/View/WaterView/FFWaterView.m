//
//  FFWaterView.m
//  GPUImageProject
//
//  Created by avazuholding on 2017/9/29.
//  Copyright © 2017年 bert. All rights reserved.
//

#import "FFWaterView.h"
#import "FFVideoWaterMarkModel.h"
@implementation FFWaterView
- (instancetype)init{
    self = [super init];
    if (self)
    {
         [self initSubview];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initSubview];
    }
    return self;
}

- (void)initSubview{
//    self.backgroundColor = [UIColor clearColor];
    self.bgView = ({
        UIView *view = [[UIView alloc]init];
        [self addSubview:view];
//        view.backgroundColor = [UIColor clearColor];
        view;
    });
    
  
    
    self.waterImage =  ({
        UIImageView *image = [[UIImageView alloc]init];
        [self.bgView addSubview:image];
//        image.backgroundColor = [UIColor redColor];
//        image.image = [UIImage imageNamed:@""];
        image;
    });
    self.waterDesLab = ({
        UILabel *label = [[UILabel alloc]init];
        [self.bgView addSubview:label];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:14];
        label;
    });
    //不能使用masonry
    self.waterImage.contentMode = UIViewContentModeScaleAspectFill;
    self.bgView.frame = self.frame;
    self.waterImage.frame = self.bounds;
    self.waterImage.center = self.bgView.center;
//    [self.waterImage mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.center.equalTo(self.bgView);
//        make.size.mas_equalTo(CGSizeMake(200, 150));
//    }];
    self.waterDesLab.frame = CGRectMake(100, 100, 100, 30);

}


- (void)setupWaterMarkWithModel:(FFVideoWaterMarkModel*)waterMarkModel{
    dispatch_async(dispatch_get_main_queue(), ^{
//        self.bgView.backgroundColor = [UIColor yellowColor];
        FFLOG(@"%@  %@",waterMarkModel.waterMarkName,waterMarkModel.waterMark);
//        self.waterDesLab.text = waterMarkModel.waterMarkName;
        if (!waterMarkModel) {
            self.waterImage.image = [UIImage imageNamed:@""];
//            self.waterImage.contentMode = UIViewContentModeCenter;
        }else{
            self.waterImage.image = [UIImage imageNamed:waterMarkModel.waterMark];
//            self.waterImage.contentMode = UIViewContentModeScaleAspectFit;
            
        }
    });
}


//- (void)layoutSubviews{
//    [super layoutSubviews];
//- (void)setupSubviewsLayout{
    
//    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self);
//    }];
//    [self.waterImage mas_makeConstraints:^(MASConstraintMaker *make) {
//        //        make.edges.equalTo(self);
//        make.center.equalTo(self.bgView);
////        make.size.mas_equalTo(CGSizeMake(200, 200));
//
//    }];
//    [self.waterDesLab mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(self.bgView);
//        make.top.mas_equalTo(self.waterImage.mas_bottom).offset(10);
//    }];
//}

@end
