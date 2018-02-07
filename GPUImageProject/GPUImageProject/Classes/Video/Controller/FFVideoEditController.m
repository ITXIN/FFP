//
//  FFVideoEditController.m
//  GPUImageProject
//
//  Created by avazuholding on 2017/9/27.
//  Copyright © 2017年 bert. All rights reserved.
//

#import "FFVideoEditController.h"
#import "FFEditVideoView.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
@interface FFVideoEditController ()<FFEditVideoViewDelegate>
{
    GPUImageNormalBlendFilter *filter;
    GPUImageMovieWriter *movieWriter;
    GPUImageMovie *movieFile;
}
@property (nonatomic,strong) FFEditVideoView *editBgView;

@end

@implementation FFVideoEditController
-(BOOL)prefersStatusBarHidden
{
    return YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.preImageView = [[GPUImageView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:self.preImageView];
    self.imageMovie = [[GPUImageMovie alloc]initWithURL:self.pathURL];
    self.imageMovie.shouldRepeat = YES;//循环
    [self.imageMovie addTarget:self.preImageView];
    [self.imageMovie startProcessing];
    
  
    
    
    self.editBgView = [[FFEditVideoView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:self.editBgView];
    self.editBgView.backgroundColor = [UIColor clearColor];
//    FFLOG(@"pathURL %@ ",self.pathURL);
//    self.editBgView.pathURL = self.pathURL;
    self.editBgView.editVideoDelegate = self;
    
    
}


#pragma mark - FFEditVideoViewDelegate
- (void)editVideoAction:(EditVideoViewActionType)actionType{
    switch (actionType) {
        case EditVideoViewActionTypeSave:
        {
            [self saveVideo];
//            [self useGpuimage];
            break;
        }
        case EditVideoViewActionTypeRetryRecord:
        {
            [self dismissViewControllerAnimated:YES completion:nil];
            
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - saveVideo
- (void)saveVideo{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(self.pathStr))
                {
                    [library writeVideoAtPathToSavedPhotosAlbum:self.pathURL completionBlock:^(NSURL *assetURL, NSError *error)
                     {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             if (error) {
                                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"视频保存失败" message:nil
                                                                                delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                 [alert show];
                             } else {
                                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"视频保存成功" message:nil
                                                                                delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                 [alert show];
                                 [self dismissViewControllerAnimated:YES completion:nil];
                                 
                             }
                         });
                     }];
                }
}


-(void)useGpuimage{
//    NSURL *videoPath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"selfS" ofType:@"MOV"]];
    [self saveVedioPath:nil WithWaterImg:[UIImage imageNamed:@"take_photo_height"] WithCoverImage:[UIImage imageNamed:@"preview"] WithQustion:@"文字水印：hudongdongBlog" WithFileName:@"waterVideo"];
}



/**
 使用GPUImage加载水印
 
 @param vedioPath 视频路径
 @param img 水印图片
 @param coverImg 水印图片二
 @param question 字符串水印
 @param fileName 生成之后的视频名字
 */
-(void)saveVedioPath:(NSURL*)vedioPath WithWaterImg:(UIImage*)img WithCoverImage:(UIImage*)coverImg WithQustion:(NSString*)question WithFileName:(NSString*)fileName
{
    [SVProgressHUD showWithStatus:@"生成水印视频到系统相册"];
    // 滤镜
    //    filter = [[GPUImageDissolveBlendFilter alloc] init];
    //    [(GPUImageDissolveBlendFilter *)filter setMix:0.0f];
    //也可以使用透明滤镜
    //    filter = [[GPUImageAlphaBlendFilter alloc] init];
    //    //mix即为叠加后的透明度,这里就直接写1.0了
    //    [(GPUImageDissolveBlendFilter *)filter setMix:1.0f];
    
    filter = [[GPUImageNormalBlendFilter alloc] init];
    
//    NSURL *sampleURL  = vedioPath;
//    AVAsset *asset = [AVAsset assetWithURL:sampleURL];
//    CGSize size = asset.naturalSize;
    
//    movieFile = [[GPUImageMovie alloc] initWithAsset:asset];
    movieFile = [[GPUImageMovie alloc] initWithURL:self.pathURL];
    movieFile.playAtActualSpeed = NO;
    
    // 文字水印
    UILabel *label = [[UILabel alloc] init];
    label.text = question;
    label.font = [UIFont systemFontOfSize:30];
    label.textColor = [UIColor whiteColor];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label sizeToFit];
    label.layer.masksToBounds = YES;
    label.layer.cornerRadius = 18.0f;
    [label setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
    [label setFrame:CGRectMake(50, 100, label.frame.size.width+20, label.frame.size.height)];
    
    //图片水印
    UIImage *coverImage1 = [img copy];
    UIImageView *coverImageView1 = [[UIImageView alloc] initWithImage:coverImage1];
    [coverImageView1 setFrame:CGRectMake(0, 100, 210, 50)];
    
    //第二个图片水印
    UIImage *coverImage2 = [coverImg copy];
    UIImageView *coverImageView2 = [[UIImageView alloc] initWithImage:coverImage2];
    [coverImageView2 setFrame:CGRectMake(270, 100, 210, 50)];
    
    UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth,kScreenHeight)];
    subView.backgroundColor = [UIColor clearColor];
    
    [subView addSubview:coverImageView1];
    [subView addSubview:coverImageView2];
    [subView addSubview:label];
    
    
    GPUImageUIElement *uielement = [[GPUImageUIElement alloc] initWithView:subView];
//    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.mp4",fileName]];
//    unlink([pathToMovie UTF8String]);
//
    
//    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    NSURL *movieURL = self.pathURL;
    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(720.0, 1280.0)];
    
    GPUImageFilter* progressFilter = [[GPUImageFilter alloc] init];
    [progressFilter addTarget:filter];
    [movieFile addTarget:progressFilter];
    [uielement addTarget:filter];
    movieWriter.shouldPassthroughAudio = YES;
    //    movieFile.playAtActualSpeed = true;
//    if ([[asset tracksWithMediaType:AVMediaTypeAudio] count] > 0){
    movieFile.audioEncodingTarget = movieWriter;
//    } else {//no audio
//        movieFile.audioEncodingTarget = nil;
//    }
    [movieFile enableSynchronizedEncodingUsingMovieWriter:movieWriter];
    // 显示到界面
    [filter addTarget:movieWriter];
    
    [movieWriter startRecording];
    [movieFile startProcessing];
    
    //    dlink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateProgress)];
    //    [dlink setFrameInterval:15];
    //    [dlink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    //    [dlink setPaused:NO];
    
    __weak typeof(self) weakSelf = self;
    //渲染
    [progressFilter setFrameProcessingCompletionBlock:^(GPUImageOutput *output, CMTime time) {
        //水印可以移动
        CGRect frame = coverImageView1.frame;
        frame.origin.x += 1;
        frame.origin.y += 1;
        coverImageView1.frame = frame;
        //第5秒之后隐藏coverImageView2
        if (time.value/time.timescale>=5.0) {
            [coverImageView2 removeFromSuperview];
        }
        [uielement update];
        
    }];
    
    
    
    
    //保存相册
    [movieWriter setCompletionBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf->filter removeTarget:strongSelf->movieWriter];
            [strongSelf->movieWriter finishRecording];
            __block PHObjectPlaceholder *placeholder;
//            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(pathToMovie))
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(self.pathStr))
            {
                NSError *error;
                [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                    PHAssetChangeRequest* createAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:movieURL];
                    placeholder = [createAssetRequest placeholderForCreatedAsset];
                } error:&error];
                if (error) {
                    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",error]];
                }
                else{
                    [SVProgressHUD showSuccessWithStatus:@"视频已经保存到相册"];
                }
            }
        });
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
