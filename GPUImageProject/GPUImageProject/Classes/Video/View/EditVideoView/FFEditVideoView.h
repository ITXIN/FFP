//
//  FFEditVideoView.h
//  GPUImageProject
//
//  Created by avazuholding on 2017/9/28.
//  Copyright © 2017年 bert. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol FFEditVideoViewDelegate<NSObject>
- (void)editVideoAction:(EditVideoViewActionType)actionType;
@end
@interface FFEditVideoView : UIView
@property (nonatomic,strong) UIView *bgView;
@property (nonatomic,strong) UIView *headerView;
@property (nonatomic,strong) UIView *bottomView;
@property (nonatomic,strong) UIButton *retryRecordBtn;
@property (nonatomic,strong) UIButton *saveBtn;
//
//@property (nonatomic,strong) GPUImageMovie *imageMovie;
//@property (nonatomic,strong) GPUImageView *preImageView;
//@property (nonatomic,strong) NSURL *pathURL;
@property (nonatomic,assign) id <FFEditVideoViewDelegate> editVideoDelegate;
@end
