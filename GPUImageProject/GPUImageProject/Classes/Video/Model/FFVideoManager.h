//
//  FFVideoManager.h
//  GPUImageProject
//
//  Created by avazuholding on 2017/9/25.
//  Copyright © 2017年 bert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class FFWaterView;
@class FFVideoWaterMarkModel;

typedef void (^TimerActionTypeBlock)();
@interface FFVideoManager : NSObject
+(FFVideoManager *)sharedInstance;
@property (nonatomic, strong) GPUImageStillCamera *videoCamera;

//@property (nonatomic, copy) TimerActionTypeBlock timerActionTypeBlock;
- (NSArray*)createGPUFilterArr;
- (NSArray*)createWaterMark;
- (UIView*)waterViewWithModel:(FFVideoWaterMarkModel*)waterMarkModel;

//人脸识别
- (NSArray*)faceRecognitionWithImage:(UIImage*)image;
- (UIImage *)fixOrientationFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;
- (CGRect)getUIImageViewRectFromCIImageRect:(CGRect)originAllRect;
//- (NSArray*)detectFaceWithImage:(UIImage*)faceImage;
- (NSArray*)detectFaceMarkWithImage:(UIImage*)image;
- (UIImage*)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;
//- (UIImage*)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;
- (void)timerInvalidate;
- (void)createTimerActionTypeBlock:(TimerActionTypeBlock)timerActionTypeBlock;
@end
