//
//  FFCircularProcessView.m
//  GPUImageProject
//
//  Created by avazuholding on 2017/9/27.
//  Copyright © 2017年 bert. All rights reserved.
//

#import "FFCircularProcessView.h"
//#define RADIUS 85/2
#define POINT_RADIUS 8
#define CIRCLE_WIDTH 4
#define PROGRESS_WIDTH 4
#define TEXT_SIZE 140
#define TIMER_INTERVAL 0.05
@implementation FFCircularProcessView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        [self initSubviews];
    }
    return self;
    
}
- (void)initSubviews{
    startAngle = -0.5*M_PI;
    endAngle = startAngle;
    totalTime = 0;
    b_timerRunning = NO;
    RADIUS = (kCircularWidth -4)/2;
    self.backgroundColor = [UIColor clearColor];
}
-(void)drawRect:(CGRect)rect{
    if (totalTime == 0) {
        endAngle = startAngle;
    }else{
        endAngle = (1-self.time_left/totalTime)*2*M_PI + startAngle;
    }
    
    UIBezierPath *circle = [UIBezierPath bezierPath];
    [circle addArcWithCenter:CGPointMake(rect.size.width/2, rect.size.height/2) radius:RADIUS startAngle:0 endAngle:2*M_PI clockwise:YES];
    circle.lineWidth = CIRCLE_WIDTH;
    [[UIColor whiteColor] setStroke];
    [circle stroke];
    
    
    UIBezierPath *progress = [UIBezierPath bezierPath];
    [progress addArcWithCenter:CGPointMake(rect.size.width/2, rect.size.height/2) radius:RADIUS startAngle:startAngle endAngle:endAngle clockwise:YES];
    progress.lineWidth = PROGRESS_WIDTH;
    [RGB(72, 147, 242) set];
    [progress stroke];
    
    //点
//    CGPoint point = [self getCurrentPointAtAngle:endAngle inRect:rect];
//    [self drawPointAt:point];
    
}
- (CGPoint)getCurrentPointAtAngle:(CGFloat)angle inRect:(CGRect)rect{
    CGFloat y = sin(angle)*RADIUS;
    CGFloat x = cos(angle)*RADIUS;
    CGPoint pos = CGPointMake(rect.size.width/2, rect.size.height/2);
    pos.x += x;
    pos.y += y;
    return pos;
}
- (void)drawPointAt:(CGPoint)point{
    UIBezierPath *dot = [UIBezierPath bezierPath];
    [dot addArcWithCenter:CGPointMake(point.x, point.y) radius:POINT_RADIUS startAngle:0 endAngle:2*M_PI clockwise:YES];
    dot.lineWidth = 1;
    [dot fill];
}

- (void)setTotalSecondTime:(CGFloat)time{
    totalTime = time;
    self.time_left = totalTime;
}

- (void)setTotalMinuteTime:(CGFloat)time{
    totalTime = time;
    self.time_left = totalTime;
}

- (void)startTimer{
    if (!b_timerRunning) {
        m_timer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL target:self selector:@selector(setProgress) userInfo:nil repeats:YES];
        b_timerRunning = YES;
    }
}
- (void)pauseTimer{
    if (b_timerRunning) {
        [m_timer invalidate];
        m_timer = nil;
        b_timerRunning = NO;
    }
}

- (void)setProgress{
//    FFLOG(@"left time %d",self.time_left);
    if (self.time_left > 0) {
        self.time_left -= TIMER_INTERVAL;
        if (_delegate) {
            [_delegate timerAction:totalTime - self.time_left];
        }
        [self setNeedsDisplay];
    }else{
        [self pauseTimer];
        if (_delegate) {
            [_delegate circularProgressEnd];
        }
    }
}

- (void)stopTimer{
    [self pauseTimer];
    startAngle = -0.5 *M_PI;
    endAngle = startAngle;
    self.time_left = totalTime;
    [self setNeedsDisplay];
}
@end
