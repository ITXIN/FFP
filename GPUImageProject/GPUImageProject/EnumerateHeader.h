//
//  EnumerateHeader.h
//  GPUImageProject
//
//  Created by avazuholding on 2017/9/27.
//  Copyright © 2017年 bert. All rights reserved.
//
#import <UIKit/UIKit.h>
#ifndef EnumerateHeader_h
#define EnumerateHeader_h

//视频预览
typedef NS_ENUM(NSInteger, VideoViewActionType){
    VideoViewActionTypeClose = 1000,
    VideoViewActionTypeFlash,
    VideoViewActionTypeSwitchCamera,
    VideoViewActionTypeFilter,
    VideoViewActionTypeWaterMark,
    VideoViewActionTypeBeginRecordVideo,
    VideoViewActionTypeEndRecordVideo,
    VideoViewActionTypeTakePhoto,
    VideoViewActionTypeTakeTapGuesture,
};

//视频编辑
typedef NS_ENUM(NSInteger, EditVideoViewActionType){
    EditVideoViewActionTypeRetryRecord = 1000,
    EditVideoViewActionTypeSave,
//    EditVideoViewActionType,
//    EditVideoViewActionType,
//    EditVideoViewActionType,
//    EditVideoViewActionType,
};


#endif /* EnumerateHeader_h */
