//
//  APPHeader.h
//  GPUImageProject
//
//  Created by avazuholding on 2017/9/22.
//  Copyright © 2017年 bert. All rights reserved.
//

#ifndef APPHeader_h
#define APPHeader_h
#ifdef DEBUG  //调试阶段
#define FFLOG(...) NSLog(@"%s 第%d行 \n %@\n\n",__func__,__LINE__,[NSString stringWithFormat:__VA_ARGS__])
#else  //发布阶段
#define FFLOG(...)
#endif

#ifndef weakify
#if DEBUG
#if __has_feature(objc_arc)
#define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

#ifndef strongify
#if DEBUG
#if __has_feature(objc_arc)
#define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif

#define kScreenWidth        [UIScreen mainScreen].bounds.size.width
#define kScreenHeight       [UIScreen mainScreen].bounds.size.height
#define ScreenWidthRatio    kScreenWidth / 320.0
#define ScreenHeightRatio   kScreenHeight / 568.0

#define Screen35Inch        (kScreenHeight  == 480.0)
#define Screen4Inch         (kScreenHeight  == 568.0)
#define Screen47Inch        (kScreenWidth   == 375.0)
#define Screen55Inch        (kScreenWidth   == 414.0)

#undef	RGB
#define RGB(R,G,B)		[UIColor colorWithRed:R/255.0f green:G/255.0f blue:B/255.0f alpha:1.0f]

#undef	RGBA
#define RGBA(R,G,B,A)	[UIColor colorWithRed:R/255.0f green:G/255.0f blue:B/255.0f alpha:A]

#define kFilterKey @"filter"
#define kFilterNameKey @"filterName"

#define kWaterMarkKey @"waterMark"
#define kWaterMarkNameKey @"waterMarkName"


#define kCircularWidth 90

#define kPressetWidth 720
#define kPressetHeight 1280


#endif /* APPHeader_h */
