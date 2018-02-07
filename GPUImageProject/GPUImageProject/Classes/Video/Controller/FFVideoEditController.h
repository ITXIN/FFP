//
//  FFVideoEditController.h
//  GPUImageProject
//
//  Created by avazuholding on 2017/9/27.
//  Copyright © 2017年 bert. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FFVideoEditController : UIViewController
@property (nonatomic,strong) GPUImageMovie *imageMovie;
@property (nonatomic,strong) GPUImageView *preImageView;
@property (nonatomic,strong) NSURL *pathURL;
@property (nonatomic,strong) NSString  *pathStr;


@end
