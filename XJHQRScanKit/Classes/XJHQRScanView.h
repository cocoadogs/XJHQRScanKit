//
//  XJHQRScanView.h
//  XJHQRScanKit
//
//  Created by xujunhao on 2018/9/17.
//  扫码中间框视图

#import <UIKit/UIKit.h>
#import "XJHQRScanViewParamsBuilder.h"

typedef void(^XJHQRScanViewConfiguration)(XJHQRScanViewParamsBuilder *builder);

@interface XJHQRScanView : UIView

- (instancetype)initWithFrame:(CGRect)frame
				configuration:(XJHQRScanViewConfiguration)configuration;

- (void)startAnimation;

- (void)stopAnimation;

@end
