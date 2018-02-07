//
//  GPUFacekitOutput.m
//  SwiftLive
//
//  Created by v.q on 2016/11/10.
//  Copyright © 2016年 DotC_United. All rights reserved.
//

#import "GPUFacekitOutput.h"

@interface GPUFacekitOutput () {
    GPUImageRotationMode _outputRotation;
    GPUImageRotationMode _internalRotation;
    dispatch_semaphore_t _frameRenderingSemaphore;
    
    GPUImageFramebuffer *_previousBuffer;
    GLProgram           *yuvConvert;
    const GLfloat       *_preferredConversion;
    GLuint  luminanceTexture;
    GLuint  chrominanceTexture;
    GLint   yuvConversionPositionAttribute;
    GLint   yuvConversionTextureCoordinateAttribute;
    GLint   yuvConversionLuminanceTextureUniform;
    GLint   yuvConversionChrominanceTextureUniform;
    GLint   yuvConversionMatrixUniform;
    GLsizei imageBufferWid;
    GLsizei imageBufferHei;
}
@property (nonatomic, strong) LMRenderEngine *renderEngine;
@end

@implementation GPUFacekitOutput

- (id)initWithRenderEngine:(LMRenderEngine*)renderEngine {
    if (self = [super init]) {
        _renderEngine = renderEngine;
        _cameraPosition = AVCaptureDevicePositionFront;
        _outputRotation = kGPUImageNoRotation;
        _internalRotation = kGPUImageNoRotation;
        _frameRenderingSemaphore = dispatch_semaphore_create(1);
        
        /// 读取相应的GPUImage中YUV转换的program的各个参数的location，
        /// 因为在shader在GPUImageVideoCamera中已经初始化连接过了，直接读取就可以
        runSynchronouslyOnVideoProcessingQueue(^{
            [GPUImageContext useImageProcessingContext];
            
            yuvConvert =
            [[GPUImageContext sharedImageProcessingContext]
             programForVertexShaderString:kGPUImageVertexShaderString
             fragmentShaderString:kGPUImageYUVFullRangeConversionForLAFragmentShaderString];
            
            if (!yuvConvert.initialized) {
                [yuvConvert addAttribute:@"position"];
                [yuvConvert addAttribute:@"inputTextureCoordinate"];
                if (![yuvConvert link]) {
                    NSString *progLog = [yuvConvert programLog];
                    FFLOG(@"Program link log: %@", progLog);
                    NSString *fragLog = [yuvConvert fragmentShaderLog];
                    FFLOG(@"Fragment shader compile log: %@", fragLog);
                    NSString *vertLog = [yuvConvert vertexShaderLog];
                    FFLOG(@"Vertex shader compile log: %@", vertLog);
                    yuvConvert = nil;
                    NSAssert(NO, @"Filter shader link failed");
                }
            }
            
            yuvConversionPositionAttribute =
            [yuvConvert attributeIndex:@"position"];
            
            yuvConversionTextureCoordinateAttribute =
            [yuvConvert attributeIndex:@"inputTextureCoordinate"];
            
            yuvConversionLuminanceTextureUniform =
            [yuvConvert uniformIndex:@"luminanceTexture"];
            
            yuvConversionChrominanceTextureUniform =
            [yuvConvert uniformIndex:@"chrominanceTexture"];
            
            yuvConversionMatrixUniform =
            [yuvConvert uniformIndex:@"colorConversionMatrix"];
            
            [GPUImageContext setActiveShaderProgram:yuvConvert];
            
            glEnableVertexAttribArray(yuvConversionPositionAttribute);
            glEnableVertexAttribArray(yuvConversionTextureCoordinateAttribute);
        });
    }
    return self;
}

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    if (dispatch_semaphore_wait(_frameRenderingSemaphore, DISPATCH_TIME_NOW) != 0)
    {
        return;
    }
    CFRetain(sampleBuffer);
    runAsynchronouslyOnVideoProcessingQueue(^{
        CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        GLsizei width = (GLsizei)CVPixelBufferGetWidth(pixelBuffer);
        GLsizei height = (GLsizei)CVPixelBufferGetHeight(pixelBuffer);
        CFTypeRef colorAttachments = CVBufferGetAttachment(pixelBuffer, kCVImageBufferYCbCrMatrixKey, NULL);
        OSType formatType = CVPixelBufferGetPixelFormatType(pixelBuffer);
        CMTime currentTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        
        CVPixelBufferLockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);

        if (formatType == kCVPixelFormatType_32BGRA) {
            CVOpenGLESTextureRef videoTextureRef = NULL;
            GLuint _videoTexture;
            
            CVReturn err;
            err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, [[GPUImageContext sharedImageProcessingContext] coreVideoTextureCache], pixelBuffer, NULL, GL_TEXTURE_2D, GL_RGBA, (int)width, (int)height, GL_BGRA, GL_UNSIGNED_BYTE, 0, &videoTextureRef);
            if (err != noErr) {
                FFLOG(@"GPUFacekitOutput Create 32BGRA Texture Failed");
                return ;
            }
            _videoTexture = CVOpenGLESTextureGetName(videoTextureRef);
            glBindTexture(GL_TEXTURE_2D, _videoTexture);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            
            GLuint tex;
            [_renderEngine processTexture:_videoTexture size:CGSizeMake(width,height) outputTexture:&tex];
            
            [self updateTargetsForVideoCameraUsingCacheTextureAtWidth:width height:height time:currentTime];
            
            if (videoTextureRef) {
                CFRelease(videoTextureRef);
            }
        }
        else {
            if (colorAttachments != NULL) {
                if (CFStringCompare(colorAttachments, kCVImageBufferYCbCrMatrix_ITU_R_601_4, 0) == kCFCompareEqualTo) {
                    if (formatType == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) { // FullYUVRange
                        _preferredConversion = kColorConversion601FullRange;
                    } else {
                        _preferredConversion = kColorConversion601;
                    }
                } else {
                    _preferredConversion = kColorConversion709; // HDTV
                }
            } else {
                if (formatType == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) { // FullYUVRange
                    _preferredConversion = kColorConversion601FullRange;
                } else {
                    _preferredConversion = kColorConversion601;
                }
            }
            
            [GPUImageContext useImageProcessingContext];
            
            CVOpenGLESTextureRef luminanceTextureRef = NULL;
            CVOpenGLESTextureRef chrominanceTextureRef = NULL;
            
            if (CVPixelBufferGetPlaneCount(pixelBuffer) > 0) { // Check for YUV Planar inputs to do RGB conversion
                if ((imageBufferWid != width) && (imageBufferHei != height)) {
                    imageBufferWid = width;
                    imageBufferHei = height;
                }
                
                CVReturn err;
                glActiveTexture(GL_TEXTURE4); // Y-Plane
                err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, [[GPUImageContext sharedImageProcessingContext] coreVideoTextureCache], pixelBuffer, NULL, GL_TEXTURE_2D, GL_LUMINANCE, width, height, GL_LUMINANCE, GL_UNSIGNED_BYTE, 0, &luminanceTextureRef);
                if (err) {
                    FFLOG(@"Error at luminanceTexture CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
                }
                
                luminanceTexture = CVOpenGLESTextureGetName(luminanceTextureRef);
                glBindTexture(GL_TEXTURE_2D, luminanceTexture);
                glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
                glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
                
                glActiveTexture(GL_TEXTURE5);
                err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, [[GPUImageContext sharedImageProcessingContext] coreVideoTextureCache], pixelBuffer, NULL, GL_TEXTURE_2D, GL_LUMINANCE_ALPHA, width/2, height/2, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, 1, &chrominanceTextureRef);
                if (err) {
                    FFLOG(@"Error at chrominanceTexture CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
                }
                
                chrominanceTexture = CVOpenGLESTextureGetName(chrominanceTextureRef);
                glBindTexture(GL_TEXTURE_2D, chrominanceTexture);
                glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
                glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
                
                [self convertYUVtoRGBOutput];
                
                GLsizei rotatedWidth = width, rotatedHeight = height;
                if (GPUImageRotationSwapsWidthAndHeight(_internalRotation)) {
                    rotatedWidth = height;
                    rotatedHeight = width;
                }
                
                GLuint tex;
                [_renderEngine processTexture:_previousBuffer.texture size:CGSizeMake(rotatedWidth,rotatedHeight) outputTexture:&tex];
                
                outputFramebuffer = [[GPUImageFramebuffer alloc] initWithSize:CGSizeMake(rotatedWidth,rotatedHeight) overriddenTexture:tex];
//                outputFramebuffer.preventReleaseTexture = YES;
                
                [self updateTargetsForVideoCameraUsingCacheTextureAtWidth:rotatedWidth height:rotatedHeight time:currentTime];
                
                [_previousBuffer unlock];
                _previousBuffer = nil;
                if (luminanceTextureRef) {
                    CFRelease(luminanceTextureRef);
                }
                if (chrominanceTextureRef) {
                    CFRelease(chrominanceTextureRef);
                }
            }
        }
        CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
        
        CFRelease(sampleBuffer);
        dispatch_semaphore_signal(_frameRenderingSemaphore);
    });
    
}

- (void)updateTargetsForVideoCameraUsingCacheTextureAtWidth:(GLsizei)bufferWidth height:(GLsizei)bufferHeight time:(CMTime)currentTime {
    for (id<GPUImageInput> currentTarget in targets) {
        NSInteger indexOfObject = [targets indexOfObject:currentTarget];
        NSInteger textureIndexOfTarget = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
        
        [currentTarget setInputRotation:_outputRotation atIndex:textureIndexOfTarget];
        [currentTarget setInputSize:CGSizeMake(bufferWidth, bufferHeight) atIndex:textureIndexOfTarget];
        
        [currentTarget setCurrentlyReceivingMonochromeInput:NO];
        [currentTarget setInputFramebuffer:outputFramebuffer atIndex:textureIndexOfTarget];
    }
    
    outputFramebuffer = nil;
    
    // Finally, trigger rendering as needed
    for (id<GPUImageInput> currentTarget in targets)
    {
        if ([currentTarget enabled])
        {
            NSInteger indexOfObject = [targets indexOfObject:currentTarget];
            NSInteger textureIndexOfTarget = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
            
            if (currentTarget != self.targetToIgnoreForUpdates)
            {
                [currentTarget newFrameReadyAtTime:currentTime atIndex:textureIndexOfTarget];
            }
        }
    }
}

- (void)convertYUVtoRGBOutput {
    [GPUImageContext setActiveShaderProgram:yuvConvert];
    
    GLsizei rotatedImageBufferWidth = imageBufferWid;
    GLsizei rotatedImageBufferHeight = imageBufferHei;
    if (GPUImageRotationSwapsWidthAndHeight(_internalRotation)) {
        rotatedImageBufferWidth = imageBufferHei;
        rotatedImageBufferHeight = imageBufferWid;
    }
    
    // 这一步，创建新的framebuffer，并绘制到纹理。这个纹理将会供faceu的sdk使用，做进一步的操作，其实也是绘制到纹理。
    // 使用这种方法创建的framebuffer需要unlock之后再置为nil
    _previousBuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:CGSizeMake(rotatedImageBufferWidth, rotatedImageBufferHeight) textureOptions:self.outputTextureOptions onlyTexture:NO];
    [_previousBuffer activateFramebuffer];
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    static const GLfloat squareVertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };
    
    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, luminanceTexture);
    glUniform1i(yuvConversionLuminanceTextureUniform, 4);
    
    glActiveTexture(GL_TEXTURE5);
    glBindTexture(GL_TEXTURE_2D, chrominanceTexture);
    glUniform1i(yuvConversionChrominanceTextureUniform, 5);
    
    glUniformMatrix3fv(yuvConversionMatrixUniform, 1, GL_FALSE, _preferredConversion);
    
    glVertexAttribPointer(yuvConversionPositionAttribute, 2, GL_FLOAT, 0, 0, squareVertices);
    glVertexAttribPointer(yuvConversionTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, [GPUImageFilter textureCoordinatesForRotation:_internalRotation]);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

#pragma mark - 以下部分copy from GPUImage的相关代码
- (void)updateOrientationSendToTargets;
{
    runSynchronouslyOnVideoProcessingQueue(^{
        if (_cameraPosition == AVCaptureDevicePositionBack)
        {
            if (_horizontallyMirrorRearFacingCamera)
            {
                switch(_outputImageOrientation)
                {
                    case UIInterfaceOrientationPortrait:_outputRotation = kGPUImageRotateRightFlipVertical; break;
                    case UIInterfaceOrientationPortraitUpsideDown:_outputRotation = kGPUImageRotate180; break;
                    case UIInterfaceOrientationLandscapeLeft:_outputRotation = kGPUImageFlipHorizonal; break;
                    case UIInterfaceOrientationLandscapeRight:_outputRotation = kGPUImageFlipVertical; break;
                    default:_outputRotation = kGPUImageNoRotation;
                }
            }
            else
            {
                switch(_outputImageOrientation)
                {
                    case UIInterfaceOrientationPortrait:_outputRotation = kGPUImageRotateRight; break;
                    case UIInterfaceOrientationPortraitUpsideDown:_outputRotation = kGPUImageRotateLeft; break;
                    case UIInterfaceOrientationLandscapeLeft:_outputRotation = kGPUImageRotate180; break;
                    case UIInterfaceOrientationLandscapeRight:_outputRotation = kGPUImageNoRotation; break;
                    default:_outputRotation = kGPUImageNoRotation;
                }
            }
        }
        else
        {
            if (_horizontallyMirrorFrontFacingCamera)
            {
                switch(_outputImageOrientation)
                {
                    case UIInterfaceOrientationPortrait:_outputRotation = kGPUImageRotateRightFlipVertical; break;
                    case UIInterfaceOrientationPortraitUpsideDown:_outputRotation = kGPUImageRotateRightFlipHorizontal; break;
                    case UIInterfaceOrientationLandscapeLeft:_outputRotation = kGPUImageFlipHorizonal; break;
                    case UIInterfaceOrientationLandscapeRight:_outputRotation = kGPUImageFlipVertical; break;
                    default:_outputRotation = kGPUImageNoRotation;
                }
            }
            else
            {
                switch(_outputImageOrientation)
                {
                    case UIInterfaceOrientationPortrait:_outputRotation = kGPUImageRotateRight; break;
                    case UIInterfaceOrientationPortraitUpsideDown:_outputRotation = kGPUImageRotateLeft; break;
                    case UIInterfaceOrientationLandscapeLeft:_outputRotation = kGPUImageNoRotation; break;
                    case UIInterfaceOrientationLandscapeRight:_outputRotation = kGPUImageRotate180; break;
                    default:_outputRotation = kGPUImageNoRotation;
                }
            }
        }
    });
}

- (void)setOutputImageOrientation:(UIInterfaceOrientation)newValue {
    _outputImageOrientation = newValue;
    [self updateOrientationSendToTargets];
}

- (void)setHorizontallyMirrorFrontFacingCamera:(BOOL)newValue {
    _horizontallyMirrorFrontFacingCamera = newValue;
    [self updateOrientationSendToTargets];
}

- (void)setHorizontallyMirrorRearFacingCamera:(BOOL)newValue {
    _horizontallyMirrorRearFacingCamera = newValue;
    [self updateOrientationSendToTargets];
}

@end
