//
//  ViewController.h
//  FFmpegDemo
//
//  Created by junfeng wang on 2018/5/8.
//  Copyright © 2018年 rswen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FlyVisionSingleton.h"
@class STMGLView;

@interface FlyVisionVideoTool : NSObject

@property(nonatomic,strong)STMGLView * stmGLView;

@property(nonatomic,assign)int fps;

SRSINGLETONH(FlyVisionVideoTool)

-(void)displayImageWithPath:(NSString *)path videoSize:(CGSize)size;

-(UIImage *)currentImage;

@end
