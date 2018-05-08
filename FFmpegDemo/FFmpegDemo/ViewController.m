//
//  ViewController.m
//  FFmpegDemo
//
//  Created by junfeng wang on 2018/5/8.
//  Copyright © 2018年 rswen. All rights reserved.
//

#define videoW 1280
#define videoH 720
#define RTSPURL @""
#define RTSPURL1 @""

#import "ViewController.h"
#import "STMGLView.h"
#import "FlyVisionVideoTool.h"
@interface ViewController ()
@property(nonatomic,strong)STMGLView  *stmGLView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
}

-(void)createUI{
    
    [FlyVisionVideoTool shareFlyVisionVideoTool].stmGLView=self.stmGLView;
    [FlyVisionVideoTool shareFlyVisionVideoTool].fps=30;
    
    NSArray * titleArr=@[@"摄像头1",@"摄像头2"];
    
    for (int i=0; i<2; i++) {
        UIButton * btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame=CGRectMake(20, i*70+200, 100, 45);
        btn.tag=200+i;
        btn.backgroundColor=[UIColor orangeColor];
        [btn addTarget:self action:@selector(chooseVideoWithBtn:) forControlEvents:(UIControlEventTouchUpInside)];
        [btn setTitle:titleArr[i] forState:(UIControlStateNormal)];
        [self.view addSubview:btn];
    }
    
}

-(void)chooseVideoWithBtn:(UIButton *)btn123{
    UIButton * btn1=[self.view viewWithTag:200];
    btn1.hidden=YES;
    UIButton * btn2=[self.view viewWithTag:201];
    btn2.hidden=YES;
    switch (btn123.tag-200) {
        case 0:
        {
            dispatch_async(dispatch_queue_create(0, 0), ^{
                [[FlyVisionVideoTool shareFlyVisionVideoTool]displayImageWithPath:RTSPURL videoSize:CGSizeMake(videoW, videoH)];
            });
        }
            break;
            
        case 1:
        {
            dispatch_async(dispatch_queue_create(0, 0), ^{
                [[FlyVisionVideoTool shareFlyVisionVideoTool]displayImageWithPath:RTSPURL1 videoSize:CGSizeMake(videoW, videoH)];
            });
        }
            break;
            
            
        default:
            break;
    }
    
}

#pragma mark - 懒加载控件
-(STMGLView *)stmGLView{
    if (!_stmGLView) {
        _stmGLView = [[STMGLView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) videoFrameSize:CGSizeMake(videoW, videoH) videoFrameFormat:STMVideoFrameFormatYUV];
        [self.view addSubview:_stmGLView];
    }
    return _stmGLView;
}


@end

