//
//  FFVideoViewController.m
//  GPUImageProject
//
//  Created by avazuholding on 2017/9/22.
//  Copyright © 2017年 bert. All rights reserved.
//

#import "FFVideoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import "GPUImageBeautifyFilter.h"
#import "FFVideoEditController.h"
#import <Photos/Photos.h>

#import "FFVideoPreview.h"
#import "FFVideoEditActionView.h"
@interface FFVideoViewController ()<FFVideoEditActionViewDelegate,FFVideoPreviewDelegate>

@property (nonatomic, strong) FFVideoPreview *videoPreview;
@property (nonatomic, strong) FFVideoEditActionView *videoEditActionView;
//@property (nonatomic,strong) GPUImageMovieWriter * movieWriter;
@end

@implementation FFVideoViewController

-(BOOL)prefersStatusBarHidden
{
    return YES;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    
    self.videoPreview = [[FFVideoPreview alloc]initWithFrame:self.view.bounds];
    self.videoPreview.videoPreviewDelegate = self;
    [self.view addSubview:self.videoPreview];
    self.videoPreview.backgroundColor = [UIColor redColor];
    [self.videoPreview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.videoEditActionView = [[FFVideoEditActionView alloc]initWithFrame:self.view.bounds];
    self.videoEditActionView.editActionViewDelegate = self;
    [self.view addSubview:self.videoEditActionView];
    [self.videoEditActionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
}

#pragma mark - FFVideoPreviewDelegate
- (void)previewAction:(VideoViewActionType)actionType{
    switch (actionType) {
        case VideoViewActionTypeTakeTapGuesture:
        {
            FFLOG(@"VideoViewActionTypeTakeTapGuesture");
            break;
        }
        case VideoViewActionTypeClose:
        {
            break;
        }
        case VideoViewActionTypeFilter:
        {
            break;
        }
        case VideoViewActionTypeEndRecordVideo:
        {
            [self.videoPreview endRecordVideo];
            [self saveVideo];
//            FFVideoEditController *editVC = [[FFVideoEditController alloc]init];
//            editVC.pathURL = self.videoPreview.movieURL;
//            editVC.pathStr = self.videoPreview.pathToMovie;
//            [self presentViewController:editVC animated:YES completion:nil];
            break;
        }
        case VideoViewActionTypeBeginRecordVideo:
        {
            [self.videoPreview startRecordVideo];
            break;
        }
        case VideoViewActionTypeFlash:
        {
            [self.videoPreview flashLightAction];
            break;
        }
        case VideoViewActionTypeSwitchCamera:
        {
            [self.videoPreview switchCamera];
            break;
        }
        case VideoViewActionTypeTakePhoto:
        {
            [self.videoPreview takePhoto];
            break;
        }
            
        default:
            break;
    }
}

- (void)didSeletedFilter:(GPUImageOutput<GPUImageInput> *)filter waterMark:(FFVideoWaterMarkModel *)waterMark{
    [self.videoPreview makeFilterWithFilter:filter waterMark:waterMark];
}

- (void)focusAtPoint:(CGPoint)point{
    [self.videoPreview focusWithPoint:point];
}
#pragma mark - FFVideoPreviewDelegate
- (void)takePhotoSuccess:(UIImage *)image{
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        __unused   PHAssetChangeRequest *req = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        FFLOG(@"-----save picture %d  %@",success,error.description);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"照片保存失败" message:nil
                                                               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"照片保存成功" message:nil
                                                               delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                [self dismissViewControllerAnimated:YES completion:nil];
                
            }
        });
    }];
}

#pragma mark -
#pragma mark - saveVideo
- (void)saveVideo{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(self.videoPreview.pathToMovie))
    {
        [library writeVideoAtPathToSavedPhotosAlbum:self.videoPreview.movieURL completionBlock:^(NSURL *assetURL, NSError *error)
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
