//
//  XJHQRScanViewParamsBuilder.m
//  XJHQRScanKit
//
//  Created by xujunhao on 2018/9/18.
//

#import "XJHQRScanViewParamsBuilder.h"

@implementation XJHQRScanViewParamsBuilder

- (CGSize)transSize {
	CGFloat width = _transSize.width;
	CGFloat height = _transSize.height;
	CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
	CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
	CGFloat length = width <= height ? width : height;
	BOOL ok  = (0 < width && width < screenWidth) && (0 < height && height < screenHeight);
	return ok ? CGSizeMake(length, length) : CGSizeMake(0.7 * screenWidth, 0.7 * screenWidth);
}

- (UIColor *)tintColor {
    return _tintColor ? : [UIColor colorWithRed:41/255.0f green:108/255.0f blue:254/255.0f alpha:1.0];
}

- (UIColor *)outlineColor {
	return _outlineColor?:[UIColor colorWithRed:41/255.0f green:108/255.0f blue:254/255.0f alpha:1.0];
}

- (CGFloat)top {
	BOOL ok = 0 < _top && _top <= [UIScreen mainScreen].bounds.size.height / 2;
	CGFloat height = [[UIApplication sharedApplication] statusBarFrame].size.height + 44;
	return ok ? (_top + height) : (20.0f + height);
}

- (UIColor *)cornerColor {
	return _cornerColor?:[UIColor colorWithRed:41/255.0f green:108/255.0f blue:254/255.0f alpha:1.0];
}

- (CGFloat)outlineWidth {
	BOOL ok = 0 < _outlineWidth && _outlineWidth <= 2.0f;
	return ok ? _outlineWidth : 0.5f;
}

- (CGFloat)cornerWidth {
	BOOL ok = 0 < _cornerWidth && _cornerWidth <= 10.0f;
	return ok ? _cornerWidth : 1.0f;
}

- (CGFloat)cornerLength {
	BOOL ok = 0 < _cornerLength && _cornerLength <= 30.0f;
	return ok ? _cornerLength : 20.0f;
}

- (NSTimeInterval)animateDuration {
	BOOL ok  = 0 < _animateDuration && _animateDuration < 1;
	return ok ? _animateDuration : 0.01;
}

- (CGFloat)bgAlpha {
	BOOL ok = 0 < _bgAlpha && _bgAlpha < 1;
	return ok ? _bgAlpha : 0.5f;
}

@end
