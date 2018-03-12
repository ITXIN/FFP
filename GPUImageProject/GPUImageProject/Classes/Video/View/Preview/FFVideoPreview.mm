//
//  FFVideoPreview.m
//  GPUImageProject
//
//  Created by avazuholding on 2017/9/25.
//  Copyright © 2017年 bert. All rights reserved.
//

#import "FFVideoPreview.h"
#import "GPUImageBeautifyFilter.h"
#import "FFVideoManager.h"
#import "FFVideoFilterCell.h"
#import "FFVideoFilterModel.h"
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <Photos/Photos.h>
#import "FFCircularProcessView.h"
#import "FFWaterView.h"
#import "FFVideoWaterMarkModel.h"

#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>

#import "GPUFacekitOutput.h"

static NSString * _Nonnull const LFBeautyBase           = @"faceuEffect/new_beauty3";

@interface FFVideoPreview ()<UIGestureRecognizerDelegate,GPUImageVideoCameraDelegate,AVCaptureMetadataOutputObjectsDelegate>
{
    GPUImageAlphaBlendFilter *currentBlendFilter;

    NSBundle    *resBundle;
    CMSampleBufferRef currentSampleBuffer;
}

//@property (nonatomic,strong) FFWaterView *waterView;
@property (nonatomic,strong) UIImageView* mouth;
@property (nonatomic,strong) UIImageView* leftEye;
@property (nonatomic,strong) UIImageView* rightEye;
@property (nonatomic,strong) UIImageView* faceView;

@property (nonatomic, strong) GPUFacekitOutput              *facekitOutput;
@property (nonatomic, strong) LMRenderEngine                *renderEngine;

// 照片输出流对象
@property (nonatomic, strong)AVCaptureStillImageOutput *stillImageOutput;

@end

@implementation FFVideoPreview
- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [[FFVideoManager sharedInstance]timerInvalidate];
}
- (GPUImageMovieWriter *)movieWriter{
    if (!_movieWriter) {
        _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:self.movieURL size:CGSizeMake(kPressetWidth, kPressetHeight)];
        _movieWriter.encodingLiveVideo = YES;
        _movieWriter.shouldPassthroughAudio = YES;
    }
    return _movieWriter;
}

- (NSMutableArray *)wateMarkArr{
    if (!_wateMarkArr) {
        _wateMarkArr = [NSMutableArray arrayWithArray:[[FFVideoManager sharedInstance]createWaterMark]];
    }
    return _wateMarkArr;
}
- (NSMutableArray *)filterArr{
    if (!_filterArr) {
        _filterArr = [NSMutableArray arrayWithArray:[[FFVideoManager sharedInstance] createGPUFilterArr]];
    }
    return _filterArr;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initFilter];
    }
    return self;
}
- (instancetype)init{
    self = [super init];
    if (self)
    {
        [self initFilter];
    }
    return self;
}

#pragma mark - arguments
#pragma mark - initFilter
- (void)initFilter{
    self.pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie4.m4v"];
    self.movieURL = [NSURL fileURLWithPath:self.pathToMovie];
    unlink([self.pathToMovie UTF8String]); // 如果已经存在文件，AVAssetWriter会有异常，删除旧文件
    
    self.bgView = ({
        UIView *view = [[UIView alloc]init];
        [self addSubview:view];
        view.backgroundColor = [UIColor whiteColor];
        view;
    });
    
    self.videoCamera = [[GPUImageStillCamera alloc]initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionBack];
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    self.videoCamera.delegate = self;
    [self.videoCamera addAudioInputsAndOutputs]; //该句可防止允许声音通过的情况下，避免录制第一帧黑屏闪屏
    
    

    
//    AVCaptureMetadataOutput *metaDataOutput = self.videoCamera.captureSession.outputs[0];
//    dispatch_queue_t videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
////    [metadDataOutput setMetadataObjectsDelegate:self queue:videoDataOutputQueue];
//    NSArray* supportTypes = metaDataOutput.availableMetadataObjectTypes;
//    //NSLog(@"supports:%@",supportTypes);
//    if ([supportTypes containsObject:AVMetadataObjectTypeFace]) {
//        [metaDataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeFace]];
//        [metaDataOutput setMetadataObjectsDelegate:self queue:videoDataOutputQueue];
//
//    }
    
    
    self.filterView = [[GPUImageView alloc]initWithFrame:self.bounds];
    self.filterView.center = self.center;
    [self.bgView addSubview:self.filterView];
    
    [self.videoCamera removeAllTargets];
    
    AVCaptureDevice *device = self.videoCamera.inputCamera;
    NSError *error;
    if ([device lockForConfiguration:&error])
    {
        [device setSubjectAreaChangeMonitoringEnabled:YES];
        [device unlockForConfiguration];
    }
    if (device.isSubjectAreaChangeMonitoringEnabled) {
        //自动对焦
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(subjectAreaDidChange:)name:AVCaptureDeviceSubjectAreaDidChangeNotification object:device];
    }
    
    {
//        AVCaptureMetadataOutput *metaDataOutput = self.videoCamera.captureSession.outputs[0];
        
//        [metaDataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
//        self.videoCamera.captureSession.output
       
    
    }
//    resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"dotc" ofType:@"bundle"]];

    
    FFVideoFilterModel *filterModel = (FFVideoFilterModel*)self.filterArr[0];
    GPUImageOutput<GPUImageInput> *pixellaterFiler =  filterModel.filter;
    self.currentFilter = pixellaterFiler;
    self.currentWaterMark = nil;
    
    [self makeFilterWithFilter:pixellaterFiler waterMark:self.currentWaterMark];

    [self initFaceView];

    

//    [self setupFaceuDic];
    
//    [[FFVideoManager sharedInstance]createTimerActionTypeBlock:^{
//        [self detectorAction];
//    }];
}

- (void)setupFaceuDic{
    // 添加faceu图标
    NSString *faceuConfigurePath = [[NSBundle mainBundle] pathForResource:@"FaceuConfigure" ofType:@"plist"];
    NSArray *faceus = [[NSArray alloc] initWithContentsOfFile:faceuConfigurePath];
    NSInteger faceuKindNumber = faceus.count;

    for (int i = 0; i < faceuKindNumber; ++i) {
        NSDictionary *faceuInfo = faceus[i];
        if (faceuInfo) {
            FFLOG(@"faceuInfo %@",faceuInfo);
        }
    }
    
    
    NSDictionary*faceuDic = [NSDictionary dictionaryWithDictionary:faceus[3]];
    
    NSString *const kFaceUInfoEffectPath        = @"faceu_effect";
    NSString *const kFaceUInfoEffectID          = @"faceu_id";

    
    //    FFLOG(@"")
    //    [self setFilter:faceuDic[kFaceUInfoEffectPath]];
    //    [self reloadFilter];
    
}
#pragma mark - notification
- (void)subjectAreaDidChange:(NSNotification *)notification
{
    FFLOG(@"subjectAreaDidChange ");
    AVCaptureDevice *device = self.videoCamera.inputCamera;
    //先进行判断是否支持控制对焦
    if (device.isFocusPointOfInterestSupported &&[device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        FFLOG(@"supporeted ");
        NSError *error =nil;
        //对cameraDevice进行操作前，需要先锁定，防止其他线程访问，
        [device lockForConfiguration:&error];
        [device setFocusMode:AVCaptureFocusModeAutoFocus];
        
        [self focusWithPoint:self.center];
        //操作完成后，记得进行unlock。
        [device unlockForConfiguration];
    }
}
#pragma mark --
- (void)focusWithPoint:(CGPoint)point{
    CGSize size = self.bounds.size;
    CGPoint focusPoint = CGPointMake( point.y /size.height ,1-point.x/size.width );
    
    NSError *error;
    AVCaptureDevice *myDevice = self.videoCamera.inputCamera;
    if ([myDevice lockForConfiguration:&error]) {
        //对焦模式和对焦点
        if ([myDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [myDevice setFocusPointOfInterest:focusPoint];
            [myDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        //曝光模式和曝光点
        if ([myDevice isExposureModeSupported:AVCaptureExposureModeAutoExpose ]) {
            [myDevice setExposurePointOfInterest:focusPoint];
            [myDevice setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        [myDevice unlockForConfiguration];
    }
}

- (void)takePhoto{
    //定格一张图片 保存到相册 GPUImageStillCamera
    GPUImageOutput<GPUImageInput>*output = nil;
    if (currentBlendFilter) {
        output = currentBlendFilter;
    }else if(self.currentFilter){
        output = self.currentFilter;
    }
    [self.videoCamera capturePhotoAsPNGProcessedUpToFilter:output withCompletionHandler:^(NSData *processedPNG, NSError *error) {
        UIImage *image = [UIImage imageWithData:processedPNG];
        if (self.videoPreviewDelegate && [self.videoPreviewDelegate respondsToSelector:@selector(takePhotoSuccess:)]) {
            [self.videoPreviewDelegate takePhotoSuccess:image];
        }
        FFLOG(@"写入图片到相册");
        
    }];
    
}
- (void)switchCamera{
    [self.videoCamera rotateCamera];
}
-(void)flashLightAction{
    if (self.videoCamera.inputCamera.position == AVCaptureDevicePositionBack) {
        if (self.videoCamera.inputCamera.torchMode == AVCaptureTorchModeOn) {
            [self.videoCamera.inputCamera lockForConfiguration:nil];
            [self.videoCamera.inputCamera setTorchMode:AVCaptureTorchModeOff];
            [self.videoCamera.inputCamera unlockForConfiguration];
        }else{
            [self.videoCamera.inputCamera lockForConfiguration:nil];
            [self.videoCamera.inputCamera setTorchMode:AVCaptureTorchModeOn];
            [self.videoCamera.inputCamera unlockForConfiguration];
        }
    }else{
        FFLOG(@"当前使用前置摄像头,未能开启闪光灯");
    }
}
#pragma mark -
- (void)startRecordVideo{
    FFLOG(@"startRecordVideo");
    
    [self.videoCamera removeTarget:self.movieWriter];
    [self.movieWriter finishRecording];
    self.movieWriter = nil;
    [[NSFileManager defaultManager]removeItemAtURL:self.movieURL error:nil];
    
    self.videoCamera.audioEncodingTarget = self.movieWriter;
    if (currentBlendFilter) {
        [currentBlendFilter addTarget:self.movieWriter];
    }else{
        if (self.currentFilter) {
            [self.currentFilter addTarget:self.movieWriter];
        }
    }
    
    [self.movieWriter startRecording];
}

- (void)endRecordVideo{
    FFLOG(@"endRecordVideo");
    self.videoCamera.audioEncodingTarget = nil;
    if (currentBlendFilter) {
        [currentBlendFilter removeTarget:self.movieWriter];
    }else{
        if (self.currentFilter) {
            [self.currentFilter removeTarget:self.movieWriter];
        }
    }
    [self.movieWriter finishRecording];
    self.movieWriter = nil;
    
}

#pragma mark -
- (void)makeFilterWithFilter:(GPUImageOutput<GPUImageInput>*)filter waterMark:(FFVideoWaterMarkModel*)waterMark{
    [self.videoCamera removeAllTargets];
    
    if (self.currentFilter) {
        [self.currentFilter removeAllTargets];
        self.currentFilter = nil;
    }
    self.currentFilter = filter;
    self.currentWaterMark = waterMark;
    currentBlendFilter = nil;
    if (filter && waterMark) {
        self.currentWaterMark = waterMark;
        [self.videoCamera addTarget:filter];
        FFLOG(@"waterMark filter");
        [self configeWaterMarkWithFilter:filter];
        
    }else{
        if (filter) {
            FFLOG(@" filter");
            currentBlendFilter = nil;
            [self.videoCamera addTarget:filter];
            [filter addTarget:self.filterView];
            [filter useNextFrameForImageCapture];//解决崩溃  CVPixelBufferCreate error.
        }
        if (waterMark) {
            FFLOG(@"waterMark");
            self.currentWaterMark = waterMark;
            FFVideoFilterModel *filterModel = (FFVideoFilterModel*)self.filterArr[0];
            GPUImageOutput<GPUImageInput> *pixellaterFiler =  filterModel.filter;
            self.currentFilter = pixellaterFiler;
            [self configeWaterMarkWithFilter:pixellaterFiler];
        }
    }
    
    [self.videoCamera startCameraCapture];
}

- (void)configeWaterMarkWithFilter:(GPUImageOutput<GPUImageInput>*)filter{
    
    GPUImageAlphaBlendFilter *blendFilter = [[GPUImageAlphaBlendFilter alloc] init];
    ////blendFilter.mix = 1.0;//调透明度
    [filter addTarget:blendFilter];
    
    UIView *waterView = [[FFVideoManager sharedInstance] waterViewWithModel:self.currentWaterMark];
    GPUImageUIElement *uiElementInput = [[GPUImageUIElement alloc] initWithView:waterView];
    
    [uiElementInput addTarget:blendFilter];
    [blendFilter addTarget:self.filterView];
    
    currentBlendFilter = blendFilter;
    [filter useNextFrameForImageCapture];
    [uiElementInput useNextFrameForImageCapture];//解决崩溃
    
    //        __weak typeof (UILabel) *weaktimeLabel = timeLabel;
    dispatch_async(dispatch_get_main_queue(), ^{
        [filter setFrameProcessingCompletionBlock:^(GPUImageOutput * filter, CMTime frameTime){
            // [uiElementInput updateWithTimestamp:frameTime];//会崩溃
            [uiElementInput update];
        }];
        
    });
    
}

- (void)detectorAction{
//    FFLOG(@"willOutputSampleBuffer");
//    CFRetain(currentSampleBuffer);
    UIImage *image = [[FFVideoManager sharedInstance]fixOrientationFromSampleBuffer:currentSampleBuffer];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//
//        dispatch_async(dispatch_get_main_queue(), ^{
            if (!image) {
                return ;
            }
            [self beginDetectorFacewithImage:image];
//        });
////        CFRelease(currentSampleBuffer);
//    });
}
#pragma mark - GPUImageVideoCameraDelegate
- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    if (sampleBuffer) {
        currentSampleBuffer = sampleBuffer;
        [self detectorAction];
    }
}
#pragma mark -
#pragma mark - Public Method
- (void)setFilter:(NSString *)effect {
    if (effect == nil || [effect isEqualToString:@""]) {
        return;
    }
//    effectPos = [self.renderEngine applyWithPath:[resBundle pathForResource:effect ofType:@""]];
//    FFLOG(@"pos is %d", effectPos);
}




#pragma mark -
- (void)beginDetectorFacewithImage:(UIImage *)image
{
    NSArray*features = [[FFVideoManager sharedInstance]detectFaceMarkWithImage:image];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (features.count > 0) {
            self.mouth.hidden = NO;
            self.leftEye.hidden = NO;
            self.rightEye.hidden = NO;
            self.faceView.hidden = NO;
        }else{
            self.mouth.hidden = YES;
            self.leftEye.hidden = YES;
            self.rightEye.hidden = YES;
            self.faceView.hidden = YES;
        }
        //5.分析人脸识别数据
        for (CIFaceFeature *faceFeature in features){
            //注意坐标的换算，CIFaceFeature计算出来的坐标的坐标系的Y轴与iOS的Y轴是相反的,需要自行处理
            FFLOG(@"faceFeature %@",faceFeature);
            CGFloat faceWidth = faceFeature.bounds.size.width;
            if (self.faceView) {
                self.faceView.frame = faceFeature.bounds;
                self.faceView.frame = CGRectMake(self.faceView.frame.origin.x, kScreenHeight-self.faceView.frame.origin.y - self.faceView.bounds.size.height, self.faceView.frame.size.width, self.faceView.frame.size.height);

                
            }
            
            // 标出左眼
            if(faceFeature.hasLeftEyePosition) {
                self.leftEye.frame = CGRectMake(faceFeature.leftEyePosition.x-faceWidth*0.15,
                                                self.bounds.size.height-(faceFeature.leftEyePosition.y-faceWidth*0.15)-faceWidth*0.3, faceWidth*0.3, faceWidth*0.3);
                
            }
            // 标出右眼
            if(faceFeature.hasRightEyePosition) {
                self.rightEye.frame = CGRectMake(faceFeature.rightEyePosition.x-faceWidth*0.15,
                                                 self.bounds.size.height-(faceFeature.rightEyePosition.y-faceWidth*0.15)-faceWidth*0.3, faceWidth*0.3, faceWidth*0.3);
                
            }
            // 标出嘴部
            if(faceFeature.hasMouthPosition) {
                self.mouth.frame = CGRectMake(faceFeature.mouthPosition.x-faceWidth*0.2,
                                              self.bounds.size.height-(faceFeature.mouthPosition.y-faceWidth*0.2)-faceWidth*0.4, faceWidth*0.4, faceWidth*0.2);
                
                
            }
            
        }
        
    });
}
- (void)initFaceView{
    NSArray *nameArr = @[@"",@"eyePatch_left",@"eyePatch_right",@"moustache",];
    for (NSInteger i = 0 ; i < 4; i ++) {
        UIImageView *faceView  =  ({
            UIImageView *image = [[UIImageView alloc]init];
            [self.bgView addSubview:image];
            image.layer.borderWidth = 1;
            image.layer.borderColor = [[UIColor redColor] CGColor];
            image.image = [UIImage imageNamed:nameArr[i]];
            image;
        });
        
        if (i == 0) {
            self.faceView = faceView;
        }else if (i == 1){
            self.leftEye = faceView;
        }else if (i == 2){
            self.rightEye = faceView;
        }else if (i == 3){
            self.mouth = faceView;
        }
    }
   
}

@end
