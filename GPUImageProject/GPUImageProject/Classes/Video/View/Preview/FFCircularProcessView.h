//
//  FFCircularProcessView.h
//  GPUImageProject
//
//  Created by avazuholding on 2017/9/27.
//  Copyright © 2017年 bert. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol FFCircularProcessViewDelegate

- (void)circularProgressEnd;
- (void)timerAction:(NSInteger)time;
@end

@interface FFCircularProcessView : UIView
{
    CGFloat startAngle;
    CGFloat endAngle;
    int     totalTime;
    UIFont *textFont;
    UIColor *textColor;
    NSMutableParagraphStyle *textStyle;
    
    NSTimer *m_timer;
    bool b_timerRunning;
    CGFloat RADIUS;
}
@property(nonatomic, assign) id<FFCircularProcessViewDelegate> delegate;
@property(nonatomic)CGFloat time_left;

- (void)setTotalSecondTime:(CGFloat)time;
- (void)setTotalMinuteTime:(CGFloat)time;

- (void)startTimer;
- (void)stopTimer;
- (void)pauseTimer;
@end
