//
//  XJHQRScanManager.h
//  XJHQRScanKit
//
//  Created by xujunhao on 2018/9/18.
//  扫码管理类

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "XJHQRScanManagerParamsBuilder.h"

typedef void(^XJHQRScanManagerConfiguration)(XJHQRScanManagerParamsBuilder *builder);
typedef void(^XJHQRScanBrightnessNotification)(CGFloat brightness);
typedef void(^XJHQRScanResultNotification)(NSString *code, NSError *error);

@interface XJHQRScanManager : NSObject

/**
 配置扫码管理

 @param viewController 需要配置扫码的视图控制器
 @param configuration 参数配置
 @param brightnessNotification 视频流亮度变化通知
 @param resultNotification 扫码结果通知
 */
- (void)configWithViewController:(UIViewController *)viewController
				   configuration:(XJHQRScanManagerConfiguration)configuration
		  brightnessNotification:(XJHQRScanBrightnessNotification)brightnessNotification
			  resultNotification:(XJHQRScanResultNotification)resultNotification;


/**
 开始扫码
 */
- (void)startScanning;

/**
 结束扫码
 */
- (void)stopScanning;

/**
 扫描静态图片获取二维码

 @param image 静态图片
 @param resultNotification 扫码结果通知
 */
- (void)scanQRCodeWithStaticImage:(UIImage *)image
			   resultNotification:(XJHQRScanResultNotification)resultNotification;

/**
 打开闪光灯
 */
- (void)openFlashLight;

/**
 关闭闪光灯
 */
- (void)closeFlashLight;

@end
