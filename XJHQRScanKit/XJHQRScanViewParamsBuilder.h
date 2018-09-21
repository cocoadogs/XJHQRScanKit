//
//  XJHQRScanViewParamsBuilder.h
//  XJHQRScanKit
//
//  Created by xujunhao on 2018/9/18.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

///边框框线位置
typedef NS_ENUM(NSUInteger, XJHQRScanOutlineLocation) {
	///默认与矩形边角同中心点
	XJHQRScanOutlineLocationDefault = 0,
	///在矩形边角内侧
	XJHQRScanOutlineLocationInside,
	///在矩形边角外侧
	XJHQRScanOutlineLocationOutside
};

@interface XJHQRScanViewParamsBuilder : NSObject

///边框框线位置
@property (nonatomic, assign) XJHQRScanOutlineLocation lineLocation;
///扫描框距离页面顶部偏移
@property (nonatomic, assign) CGFloat top;
///透明扫描框size，默认大小宽高相等且等于屏幕宽度的0.7
@property (nonatomic, assign) CGSize transSize;
///边框框线颜色，默认whiteColor
@property (nonatomic, strong) UIColor *outlineColor;
///边框四个边角颜色
@property (nonatomic, strong) UIColor *cornerColor;
///扫码网格tintColor
@property (nonatomic, strong) UIColor *tintColor;
///边框框线线宽，默认0.5f
@property (nonatomic, assign) CGFloat outlineWidth;
///边框边角线宽，默认1.0f
@property (nonatomic, assign) CGFloat cornerWidth;
///边框边角线长，默认20
@property (nonatomic, assign) CGFloat cornerLength;
///扫码动画时间间隔，默认0.02s
@property (nonatomic, assign) NSTimeInterval animateDuration;
///背景透明度，默认为0.5f
@property (nonatomic, assign) CGFloat bgAlpha;

@end
