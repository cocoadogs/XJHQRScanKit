//
//  XJHQRScanManagerParamsBuilder.m
//  XJHQRScanKit
//
//  Created by xujunhao on 2018/9/18.
//

#import "XJHQRScanManagerParamsBuilder.h"

@implementation XJHQRScanManagerParamsBuilder

- (AVCaptureSessionPreset)sessionPreset {
	return _sessionPreset ?: [self defaultSessionPreset];
}

- (NSArray<AVMetadataObjectType> *)metadataObjectTypes {
	return _metadataObjectTypes ?: [self defaultMetadataObjectTypes];
}

- (NSString *)soundName {
	NSArray *componet = [_soundName componentsSeparatedByString:@"."];
	if (componet.count == 2) {
		NSString *extend = componet[1];
		if ([extend isEqualToString:@"caf"] || [extend isEqualToString:@"mp3"] || [extend isEqualToString:@"aac"] || [extend isEqualToString:@"m4a"] || [extend isEqualToString:@"m4r"] || [extend isEqualToString:@"wav"]) {
			return _soundName;
		}
	}
	return nil;
}

- (CGSize)transSize {
    CGFloat width = _transSize.width;
    CGFloat height = _transSize.height;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat length = width <= height ? width : height;
    BOOL ok  = (0 < width && width < screenWidth) && (0 < height && height < screenHeight);
    return ok ? CGSizeMake(length, length) : CGSizeMake(0.7 * screenWidth, 0.7 * screenWidth);
}

- (CGFloat)top {
    BOOL ok = 0 < _top && _top <= [UIScreen mainScreen].bounds.size.height / 2;
    CGFloat height = [[UIApplication sharedApplication] statusBarFrame].size.height + 44;
    return ok ? (_top + height) : (20.0f + height);
}

- (NSArray<AVMetadataObjectType> *)defaultMetadataObjectTypes {
	return @[AVMetadataObjectTypeQRCode];
}

- (AVCaptureSessionPreset)defaultSessionPreset {
	return AVCaptureSessionPreset1920x1080;
}


@end
