//
//  FFVideoEditActionView.m
//  GPUImageProject
//
//  Created by avazuholding on 2017/9/29.
//  Copyright © 2017年 bert. All rights reserved.
//

#import "FFVideoEditActionView.h"
#import "GPUImageBeautifyFilter.h"
#import "FFVideoManager.h"
#import "FFVideoFilterCell.h"
#import "FFVideoFilterModel.h"
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <Photos/Photos.h>
#import "FFCircularProcessView.h"
#import "FFWaterView.h"
@interface FFVideoEditActionView ()<UICollectionViewDelegate,UICollectionViewDataSource,UIGestureRecognizerDelegate,FFCircularProcessViewDelegate,UIScrollViewDelegate>
{
    FFVideoFilterCell *filterSeletedCell;
    FFVideoFilterCell *waterMarkSeletedCell;
    CGFloat recrodW;
    
}
@property (nonatomic,strong) FFCircularProcessView *circularProcessView;

//@property (nonatomic,strong) FFWaterView *waterView;
@property (nonatomic,strong) FFVideoWaterMarkModel *currentWaterModel;

@end

@implementation FFVideoEditActionView
static NSString *identify = @"FilterIdentify";
static CGFloat bottomHeight = 200;
static CGFloat bottomHeaderHeight = 50;
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        flowLayout.itemSize = CGSizeMake((kScreenWidth-50)/4, (kScreenWidth-50)/4);
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, bottomHeight) collectionViewLayout:flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = RGBA(0, 0, 0,0);
        for (NSInteger i = 0; i < self.filterArr.count ; i++) {
            NSString * stringID = [NSString stringWithFormat:@"%@%ld",identify,i];
            [_collectionView registerClass:[FFVideoFilterCell class] forCellWithReuseIdentifier:stringID];
        }
    }
    return _collectionView;
}

- (UICollectionView *)waterMarkCollectionView{
    if (!_waterMarkCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        flowLayout.itemSize = CGSizeMake((kScreenWidth-50)/4, (kScreenWidth-50)/4);
        _waterMarkCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, bottomHeight) collectionViewLayout:flowLayout];
        _waterMarkCollectionView.delegate = self;
        _waterMarkCollectionView.dataSource = self;
        _waterMarkCollectionView.backgroundColor = RGBA(0, 0, 0,0);
        for (NSInteger i = 0; i < self.wateMarkArr.count ; i++) {
            NSString * stringID = [NSString stringWithFormat:@"%@%ld",identify,i];
            [_waterMarkCollectionView registerClass:[FFVideoFilterCell class] forCellWithReuseIdentifier:stringID];
        }
        
    }
    return _waterMarkCollectionView;
}

- (FFCircularProcessView *)circularProcessView{
    if (!_circularProcessView) {
        _circularProcessView = [[FFCircularProcessView alloc]init];
        _circularProcessView.delegate = self;
        [_circularProcessView setTotalSecondTime:10];
    }
    return _circularProcessView;
}

- (NSMutableArray *)wateMarkArr{
    if (!_wateMarkArr) {
        _wateMarkArr = [NSMutableArray arrayWithArray:[[FFVideoManager sharedInstance]createWaterMark]];
    }
    return _wateMarkArr;
}
- (NSMutableArray *)filterArr{
    if (!_filterArr) {
        _filterArr = [NSMutableArray arrayWithArray:[[FFVideoManager sharedInstance] createGPUFilterArr]];
    }
    return _filterArr;
}


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initFilter];
    }
    return self;
}
- (instancetype)init{
    self = [super init];
    if (self)
    {
        [self initFilter];
    }
    return self;
}

#pragma mark - arguments
#pragma mark - initFilter
- (void)initFilter{
    self.pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie4.m4v"];
    self.movieURL = [NSURL fileURLWithPath:self.pathToMovie];
    unlink([self.pathToMovie UTF8String]); // 如果已经存在文件，AVAssetWriter会有异常，删除旧文件
    FFVideoFilterModel *filterModel = (FFVideoFilterModel*)self.filterArr[0];
    GPUImageOutput<GPUImageInput> *pixellaterFiler = filterModel.filter;
    self.currentFilter = pixellaterFiler;
    self.currentWaterModel = self.wateMarkArr[0];
    
    self.bgView = ({
        UIView *view = [[UIView alloc]init];
        [self addSubview:view];
        view.backgroundColor = [UIColor clearColor];
        view;
    });

    self.spaceView = ({
        UIView *view = [[UIView alloc]init];
        [self.bgView addSubview:view];
        view.backgroundColor = [UIColor clearColor];
        view.userInteractionEnabled = YES;
        view.tag = 10000;
        view;
    });
    
    self.identifyArr = [NSMutableArray array];
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    tapGes.delegate = self;
    [self.spaceView addGestureRecognizer:tapGes];
//    self.spaceView.backgroundColor = [UIColor redColor];
    
    self.closeBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.bgView addSubview:btn];
        btn.tag = VideoViewActionTypeClose;
        [btn addTarget:self action:@selector(videoViewAction:) forControlEvents:UIControlEventTouchUpInside];
        [btn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        btn;
    });
    
    self.switchCameraBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.bgView addSubview:btn];
        btn.tag = VideoViewActionTypeSwitchCamera;
        [btn addTarget:self action:@selector(videoViewAction:) forControlEvents:UIControlEventTouchUpInside];
        [btn setImage:[UIImage imageNamed:@"switch_camera"] forState:UIControlStateNormal];
        btn;
    });
    self.flashBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.bgView addSubview:btn];
        btn.tag = VideoViewActionTypeFlash;
        [btn addTarget:self action:@selector(videoViewAction:) forControlEvents:UIControlEventTouchUpInside];
        [btn setImage:[UIImage imageNamed:@"flash_normal"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"flash_seleted"] forState:UIControlStateSelected];
        btn;
    });
    
    self.bottomView = ({
        UIView *view = [[UIView alloc]init];
        [self.bgView addSubview:view];
        view.backgroundColor = [UIColor clearColor];
        view;
    });
    
    self.scrollView = [[UIScrollView alloc]init];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.contentSize = CGSizeMake(kScreenWidth*2, 0);
    self.scrollView.alwaysBounceHorizontal = NO;
    self.scrollView.bounces = NO;
    [self.bottomView addSubview:self.scrollView];

    self.filterBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.bottomView addSubview:btn];
        btn.tag = VideoViewActionTypeFilter;
        btn.selected = NO;
        [btn addTarget:self action:@selector(filterAction:) forControlEvents:UIControlEventTouchUpInside];
        [btn setImage:[UIImage imageNamed:@"filter_normal"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"filter_seleted"] forState:UIControlStateSelected];
        btn;
    });
    
    self.waterMarkBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.bottomView addSubview:btn];
        btn.tag = VideoViewActionTypeWaterMark;
        btn.selected = NO;
        [btn addTarget:self action:@selector(waterMarkAction:) forControlEvents:UIControlEventTouchUpInside];
        [btn setImage:[UIImage imageNamed:@"watermark_normal"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"watermark_seleted"] forState:UIControlStateSelected];
        btn;
    });
    
    
    self.lineView = ({
        UIView *view = [[UIView alloc]init];
        [self.bottomView addSubview:view];
        view.backgroundColor = RGBA(255, 255, 255, 0.5);
        view;
    });
    
    self.timeLab = ({
        UILabel *label = [[UILabel alloc]init];
        [self.bottomView addSubview:label];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:11];
        
        label;
    });
    
    self.recordVideoBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.bottomView addSubview:btn];
        btn.selected = NO;
        btn.hidden = NO;
        [btn setImage:[UIImage imageNamed:@"take_photo_click"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"take_photo_height"] forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(takePhotoAction:) forControlEvents:UIControlEventTouchUpInside];
        //button长按事件
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTapAction:)];
        longPress.minimumPressDuration = 0.8; //定义按的时间
        [btn addGestureRecognizer:longPress];
        
        btn;
    });
    
    filterSeletedCell = nil;
    waterMarkSeletedCell = nil;
    [self updateConstraintsWithFilterState:NO];
    [self setupBottomCollectionView];
    
    
    _focusView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
    _focusView.layer.borderWidth = 1.0;
    _focusView.layer.borderColor =[UIColor greenColor].CGColor;
    _focusView.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:_focusView];
    _focusView.hidden = YES;
}
- (void)setupBottomCollectionView{
    if (![self.scrollView.subviews containsObject:self.collectionView] ) {
        [self.scrollView addSubview:self.collectionView];
        [self.scrollView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.trailing.leading.equalTo(self.bottomView);
            make.bottom.mas_equalTo(0);
            make.height.mas_equalTo(bottomHeight);
        }];
        
        [self.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.top.mas_equalTo(0);
            make.size.mas_equalTo(CGSizeMake(kScreenWidth, bottomHeight));
        }];
        [self.scrollView addSubview:self.waterMarkCollectionView];
        
        [self.waterMarkCollectionView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.collectionView);
            make.left.mas_equalTo(kScreenWidth);
            make.size.mas_equalTo(CGSizeMake(kScreenWidth, bottomHeight));
        }];
    }
}


#pragma mark -
- (void)tapAction:(UITapGestureRecognizer*)sender{
    if (self.editActionViewDelegate && [self.editActionViewDelegate respondsToSelector:@selector(previewAction:)]) {
        [self.editActionViewDelegate previewAction:VideoViewActionTypeTakeTapGuesture];
    }
    [self updateConstraintsWithFilterState:NO];
    self.filterBtn.selected = NO;
    self.waterMarkBtn.selected = NO;
    
    CGPoint point = [sender locationInView:sender.view];
//    CGSize size = self.bounds.size;
//    CGPoint focusPoint = CGPointMake(point.y/size.height, 1-point.x/size.width);
   
    _focusView.center = point;
    _focusView.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        _focusView.transform = CGAffineTransformMakeScale(1.25, 1.25);
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            _focusView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            _focusView.hidden = YES;
        }];
    }];
    
    if (self.editActionViewDelegate && [self.editActionViewDelegate respondsToSelector:@selector(focusAtPoint:)]) {
        [self.editActionViewDelegate focusAtPoint:point];
    }
    
}
#pragma mark -
- (void)videoViewAction:(UIButton*)sender{
    if (sender.tag == VideoViewActionTypeFlash) {
        sender.selected = !sender.selected;
    }
    
    if (self.editActionViewDelegate && [self.editActionViewDelegate respondsToSelector:@selector(previewAction:)]) {
        [self.editActionViewDelegate previewAction:sender.tag];
    }
}

#pragma mark - update
- (void)updateConstraintsWithFilterState:(BOOL)isFilterState{
    if (isFilterState) {
        self.recordVideoBtn.hidden = YES;
        self.lineView.hidden = NO;
        self.bottomView.backgroundColor = RGBA(0, 0, 0, 0.5);
        [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.trailing.leading.equalTo(self.bgView);
            make.bottom.mas_equalTo(0);
            make.height.mas_equalTo(bottomHeight+bottomHeaderHeight);
        }];
        self.scrollView.hidden = NO;
        
    }else{
        self.recordVideoBtn.hidden = NO;
        self.lineView.hidden = YES;
        self.scrollView.hidden = YES;
        self.bottomView.backgroundColor = [UIColor clearColor];
        [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.trailing.leading.equalTo(self.bgView);
            make.bottom.mas_equalTo(0);
            make.height.mas_equalTo(bottomHeight-bottomHeaderHeight);
        }];
        
        [self.filterBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.bottomView).offset(-50);
            make.top.mas_equalTo(10);
        }];
        [self.waterMarkBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.bottomView).offset(50);
            make.top.equalTo(self.filterBtn);
        }];
        [self.lineView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.bottomView);
            make.top.mas_equalTo(self.filterBtn.mas_bottom).offset(6);
            make.leading.trailing.equalTo(self.bottomView);
            make.height.mas_equalTo(0.5);
        }];
        
        [self.recordVideoBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.bottomView);
            make.top.equalTo(self.filterBtn.mas_bottom).offset(17);
        }];
        
    }
}

#pragma mark -
- (void)filterAction:(UIButton*)sender{
    [self  bottomHeaderAction:sender];
}
- (void)waterMarkAction:(UIButton*)sender{
    [self  bottomHeaderAction:sender];
}
- (void)bottomHeaderAction:(UIButton*)sender{
    if (sender.selected) {
        sender.selected = !sender.selected;
        
        [self updateConstraintsWithFilterState:NO];
        return;
    }
    
    if (!sender.selected) {
        [self updateConstraintsWithFilterState:YES];
    }else{
        [self updateConstraintsWithFilterState:NO];
    }
    sender.selected = !sender.selected;
    
    if ([sender isEqual:self.waterMarkBtn]) {
        self.filterBtn.selected = !sender.selected;
        [self.scrollView setContentOffset:CGPointMake(kScreenWidth, 0) animated:YES];
    }else if ([sender isEqual:self.filterBtn]){
        self.waterMarkBtn.selected = !sender.selected;
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    
}

#pragma mark - takePhoto
- (void)takePhotoAction:(UIButton*)sender{
    FFLOG(@"takePhotoAction");
    if (self.editActionViewDelegate && [self.editActionViewDelegate respondsToSelector:@selector(previewAction:)]) {
        [self.editActionViewDelegate previewAction:VideoViewActionTypeTakePhoto];
    }
}
- (void)longTapAction:(UITapGestureRecognizer*)sender{
    FFLOG(@"longTapAction");
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        {
            FFLOG(@"UIGestureRecognizerStateBegan");
            [self beginRecordVideo];
            
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            FFLOG(@"UIGestureRecognizerStateEnded");
            [self endRecordVideo];
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            FFLOG(@"UIGestureRecognizerStateChanged");
            break;
        }
        case UIGestureRecognizerStatePossible:
        {
            FFLOG(@"UIGestureRecognizerStatePossible");
            break;
        }
            
        case UIGestureRecognizerStateCancelled:
        {
            FFLOG(@"UIGestureRecognizerStateCancelled");
            break;
        }
        case UIGestureRecognizerStateFailed:
        {
            FFLOG(@"UIGestureRecognizerStateFailed");
            break;
        }
            
        default:
            break;
    }
}
#pragma mark - beginRecordVideo
- (void)beginRecordVideo{
    [self.circularProcessView startTimer];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.filterBtn.hidden = YES;
        self.waterMarkBtn.hidden = YES;
        self.timeLab.hidden = NO;
        [self.bottomView insertSubview:self.circularProcessView belowSubview:self.recordVideoBtn];
        [self.circularProcessView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.recordVideoBtn);
            make.size.mas_equalTo(CGSizeMake(kCircularWidth, kCircularWidth));
        }];
        [self.timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.bottomView);
            make.bottom.equalTo(self.circularProcessView.mas_top).offset(-10);
        }];
    });
    
    if (self.editActionViewDelegate && [self.editActionViewDelegate respondsToSelector:@selector(previewAction:)]) {
        [self.editActionViewDelegate previewAction:VideoViewActionTypeBeginRecordVideo];
    }
}

- (void)endRecordVideo{
    [self.circularProcessView pauseTimer];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.waterMarkBtn.hidden = NO;
        self.filterBtn.hidden = NO;
        self.timeLab.hidden = YES;
        self.recordVideoBtn.hidden = NO;
        [self.recordVideoBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.bottomView);
            make.top.equalTo(self.filterBtn.mas_bottom).offset(17);
        }];
        
        [self.circularProcessView removeFromSuperview];
        self.circularProcessView = nil;
    });
    if (self.editActionViewDelegate && [self.editActionViewDelegate respondsToSelector:@selector(previewAction:)]) {
        [self.editActionViewDelegate previewAction:VideoViewActionTypeEndRecordVideo];
    }
}

#pragma mark tapGestureRecgnizerdelegate 解决手势冲突
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    FFLOG(@"%@",NSStringFromClass([touch.view class]));
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UIView"]) {
        if (touch.view.tag == 1000 ) {
            
            FFLOG(@"space white");
            if (self.editActionViewDelegate && [self.editActionViewDelegate respondsToSelector:@selector(previewAction:)]) {
                [self.editActionViewDelegate previewAction:VideoViewActionTypeTakePhoto];
            }
        }
    }
    if ([touch.view isKindOfClass:[UITableView class]]){
        return NO;
    }
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return YES;
}
#pragma mark -FFCirculationViewDelegate
- (void)circularProgressEnd{
    FFLOG(@"circularProgressEnd");
    [self endRecordVideo];
}
- (void)timerAction:(NSInteger)time{
    self.timeLab.text = [NSString stringWithFormat:@"%d 秒",time];
}

#pragma mark - scrollviewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.scrollView]) {
        NSInteger index = scrollView.contentOffset.x/kScreenWidth;
        FFLOG(@"index %ld ",index);
        if (index == 0) {
            [self filterAction:self.filterBtn];
        }else if(index == 1){
            [self waterMarkAction:self.waterMarkBtn];
        }
    }
    
    
    
}
#pragma mark --- UICollectionViwDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([collectionView isEqual:self.collectionView]) {
        return self.filterArr.count;
    }else{
        return self.wateMarkArr.count;
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([collectionView isEqual:self.collectionView]) {

       
        [filterSeletedCell setSelected:NO];
        FFVideoFilterCell *cell = (FFVideoFilterCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
        filterSeletedCell = cell;
        
        FFVideoFilterModel *filterModel = (FFVideoFilterModel*)self.filterArr[indexPath.row];
        GPUImageOutput<GPUImageInput> *pixellaterFiler =  filterModel.filter;
        self.currentFilter = pixellaterFiler;

    }else{
        [waterMarkSeletedCell setSelected:NO];
        FFVideoFilterCell *cell = (FFVideoFilterCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
        waterMarkSeletedCell = cell;
        self.currentWaterModel = self.wateMarkArr[indexPath.row];
        if (indexPath.row != 0) {
            self.isWaterMark = YES;
        }else{
            self.isWaterMark = NO;
        }
        
    }
    
    if (self.editActionViewDelegate && [self.editActionViewDelegate respondsToSelector:@selector(didSeletedFilter:waterMark:)]) {
        if (_isWaterMark) {
            [self.editActionViewDelegate didSeletedFilter:self.currentFilter waterMark:self.currentWaterModel];
        }else{
            [self.editActionViewDelegate didSeletedFilter:self.currentFilter waterMark:nil];
        }
    }
    
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *stringID = [NSString stringWithFormat:@"%@%ld",identify,indexPath.row];
    
    if ([collectionView isEqual:self.collectionView ]) {
        FFVideoFilterCell *cell = (FFVideoFilterCell*)[collectionView dequeueReusableCellWithReuseIdentifier:stringID forIndexPath:indexPath];
        
        if (self.filterArr.count > 0){
            if (indexPath.row == 0) {
                if (filterSeletedCell==nil) {
                    filterSeletedCell = cell;
                }
            }
            if (![self.identifyArr containsObject:stringID]) {
                [self.identifyArr addObject:stringID];
                [cell setupFilterWithModel:self.filterArr[indexPath.row]];
            }
            if (filterSeletedCell) {
                [filterSeletedCell setSelected:YES];
            }
        }
        return cell;
    }else{
        FFVideoFilterCell *cell = (FFVideoFilterCell*)[collectionView dequeueReusableCellWithReuseIdentifier:stringID forIndexPath:indexPath];
        
        if (self.wateMarkArr.count > 0){
            if (indexPath.row == 0) {
                if (waterMarkSeletedCell==nil) {
                    waterMarkSeletedCell = cell;
                }
            }
            if (![self.identifyWaterMarkArr containsObject:stringID]) {
                [self.identifyWaterMarkArr addObject:stringID];
                [cell setupWaterMarkWithModel:self.wateMarkArr[indexPath.row]];
            }
            if (waterMarkSeletedCell) {
                [waterMarkSeletedCell setSelected:YES];
            }
        }
        return cell;
    }
    
}
#pragma mark -
#pragma mark --- UICollectionViewDelegateFlowLayout
//如果这个偏移没有超过屏幕宽度减去itemsize ，那么列间距自动适应.总的来说是间距是不累加的
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    
//    return UIEdgeInsetsMake(5, 5, 0, 5);
    return UIEdgeInsetsMake(10, 10, 10, 10);
}
//列间距
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
//{
////    return 5;
//    return 10;
//}
//行间距
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
//{
//    return 10;
//}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self.spaceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.bgView);
    }];
    
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(20);
    }];
    [self.switchCameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.closeBtn);
        make.right.mas_equalTo(-20);
    }];
    [self.flashBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.closeBtn);
        make.right.mas_equalTo(self.switchCameraBtn.mas_left).offset(-40);
    }];

}

@end
