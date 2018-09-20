//
//  XJHQRScanView.m
//  XJHQRScanKit
//
//  Created by xujunhao on 2018/9/17.
//

#import "XJHQRScanView.h"
#import <ReactiveObjC/ReactiveObjC.h>

#define XJHQRScanKitImageNamed(name) [UIImage imageNamed:name inBundle:[NSBundle bundleWithURL:[[NSBundle bundleForClass:NSClassFromString(@"XJHQRScanView")] URLForResource:@"XJHQRScanKit" withExtension:@"bundle"]] compatibleWithTraitCollection:nil]

@interface UIView (XJHQRScan)

@property (nonatomic, assign) CGFloat qr_y;

@end

@implementation UIView (XJHQRScan)

- (void)setQr_y:(CGFloat)qr_y {
	CGFloat x = self.frame.origin.x;
	CGFloat width = self.frame.size.width;
	CGFloat height = self.frame.size.height;
	self.frame = CGRectMake(x, qr_y, width, height);
}

- (CGFloat)qr_y {
	return self.frame.origin.y;
}

@end

@interface NSTimer (XJHQRScan)

+ (NSTimer *)scheduledScanTimerWithTimeInterval:(NSTimeInterval)seconds block:(void (^)(NSTimer *timer))block repeats:(BOOL)repeats;

@end

@implementation NSTimer (XJHQRScan)

+ (NSTimer *)scheduledScanTimerWithTimeInterval:(NSTimeInterval)seconds block:(void (^)(NSTimer *timer))block repeats:(BOOL)repeats {
	return [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(_scan_ExecBlock:) userInfo:[block copy] repeats:repeats];
}

+ (void)_scan_ExecBlock:(NSTimer *)timer {
	if ([timer userInfo]) {
		void (^block)(NSTimer *timer) = (void (^)(NSTimer *timer))[timer userInfo];
		block(timer);
	}
}

@end

@interface XJHQRScanView ()

@property (nonatomic, assign) CGRect clearRect;
@property (nonatomic, strong) UIView *netContainer;
@property (nonatomic, strong) UIImageView *netImgView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) XJHQRScanViewParamsBuilder *builder;

@end

@implementation XJHQRScanView

#pragma mark - Init Method

- (instancetype)initWithFrame:(CGRect)frame
				configuration:(XJHQRScanViewConfiguration)configuration {
	if (self = [super initWithFrame:frame]) {
		!configuration?:configuration(self.builder);
		self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:self.builder.bgAlpha];
	}
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
	NSAssert(NO, @"请调用initWithFrame:configuration:方法初始化");
	return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	[self.netContainer addSubview:self.netImgView];
}

- (void)drawRect:(CGRect)rect {
//	[super drawRect:rect];
	
	CGFloat width = self.builder.transSize.width;
	CGFloat height = self.builder.transSize.height;
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	//设置整个扫描界面的背景颜色
	CGContextSetRGBFillColor(ctx, 0, 0, 0, self.builder.bgAlpha);
	CGContextFillRect(ctx, rect);
	
	//挖出中间的透明的扫描框
	self.clearRect = CGRectMake(self.frame.size.width / 2 - width / 2, self.builder.top, width, height);
	CGContextClearRect(ctx, self.clearRect);
	
	CGFloat x = self.clearRect.origin.x;
	CGFloat y = self.clearRect.origin.y;
    
    self.netContainer = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
    self.netContainer.backgroundColor = [UIColor clearColor];
    [self addSubview:self.netContainer];
    self.netContainer.clipsToBounds = YES;
    
	//画边框细线
	switch (self.builder.lineLocation) {
		case XJHQRScanOutlineLocationDefault:
		{
			//边框线设置
			UIBezierPath *borderPath = [UIBezierPath bezierPathWithRect:CGRectMake(x + self.builder.cornerWidth/2, y + self.builder.cornerWidth/2, width - self.builder.cornerWidth, height - self.builder.cornerWidth)];
			borderPath.lineCapStyle = kCGLineCapButt;
			borderPath.lineWidth = self.builder.outlineWidth;
			[self.builder.outlineColor set];
			[borderPath stroke];
		}
			break;
		case XJHQRScanOutlineLocationInside:
		{
			//边框线设置
			UIBezierPath *borderPath = [UIBezierPath bezierPathWithRect:CGRectMake(x + self.builder.cornerWidth, y + self.builder.cornerWidth, width - self.builder.cornerWidth * 2, height - self.builder.cornerWidth * 2)];
			borderPath.lineCapStyle = kCGLineCapButt;
			borderPath.lineWidth = self.builder.outlineWidth;
			[self.builder.outlineColor set];
			[borderPath stroke];
		}
			break;
		case XJHQRScanOutlineLocationOutside:
		{
			//边框线设置
			UIBezierPath *borderPath = [UIBezierPath bezierPathWithRect:CGRectMake(x, y, width, height)];
			borderPath.lineCapStyle = kCGLineCapButt;
			borderPath.lineWidth = self.builder.outlineWidth;
			[self.builder.outlineColor set];
			[borderPath stroke];
		}
			break;
		default:
			break;
	}

	//左上角小图标
	UIBezierPath *leftTopPath = [UIBezierPath bezierPath];
	leftTopPath.lineWidth = self.builder.cornerWidth;
	[self.builder.cornerColor set];
	[leftTopPath moveToPoint:CGPointMake(x + self.builder.cornerWidth / 2, y + self.builder.cornerLength + self.builder.cornerWidth)];
	[leftTopPath addLineToPoint:CGPointMake(x + self.builder.cornerWidth / 2, y + self.builder.cornerWidth / 2)];
	[leftTopPath addLineToPoint:CGPointMake(x + self.builder.cornerLength + self.builder.cornerWidth, y + self.builder.cornerWidth / 2)];
	[leftTopPath stroke];
	
	//左下角小图标
	UIBezierPath *leftBottomPath = [UIBezierPath bezierPath];
	leftBottomPath.lineWidth = self.builder.cornerWidth;
	[self.builder.cornerColor set];
	[leftBottomPath moveToPoint:CGPointMake(x + self.builder.cornerWidth / 2, y + height - self.builder.cornerWidth - self.builder.cornerLength)];
	[leftBottomPath addLineToPoint:CGPointMake(x + self.builder.cornerWidth / 2, y + height - self.builder.cornerWidth / 2)];
	[leftBottomPath addLineToPoint:CGPointMake(x + self.builder.cornerWidth + self.builder.cornerLength, y + height - self.builder.cornerWidth / 2)];
	[leftBottomPath stroke];
	
	//右下角小图标
	UIBezierPath *rightBottomPath = [UIBezierPath bezierPath];
	rightBottomPath.lineWidth = self.builder.cornerWidth;
	[self.builder.cornerColor set];
	[rightBottomPath moveToPoint:CGPointMake(x + width - self.builder.cornerWidth - self.builder.cornerLength, y + height - self.builder.cornerWidth / 2)];
	[rightBottomPath addLineToPoint:CGPointMake(x + width - self.builder.cornerWidth / 2, y + height - self.builder.cornerWidth / 2)];
	[rightBottomPath addLineToPoint:CGPointMake(x + width - self.builder.cornerWidth / 2, y + height - self.builder.cornerWidth - self.builder.cornerLength)];
	[rightBottomPath stroke];
	
	//右上角小图标
	UIBezierPath *rightTopPath = [UIBezierPath bezierPath];
	rightTopPath.lineWidth = self.builder.cornerWidth;
	[self.builder.cornerColor set];
	[rightTopPath moveToPoint:CGPointMake(x + width - self.builder.cornerWidth / 2, y + self.builder.cornerWidth + self.builder.cornerLength)];
	[rightTopPath addLineToPoint:CGPointMake(x + width - self.builder.cornerWidth / 2, y + self.builder.cornerWidth / 2)];
	[rightTopPath addLineToPoint:CGPointMake(x + width - self.builder.cornerWidth - self.builder.cornerLength, y + self.builder.cornerWidth / 2)];
	[rightTopPath stroke];
    [self sendSubviewToBack:self.netContainer];
}

#pragma mark - Life Cycle Method

- (void)dealloc {
	[_timer invalidate];
	_timer = nil;
	NSLog(@"---XJHQRScanView---dealloc---");
}

#pragma mark - Public Method

- (void)startAnimation {
    [self.netContainer addSubview:self.netImgView];
	[[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stopAnimation {
	[self.timer invalidate];
	self.timer = nil;
	[self.netImgView removeFromSuperview];
	self.netImgView = nil;
}

#pragma mark - Lazy Load Method

- (XJHQRScanViewParamsBuilder *)builder {
	if (!_builder) {
		_builder = [[XJHQRScanViewParamsBuilder alloc] init];
	}
	return _builder;
}

- (UIImageView *)netImgView {
	if (!_netImgView) {
		_netImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.builder.transSize.width, self.builder.transSize.height)];
		_netImgView.image = [XJHQRScanKitImageNamed(@"scan_net") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _netImgView.tintColor = self.builder.tintColor;
		_netImgView.contentMode = UIViewContentModeScaleAspectFill;
		_netImgView.clipsToBounds = YES;
	}
	return _netImgView;
}

- (NSTimer *)timer {
	if (!_timer) {
		@weakify(self)
		_timer = [NSTimer scheduledScanTimerWithTimeInterval:self.builder.animateDuration block:^(NSTimer *timer) {
			@strongify(self)
			static BOOL isOriginPosition = YES;
			if (isOriginPosition) {
				self.netImgView.qr_y = - self.builder.transSize.height;
				self.netImgView.alpha = 1;
				isOriginPosition = NO;
				[UIView animateWithDuration:self.builder.animateDuration animations:^{
					self.netImgView.qr_y += 2;
				} completion:nil];
			} else {
				if (self.netImgView.qr_y <= 0) {
					if (self.netImgView.qr_y == 0) {
						[self.timer setFireDate:[NSDate distantFuture]];
						[UIView animateWithDuration:0.25 animations:^{
							self.netImgView.alpha = 0;
						} completion:^(BOOL finished) {
							self.netImgView.qr_y = - self.builder.transSize.height;
							isOriginPosition = YES;
							[self.timer setFireDate:[NSDate date]];
						}];
					} else {
						[UIView animateWithDuration:self.builder.animateDuration animations:^{
							self.netImgView.qr_y += 2;
						} completion:nil];
					}
				} else {
					isOriginPosition = !isOriginPosition;
				}
			}
		} repeats:YES];
	}
	return _timer;
}

@end
