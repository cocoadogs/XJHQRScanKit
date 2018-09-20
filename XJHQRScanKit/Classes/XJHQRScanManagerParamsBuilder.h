//
//  XJHQRScanManagerParamsBuilder.h
//  XJHQRScanKit
//
//  Created by xujunhao on 2018/9/18.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface XJHQRScanManagerParamsBuilder : NSObject

///二维码读取质量
@property (nonatomic, strong) AVCaptureSessionPreset sessionPreset;

///支持的条码类型
@property (nonatomic, copy) NSArray<AVMetadataObjectType> *metadataObjectTypes;

///扫描框距离页面顶部偏移，同XJHQRScanViewParamsBuilder的top
@property (nonatomic, assign) CGFloat top;

///透明扫描框size，默认大小宽高相等且等于屏幕宽度的0.7，同XJHQRScanViewParamsBuilder的transSize
@property (nonatomic, assign) CGSize transSize;

///扫码提示声音文件完整名称
@property (nonatomic, copy) NSString *soundName;


@end
