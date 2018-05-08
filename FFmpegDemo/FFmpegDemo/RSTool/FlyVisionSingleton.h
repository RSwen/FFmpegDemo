//
//  ViewController.h
//  FFmpegDemo
//
//  Created by junfeng wang on 2018/5/8.
//  Copyright © 2018年 rswen. All rights reserved.
//


#define SRSINGLETONH(name) +(instancetype)share##name;

#define SRSINGLETONM(name) static id _instance;\
+(instancetype)allocWithZone:(struct _NSZone *)zone\
{\
static dispatch_once_t onceToken;\
dispatch_once(&onceToken, ^{\
_instance = [super allocWithZone:zone];\
});\
return _instance;\
}\
\
+(instancetype)share##name\
{\
return [[self alloc]init];\
}\
-(id)copyWithZone:(NSZone *)zone\
{\
return _instance;\
}\
\
-(id)mutableCopyWithZone:(NSZone *)zone\
{\
return _instance;\
}




