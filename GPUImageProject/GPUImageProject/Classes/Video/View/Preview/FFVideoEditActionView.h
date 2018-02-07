//
//  FFVideoEditActionView.h
//  GPUImageProject
//
//  Created by avazuholding on 2017/9/29.
//  Copyright © 2017年 bert. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GPUImageBeautifyFilter;
@class FFVideoWaterMarkModel;
@protocol FFVideoEditActionViewDelegate<NSObject>
- (void)previewAction:(VideoViewActionType)actionType;
- (void)didSeletedFilter:(GPUImageOutput<GPUImageInput>*)filter waterMark:(FFVideoWaterMarkModel*)waterMark;
- (void)focusAtPoint:(CGPoint)point;

@end
#import "FFVideoPreview.h"

@interface FFVideoEditActionView : UIView
@property (nonatomic,strong) UIView *bgView;
@property (nonatomic,strong) UIView  *spaceView;//空白区,手势

@property (nonatomic,strong) UIButton *closeBtn;
@property (nonatomic,strong) UIButton *switchCameraBtn;
@property (nonatomic,strong) UIButton *flashBtn;
@property (nonatomic,strong) UIView *bottomView;//底部大的底图
@property (nonatomic,strong) UIScrollView *scrollView;

@property (nonatomic,strong) UIView *lineView;//
@property (nonatomic,strong) UICollectionView *collectionView;//filter
@property (nonatomic,strong) UICollectionView *waterMarkCollectionView;//filter
@property (nonatomic,strong) UIButton* filterBtn;
@property (nonatomic,strong) UIButton* waterMarkBtn;//water
@property (nonatomic,strong) UIButton *recordVideoBtn;

@property (nonatomic,strong) UILabel *timeLab;
@property (nonatomic,strong) UIView *focusView;
@property (nonatomic,strong) NSMutableArray *identifyArr;//滤镜解决上下滑动闪烁
@property (nonatomic,strong) NSMutableArray *filterArr;
@property (nonatomic,strong) NSMutableArray *wateMarkArr;
@property (nonatomic,strong) NSMutableArray *identifyWaterMarkArr;//水印解决上下滑动闪烁

@property (nonatomic,strong) GPUImageOutput<GPUImageInput> *currentFilter;

@property (nonatomic,strong) NSString *pathToMovie;
@property (nonatomic,strong) NSURL *movieURL;

@property (nonatomic,assign) BOOL isWaterMark;

@property (nonatomic,weak) id <FFVideoEditActionViewDelegate> editActionViewDelegate;


@end
