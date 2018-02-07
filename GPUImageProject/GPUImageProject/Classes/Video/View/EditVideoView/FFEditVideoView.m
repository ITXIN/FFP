//
//  FFEditVideoView.m
//  GPUImageProject
//
//  Created by avazuholding on 2017/9/28.
//  Copyright © 2017年 bert. All rights reserved.
//

#import "FFEditVideoView.h"

@implementation FFEditVideoView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initSubviews];
        [self setupLayoutSubviews];
    }
    return self;
}
#pragma mark - 
- (void)initSubviews{
    self.bgView = ({
        UIView *view = [[UIView alloc]init];
        [self addSubview:view];
        
        view;
    });
    
//    self.preImageView = [[GPUImageView alloc]initWithFrame:self.bounds];
//    [self.bgView addSubview:self.preImageView];
//    self.imageMovie = [[GPUImageMovie alloc]initWithURL:self.pathURL];
//    self.imageMovie.shouldRepeat = YES;//循环
//    [self.imageMovie addTarget:self.preImageView];
//    [self.imageMovie startProcessing];
    
    
    self.headerView = ({
        UIView *view = [[UIView alloc]init];
        [self addSubview:view];
        view.backgroundColor = RGBA(0, 0, 0, 0.5);
        view;
    });
    
    self.bottomView = ({
        UIView *view = [[UIView alloc]init];
        [self addSubview:view];
        view.backgroundColor = RGBA(0, 0, 0, 0.5);
        view;
    });
    
    
    self.retryRecordBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.headerView addSubview:btn];
        btn.tag = EditVideoViewActionTypeRetryRecord;
        [btn addTarget:self action:@selector(editVideoViewAction:) forControlEvents:UIControlEventTouchUpInside];
        [btn setImage:[UIImage imageNamed:@"filter_normal"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"filter_seleted"] forState:UIControlStateSelected];
        btn;
    });
    self.saveBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.bottomView addSubview:btn];
        btn.tag = EditVideoViewActionTypeSave;
        [btn addTarget:self action:@selector(editVideoViewAction:) forControlEvents:UIControlEventTouchUpInside];
        [btn setImage:[UIImage imageNamed:@"filter_normal"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"filter_seleted"] forState:UIControlStateSelected];
        btn;
    });
    
}
#pragma mark - editVideoViewAction
- (void)editVideoViewAction:(UIButton*)sender{
    if (self.editVideoDelegate && [self.editVideoDelegate respondsToSelector:@selector(editVideoAction:)]) {
        [self.editVideoDelegate editVideoAction:sender.tag];
    }
}
- (void)setupLayoutSubviews{
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.bgView);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(44);
    }];
    [self.retryRecordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.headerView);
        make.left.mas_equalTo(30);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.bgView);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(44);
    }];
    [self.saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bottomView);
        make.right.mas_equalTo(-30);
    }];
}

@end
