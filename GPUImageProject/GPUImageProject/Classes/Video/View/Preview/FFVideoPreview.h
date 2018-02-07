//
//  FFVideoPreview.h
//  GPUImageProject
//
//  Created by avazuholding on 2017/9/25.
//  Copyright © 2017年 bert. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GPUImageBeautifyFilter;
@class FFVideoWaterMarkModel;

@protocol FFVideoPreviewDelegate<NSObject>

- (void)takePhotoSuccess:(UIImage*)image;

@end
@interface FFVideoPreview : UIView
@property (nonatomic,strong) UIView *bgView;

//GPUImage
@property (nonatomic,strong) GPUImageStillCamera *videoCamera;
//屏幕上显示的View
@property (nonatomic,strong) GPUImageView *filterView;
@property (nonatomic,strong) GPUImageMovieWriter * movieWriter;
@property (nonatomic,strong) GPUImageOutput<GPUImageInput> *currentFilter;
@property (nonatomic,strong) FFVideoWaterMarkModel *currentWaterMark;

@property (nonatomic,strong) NSMutableArray *filterArr;
@property (nonatomic,strong) NSMutableArray *wateMarkArr;

@property (nonatomic,strong) NSString *pathToMovie;
@property (nonatomic,strong) NSURL *movieURL;
@property (nonatomic,assign) id <FFVideoPreviewDelegate> videoPreviewDelegate;
- (void)makeFilterWithFilter:(GPUImageOutput<GPUImageInput>*)filter waterMark:(FFVideoWaterMarkModel*)waterMark;

- (void)startRecordVideo;
- (void)endRecordVideo;
- (void)switchCamera;
- (void)flashLightAction;
- (void)focusWithPoint:(CGPoint)focusPoint;
- (void)takePhoto;
@end
