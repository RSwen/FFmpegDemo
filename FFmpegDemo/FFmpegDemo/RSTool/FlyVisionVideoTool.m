//
//  ViewController.h
//  FFmpegDemo
//
//  Created by junfeng wang on 2018/5/8.
//  Copyright © 2018年 rswen. All rights reserved.
//

#import "FlyVisionVideoTool.h"
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libswscale/swscale.h>
#import "STMGLView.h"

@implementation FlyVisionVideoTool
{
    AVFormatContext    *pFormatCtx;
    int                videoindex;
    AVCodecContext    *pCodecCtx;
    AVCodec            *pCodec;
    AVPicture           picture;
    AVFrame             *XYQFrame;
    
    STMVideoFrameYUV   *videoFrameYUV;
    CGFloat videoW;
    CGFloat videoH;
}

#pragma mark 单例创建FlyVisionVideoTool

SRSINGLETONM(FlyVisionVideoTool)

- (void)displayImageWithPath:(NSString *)path videoSize:(CGSize)size {
   
    if (!videoFrameYUV) {
         videoFrameYUV = [[STMVideoFrameYUV alloc] init];
    }
    videoW=size.width;
    videoH=size.height;
    const char *filepath = [path UTF8String];
    
    av_register_all();
    avformat_network_init();
    pFormatCtx = avformat_alloc_context();
    pFormatCtx = avformat_alloc_context();
    AVDictionary* options = NULL;
    av_dict_set(&options, "rtsp_transport", "tcp", 0);
   int ret123 = avformat_open_input(&pFormatCtx, filepath, 0, &options);
    if(ret123 != 0) {
        printf("Couldn't open input stream.\n");
        exit(1);
    }
    
    if(avformat_find_stream_info(pFormatCtx, NULL) < 0) {
        printf("Couldn't find stream information.\n");
        exit(1);
    }
    
    videoindex = -1;
    for(int i = 0; i < pFormatCtx->nb_streams; i++)
        if(pFormatCtx->streams[i]->codec->codec_type == AVMEDIA_TYPE_VIDEO) {
            videoindex=i;
            break;
        }
    
    if(videoindex==-1) {
        printf("Didn't find a video stream.\n");
        exit(1);
    }
    
    pCodecCtx = pFormatCtx->streams[videoindex]->codec;
    pCodec = avcodec_find_decoder(pCodecCtx->codec_id);
    if(pCodec == NULL) {
        printf("Codec not found.\n");
        exit(1);
    }
    if(avcodec_open2(pCodecCtx, pCodec, NULL) < 0) {
        printf("Could not open codec.\n");
        exit(1);
    }
    
    AVFrame  *pFrameYUV;
    XYQFrame = av_frame_alloc();
    pFrameYUV = av_frame_alloc();
    
    int ret, got_picture;
    int y_size = pCodecCtx->width * pCodecCtx->height;
    
    AVPacket *packet=(AVPacket *)malloc(sizeof(AVPacket));
    av_new_packet(packet, y_size);
    
    printf("video infomation：\n");
    av_dump_format(pFormatCtx, 0, filepath, 0);
    
    while(av_read_frame(pFormatCtx, packet) >= 0) {
        if(packet->stream_index==videoindex) {
            ret = avcodec_decode_video2(pCodecCtx, XYQFrame, &got_picture, packet);
            if(ret < 0) {
                printf("Decode Error.\n");
                exit(1);
            }
            
            if(got_picture) {
                char *buf = (char *)malloc(XYQFrame->width * XYQFrame->height * 3 / 2);
                
                AVPicture *pict;
                int w, h;
                char *y, *u, *v;
                pict = (AVPicture *)XYQFrame;//这里的frame就是解码出来的AVFrame
                w = XYQFrame->width;
                h = XYQFrame->height;
                y = buf;
                u = y + w * h;
                v = u + w * h / 4;
                
                for (int i=0; i<h; i++)
                    memcpy(y + w * i, pict->data[0] + pict->linesize[0] * i, w);
                for (int i=0; i<h/2; i++)
                    memcpy(u + w / 2 * i, pict->data[1] + pict->linesize[1] * i, w / 2);
                for (int i=0; i<h/2; i++)
                    memcpy(v + w / 2 * i, pict->data[2] + pict->linesize[2] * i, w / 2);
                
                
                // 将得到的 i420 数据赋值给 videoFrameYUV 对象
                int yuvWidth, yuvHeight;
                void *planY, *planU, *planV;
                
                yuvWidth = XYQFrame->width;
                yuvHeight = XYQFrame->height;
                
                planY = buf;
                planU = buf + XYQFrame->width * XYQFrame->height;
                planV = buf + XYQFrame->width * XYQFrame->height * 5 / 4;
                
                videoFrameYUV.format = STMVideoFrameFormatYUV;
                videoFrameYUV.width = yuvWidth;
                videoFrameYUV.height = yuvHeight;
                videoFrameYUV.luma = planY;
                videoFrameYUV.chromaB = planU;
                videoFrameYUV.chromaR = planV;
                
                // 控制渲染速度
                if (!self.fps) {
                    self.fps=60;
                }
                usleep(1.0/self.fps);
                // 渲染 i420
                [self.stmGLView render:videoFrameYUV];
                
                free(buf);
            }
        }
        av_packet_unref(packet);
    }
    av_frame_free(&pFrameYUV);
    avcodec_close(pCodecCtx);
    avformat_close_input(&pFormatCtx);
}
#pragma mark - 获取当前图片

-(UIImage *)currentImage {
    if (!XYQFrame->data[0]) return nil;
    return [self imageFromAVPicture];
}

- (UIImage *)imageFromAVPicture
{
    avpicture_free(&picture);
    avpicture_alloc(&picture, AV_PIX_FMT_RGB24, videoW, videoH);
    
    struct SwsContext * imgConvertCtx = sws_getContext(XYQFrame->width,
                                                       XYQFrame->height,
                                                       AV_PIX_FMT_YUV420P,
                                                       videoW,
                                                       videoH,
                                                       AV_PIX_FMT_RGB24,
                                                       SWS_FAST_BILINEAR,
                                                       NULL,
                                                       NULL,
                                                       NULL);
    if(imgConvertCtx == nil) return nil;
    sws_scale(imgConvertCtx,
              XYQFrame->data,
              XYQFrame->linesize,
              0,
              XYQFrame->height,
              picture.data,
              picture.linesize);
    sws_freeContext(imgConvertCtx);
    
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CFDataRef data = CFDataCreate(kCFAllocatorDefault,
                                  picture.data[0],
                                  picture.linesize[0] * videoH);
    
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(data);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef cgImage = CGImageCreate(videoW,
                                       videoH,
                                       8,
                                       24,
                                       picture.linesize[0],
                                       colorSpace,
                                       bitmapInfo,
                                       provider,
                                       NULL,
                                       NO,
                                       kCGRenderingIntentDefault);
    
    
    
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    CGColorSpaceRelease(colorSpace);
    CGDataProviderRelease(provider);
    CFRelease(data);
    
    return image;
}

@end
