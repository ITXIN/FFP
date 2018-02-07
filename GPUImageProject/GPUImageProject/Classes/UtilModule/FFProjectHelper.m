//
//  FFProjectHelper.m
//  GPUImageProject
//
//  Created by avazuholding on 2017/9/29.
//  Copyright © 2017年 bert. All rights reserved.
//

#import "FFProjectHelper.h"

@implementation FFProjectHelper
+(BOOL )isUpScrollWithScollOffset:(CGFloat)offset
{
    static float newx = 0;
    static float oldx = 0;
    newx= offset;
    static BOOL isUpOrDown = false;
    if (newx != oldx )
    {
        //up-yes,down-no
        if (newx > oldx) {
            isUpOrDown = NO;
        }else if(newx < oldx){
            isUpOrDown = YES;
        }
        oldx = newx;
    }else
    {
    }
    return isUpOrDown;
}
@end
