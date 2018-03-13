    //
    //  FFVideoManager.m
    //  GPUImageProject
    //
    //  Created by avazuholding on 2017/9/25.
    //  Copyright © 2017年 bert. All rights reserved.
    //

#import "FFVideoManager.h"
#import "GPUImageBeautifyFilter.h"
#import "FFVideoFilterModel.h"
#import "FFVideoWaterMarkModel.h"
#import "FFWaterView.h"
#import <UIKit/UIKit.h>
@interface FFVideoManager ()

//@property (nonatomic, strong) GPUImageStillCamera *videoCamera;
//
{
    dispatch_source_t _timer;
    dispatch_queue_t _queue;
}
@end
@implementation FFVideoManager

+(FFVideoManager *)sharedInstance
{
    static FFVideoManager *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[FFVideoManager alloc] init];
       
    });
    return _sharedInstance;
}

-(instancetype)init{
    self = [super init];
    if (self)
    {
//        self.videoCamera = [[GPUImageStillCamera alloc]initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionBack];
//        self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
//        self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
//        self.videoCamera.delegate = self;
//        [self.videoCamera addAudioInputsAndOutputs]; //该句可防止允许声音通过的情况下，避免录制第一帧黑屏闪屏
//        
    }
    return self;
}
#pragma mark -
- (NSArray*)createGPUFilterArr{
    NSMutableArray *filterArr = [NSMutableArray array];
    NSString *filterKey = kFilterKey;
    NSString *nameKey = kFilterNameKey;
    GPUImageFilter *filter = [[GPUImageFilter alloc]init];
    NSDictionary *nullFilterDic = [NSDictionary dictionaryWithObjectsAndKeys:filter,filterKey,@"无滤镜",nameKey, nil];
    [filterArr addObject:nullFilterDic];
    
    
    GPUImageBeautifyFilter *beautifyFilter = [[GPUImageBeautifyFilter alloc]init];
    NSDictionary *filterDic = [NSDictionary dictionaryWithObjectsAndKeys:beautifyFilter,filterKey,@"美颜",nameKey, nil];
    [filterArr addObject:filterDic];
    
    NSArray *filterNameArr = @[@"伽马线",@"反色",@"褐色怀旧",@"灰度",@"色彩直方图",@"RGB",@"单色",@"模糊",@"漫画反色",@"蓝绿边缘",@"素描",@"卡通",@"监控",@"哈哈镜"];
    for (NSInteger i = 0 ; i < filterNameArr.count; i ++) {
        NSDictionary *filterDic = nil;
        GPUImageOutput<GPUImageInput> * output = nil;
        switch (i) {
            case 0:
            {
            output = [[GPUImageGammaFilter alloc] init];
            [(GPUImageGammaFilter*)output setGamma:1.5];
            break;
            }
            case 1:
            {
            output = [[GPUImageColorInvertFilter alloc]init];
            
            break;
            }
            case 2:
            {
            output = [[GPUImageSepiaFilter alloc]init];
            
            break;
            }
            case 3:
            {
            output = [[GPUImageGrayscaleFilter alloc]init];
            break;
            }
            case 4:
            {
            output = [[GPUImageHistogramGenerator alloc]init];
            break;
            }
            case 5:
            {
            GPUImageRGBFilter *outputRGB = [[GPUImageRGBFilter alloc]init];
            [outputRGB setRed:0.8];
            [outputRGB setGreen:0.3];
            [outputRGB setBlue:0.5];
            
            output = outputRGB;
            break;
            }
            case 6:
            {
            output = [[GPUImageMonochromeFilter alloc]init];
            [(GPUImageMonochromeFilter*)output setColorRed:0.3 green:0.5 blue:0.8];
            break;
            }
            case 7:
            {
            output = [GPUImageBoxBlurFilter new];
            break;
            }
            case 8:
            {
            output = [GPUImageSobelEdgeDetectionFilter new];
            break;
            }
            case 9:
            {
            output = [GPUImageXYDerivativeFilter new];
            break;
            }
            case 10:
            {
            output = [GPUImageSketchFilter new];
            break;
            }
            case 11:
            {
            output = [GPUImageSmoothToonFilter new];
            break;
            }
            case 12:
            {
            output = [GPUImageColorPackingFilter new];
            break;
            }
            case 13:
            {
            output = [[GPUImageStretchDistortionFilter alloc] init];
            
            break;
            }
                
            default:
                break;
        }
        
        filterDic = [NSDictionary dictionaryWithObjectsAndKeys:output,filterKey,filterNameArr[i],nameKey, nil];
        [filterArr addObject:filterDic];
    }
    
    NSMutableArray *resultArr = [NSMutableArray array];
    for (NSDictionary *dic in filterArr) {
        FFVideoFilterModel *model = [[FFVideoFilterModel alloc]init];
        model.filter = dic[kFilterKey];
        model.filterName = dic[kFilterNameKey];
        [resultArr addObject:model];
    }
   
    
    return resultArr;
    
}

- (NSArray*)createWaterMark{
    
    NSMutableArray *waterMarkArr = [NSMutableArray array];
    
    NSArray *nameArr = @[@"无",@"漫威黑寡妇",@"钢铁侠01",@"钢铁侠02",@"绿巨人",@"蜘蛛侠01",@"蜘蛛侠02",@"蝙蝠侠01",@"蝙蝠侠02",@"变形金刚01"];
    NSArray *imageNameArr = @[@"no_filter",@"blac_watermark",@"ironman_watermark_01",@"ironman_watermark_02",@"greengiant_watermark_01",@"spiderman_watermark_01",@"spiderman_watermark_02",@"batman_watermark_01",@"batman_watermark_02",@"transformers_watermark_01"];
    
    for (NSInteger i = 0 ; i < nameArr.count; i ++) {
        NSDictionary *waterMarkDic = [NSDictionary dictionaryWithObjectsAndKeys:imageNameArr[i],kWaterMarkKey,nameArr[i],kWaterMarkNameKey, nil];
        
        [waterMarkArr addObject:waterMarkDic];
    }
    
    NSMutableArray *resultArr = [NSMutableArray array];
    for (NSDictionary *dic in waterMarkArr) {
        FFVideoWaterMarkModel *model = [[FFVideoWaterMarkModel alloc]init];
        model.waterMark = dic[kWaterMarkKey];
        model.waterMarkName = dic[kWaterMarkNameKey];
        [resultArr addObject:model];
    }
    return resultArr;
    
}


- (UIView*)waterViewWithModel:(FFVideoWaterMarkModel*)waterMarkModel{
//    if (self.waterView==nil) {
    FFWaterView* waterView = [[FFWaterView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    //    }
    [waterView setupWaterMarkWithModel:waterMarkModel];
    UIView *view = waterView;
    return view;
}
#pragma mark - 人脸识别
/**
 *  用来处理图片翻转90度
 */
- (UIImage *)fixOrientationFromSampleBuffer:(CMSampleBufferRef)sampleBuffer{
   UIImage* aImage = [self imageFromSampleBuffer:sampleBuffer];
    
//    return aImage;
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

- (UIImage*)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    
//    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
//    if (!imageBuffer) {
//        return nil;
//    }
//    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
//    CIContext *temporaryContent = [CIContext contextWithOptions:nil];
//    CGImageRef videoImage = [temporaryContent createCGImage:ciImage fromRect:CGRectMake(0, 0, CVPixelBufferGetWidth(imageBuffer), CVPixelBufferGetHeight(imageBuffer))];
//    UIImage *result = [[UIImage alloc]initWithCGImage:videoImage scale:1.0 orientation:UIImageOrientationLeftMirrored];
//    CGImageRelease(videoImage);
//    return result;
    
    
    
   
    {
       CVImageBufferRef buffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        
        CVPixelBufferLockBaseAddress(buffer, 0);
//        uint8_t *base;
        void *base;
        size_t width, height, bytesPerRow;
        base = CVPixelBufferGetBaseAddress(buffer);
        width = CVPixelBufferGetWidth(buffer);
        height = CVPixelBufferGetHeight(buffer);
        bytesPerRow = CVPixelBufferGetBytesPerRow(buffer);
        
        //利用取得影像细部信息格式化 CGContextRef
        CGColorSpaceRef colorSpace;
        CGContextRef cgContext;
        colorSpace = CGColorSpaceCreateDeviceRGB();
        cgContext = CGBitmapContextCreate(base, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
        CGColorSpaceRelease(colorSpace);
        
        //透过 CGImageRef 将 CGContextRef 转换成 UIImage
        CGImageRef cgImage;
        UIImage *image;
        cgImage = CGBitmapContextCreateImage(cgContext);
     // 解锁pixel buffer
     CVPixelBufferUnlockBaseAddress(buffer,0);
     
        image = [UIImage imageWithCGImage:cgImage];
        CGImageRelease(cgImage);
        CGContextRelease(cgContext);
        
        return image;
//        作者：蚾蚾虾
//        链接：http://www.jianshu.com/p/3ed2507cd026
//        來源：简书
//        著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
    }

}

/*
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer {
    // 为媒体数据设置一个CMSampleBuffer的Core Video图像缓存对象
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // 锁定pixel buffer的基地址
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // 得到pixel buffer的基地址
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // 得到pixel buffer的行字节数
//    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    
    // 得到pixel buffer的宽和高
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    size_t bytesPerRow = width*4;
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * height);
    
    // 创建一个依赖于设备的RGB颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // 用抽样缓存的数据创建一个位图格式的图形上下文（graphics context）对象
//    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
//                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, width, height, 8,
                                                 bytesPerRow, colorSpace,  kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // 根据这个位图context中的像素数据创建一个Quartz image对象
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // 解锁pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // 释放context和颜色空间
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // 用Quartz image创建一个UIImage对象image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    // 释放Quartz image对象
    CGImageRelease(quartzImage);
    
    return (image);
}
*/
//作者：brownfeng
//链接：http://www.jianshu.com/p/3692475412c8
//來源：简书
//著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

#pragma mark - 人脸检测
- (NSArray*)faceRecognitionWithImage:(UIImage*)image{
    if (![self hasFace:image]) {
        return nil;
    }
    NSArray *feature = [self detectFaceWithImage:image];
    NSMutableArray *arrM = [NSMutableArray arrayWithCapacity:feature.count];
    for (CIFaceFeature *face in feature) {
        [arrM addObject:[NSValue valueWithCGRect:face.bounds]];
    }
    return arrM;
}

- (BOOL)hasFace:(UIImage*)image{
    NSArray *features = [self detectFaceWithImage:image];
    
    return features.count? YES:NO;
}

- (NSArray*)detectFaceWithImage:(UIImage*)faceImage{

    CIDetector *faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyLow}];
    CIImage *ciImage = [CIImage imageWithCGImage:faceImage.CGImage];
    NSArray *features = [faceDetector featuresInImage:ciImage];
    return features;
}

- (NSArray*)detectFaceMarkWithImage:(UIImage*)image{
    //1 将UIImage转换成CIImage
    CIImage* ciimage = [CIImage imageWithCGImage:image.CGImage];
    //    缩小图片，默认照片的图片像素很高，需要将图片的大小缩小为我们现实的ImageView的大小，否则会出现识别五官过大的情况
    //    float factor = self.imageView.bounds.size.width/image.size.width;
    float factor = kScreenWidth/image.size.width;
    ciimage = [ciimage imageByApplyingTransform:CGAffineTransformMakeScale(factor, factor)];
    
    //    2.设置人脸识别精度
    NSDictionary* opts = [NSDictionary dictionaryWithObject:
                          CIDetectorAccuracyLow forKey:CIDetectorAccuracy];
    //3.创建人脸探测器
    CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:nil options:opts];
    
    //4.获取人脸识别数据
    NSArray* features = [detector featuresInImage:ciimage];
    return features;
}
#pragma mark - 人脸识别对坐标的处理
- (CGRect)getUIImageViewRectFromCIImageRect:(CGRect)originAllRect
{
    CGRect getRect = originAllRect;
    float scrSalImageW = kPressetWidth/kScreenWidth;
    float scrSalImageH = kPressetHeight/kScreenHeight;
    getRect.size.width = originAllRect.size.width/scrSalImageW;
    getRect.size.height = originAllRect.size.height/scrSalImageH;

    float hx = kScreenWidth/kPressetWidth;
    float hy = kScreenHeight/kPressetHeight;

    getRect.origin.x = originAllRect.origin.x*hx;//*hx
    getRect.origin.y = (kScreenHeight - originAllRect.origin.y*hy) - getRect.size.height;
    return getRect;
}


- (void)timerInvalidate{
    if (_timer != nil) {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}
- (void)createTimerActionTypeBlock:(TimerActionTypeBlock)timerActionTypeBlock {
    _queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //倒计时时间1
//    __block NSInteger timeOut = 4;
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _queue);
    //每秒执行一次
    //    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 1 * NSEC_PER_SEC, 1 * NSEC_PER_SEC);
    
    dispatch_source_set_timer(_timer, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),  (1 * NSEC_PER_SEC), 0);
    @weakify(self);
    dispatch_source_set_event_handler(_timer, ^{
        @strongify(self);
        timerActionTypeBlock();
//        if (timeOut <= 0) {
//            dispatch_source_cancel(self->_timer);
//            FFLOG(@"<= %ld",timeOut);
////            self.processAwaitActionTypeBlock();
//        } else {
//            FFLOG(@"-- %ld",timeOut);
//            dispatch_async(dispatch_get_main_queue(), ^{
//
//                timeOut--;
//            });
//
//        }
    });
    dispatch_resume(_timer);
}























@end
