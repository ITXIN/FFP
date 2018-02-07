//
//  FFVideoFilterModel.h
//  GPUImageProject
//
//  Created by avazuholding on 2017/9/26.
//  Copyright © 2017年 bert. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GPUImageOutput;
@interface FFVideoFilterModel : NSObject
@property (nonatomic,strong) GPUImageOutput<GPUImageInput> *filter;
@property (nonatomic,strong) NSString *filterName;

@end
