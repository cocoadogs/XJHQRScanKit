//
//  XJHQRScanManager.m
//  XJHQRScanKit
//
//  Created by xujunhao on 2018/9/18.
//

#import "XJHQRScanManager.h"
#import <ImageIO/ImageIO.h>

typedef void(^XJHQRScanPropertyChangeBlock)(AVCaptureDevice *device);

@interface XJHQRScanManager ()<AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, strong) XJHQRScanManagerParamsBuilder *builder;
@property (nonatomic, copy) XJHQRScanBrightnessNotification brightnessNotification;
@property (nonatomic, copy) XJHQRScanResultNotification resultNotification;

///扫码会话
@property (nonatomic, strong) AVCaptureSession *session;
///硬件
@property (nonatomic, strong) AVCaptureDevice *device;
///扫码视频流输出数据
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
///扫码视频流预览图层
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@end

@implementation XJHQRScanManager

#pragma mark - Life Cycle Method

- (void)dealloc {
	[self closeFlashLight];
	[_session stopRunning];
	_session = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:nil];
    NSLog(@"---XJHQRScanManager---dealloc---");
}

#pragma mark - Public Methods

- (void)configWithViewController:(UIViewController *)viewController
				   configuration:(XJHQRScanManagerConfiguration)configuration
		  brightnessNotification:(XJHQRScanBrightnessNotification)brightnessNotification
			  resultNotification:(XJHQRScanResultNotification)resultNotification {
	if (viewController == nil || configuration == nil) {
		NSException *excp = [NSException exceptionWithName:@"XJHQRScanManagerException" reason:@"viewController和configuration参数不能为空"  userInfo:nil];
		[excp raise];
	}
	self.viewController = viewController;
	!configuration?:configuration(self.builder);
	self.brightnessNotification = brightnessNotification;
	self.resultNotification = resultNotification;
	//1.获取摄像设备
	self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	
	//2.创建设备输流
	NSError *error = nil;
	AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
	if (error) {
		!self.resultNotification?:self.resultNotification(nil, error);
		return;
	}
	
	//3.创建数据输出流
	AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
	[metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
	
	//3(1).创建设备输出流:self.videoDataOutput
	//设置扫描范围（每一个取值0~1，默认为左上角  (0,0,1,1)这是默认值  全屏的 最大为1）
	//metadataOutput.rectOfInterest = CGRectMake(0.05, 0.2, 0.7, 0.6);
	
	//4.创建会话对象:self.session
	
	//5.添加设备输出流到会话对象
	[self.session addOutput:metadataOutput];
	
	//5(1).添加设备输出流到会话对象，与3(1)构成识别光线强弱
	[self.session addOutput:self.videoDataOutput];
	
	//6.添加设备输入流到会话对象
	[self.session addInput:deviceInput];
	
	//7.设置数据输出类型，需要将数据输出添加到会话后，才能指定元数据类型，否则会报错
	// 设置扫码支持的编码格式(如下设置条形码和二维码兼容)
	// @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code,  AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code]
	metadataOutput.metadataObjectTypes = self.builder.metadataObjectTypes;
    metadataOutput.rectOfInterest = [self calculateInterestRect];
	
	//8.添加视频流预览图层到目标视图控制器
	[viewController.view.layer insertSublayer:self.videoPreviewLayer atIndex:0];
	
	//9.设置相机自动对焦通知处理
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:self.device];
    
    //10.配置相机区域改变捕获通知使能监测
    [self configDeviceAreaChangeMonitor];
}

- (void)startScanning {
	//启动会话对象，开始扫码
	[self.session startRunning];
}

- (void)stopScanning {
	[self.session stopRunning];
}

- (void)scanQRCodeWithStaticImage:(UIImage *)image
			   resultNotification:(XJHQRScanResultNotification)resultNotification {
	self.resultNotification = resultNotification;
	//CIDetector(CIDetector可用于人脸识别)进行图片解析，从而使我们可以便捷的从相册中获取到二维码
	//声明一个 CIDetector，并设定识别类型 CIDetectorTypeQRCode
	//识别精度
	CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
	//取得识别结果
	NSArray<CIFeature *> *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
	if (features.count ==  0) {
		!self.resultNotification?:self.resultNotification(nil, [NSError errorWithDomain:NSCocoaErrorDomain code:500 userInfo:@{NSLocalizedDescriptionKey :@"无法识别二维码"}]);
	} else {
		NSString *code = @"";
		for (CIQRCodeFeature *feature in features) {
			if (feature.messageString) {
				code = [feature.messageString copy];
				break;
			}
		}
		if (code.length > 0) {
			!self.resultNotification?:self.resultNotification(code, nil);
		} else {
			!self.resultNotification?:self.resultNotification(nil, [NSError errorWithDomain:NSCocoaErrorDomain code:500 userInfo:@{NSLocalizedDescriptionKey :@"无法识别二维码"}]);
		}
	}
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate Method

- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
	if (metadataObjects.count > 0) {
		[self stopScanning];
		[self playSound];
		AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
		!self.resultNotification?:self.resultNotification(obj.stringValue, nil);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self startScanning];
        });
	}
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate Method

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
	CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
	NSDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary*)metadataDict];
	CFRelease(metadataDict);
	NSDictionary *exifMetadata = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
	CGFloat brightnessValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
	if (brightnessValue < -1) {
		!self.brightnessNotification?:self.brightnessNotification(brightnessValue);
	}
}


#pragma mmark - Private Method

- (void)playSound {
	NSString *audioFile = nil;
	if (self.builder.soundName) {
		audioFile = [[NSBundle mainBundle] pathForResource:self.builder.soundName ofType:nil];
	} else {
		audioFile = [[NSBundle bundleWithURL:[[NSBundle bundleForClass:NSClassFromString(@"XJHQRScanManager")] URLForResource:@"XJHQRScanKit" withExtension:@"bundle"]] pathForResource:@"scan_sound.caf" ofType:nil];
	}
	NSURL *fileUrl = [NSURL fileURLWithPath:audioFile];
	SystemSoundID soundID = 0;
	AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileUrl), &soundID);
	AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, soundCompleteCallback, NULL);
	AudioServicesPlaySystemSound(soundID); // 播放音效
}

void soundCompleteCallback(SystemSoundID soundID, void *clientData){
	
}

- (void)openFlashLight {
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    if ([captureDevice hasTorch]) {
        BOOL locked = [captureDevice lockForConfiguration:&error];
        if (locked) {
            captureDevice.torchMode = AVCaptureTorchModeOn;
            [captureDevice unlockForConfiguration];
        }
    }
}

- (void)closeFlashLight {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        [device setTorchMode:AVCaptureTorchModeOff];
        [device unlockForConfiguration];
    }
}

- (void)subjectAreaDidChange:(NSNotification *)notification {
	[self focusAtPoint:self.viewController.view.center];
}

- (void)focusAtPoint:(CGPoint)point{
	CGSize size = self.viewController.view.bounds.size;
	CGPoint focusPoint = CGPointMake(point.y / size.height ,1 - point.x/size.width );
	NSError *error = nil;
	//对cameraDevice进行操作前，需要先锁定，防止其他线程访问
	if ([self.device lockForConfiguration:&error]) {
		if (self.device.isFocusPointOfInterestSupported && [self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
			[self.device setFocusMode:AVCaptureFocusModeAutoFocus];
			[self.device setFocusPointOfInterest:focusPoint];
		}
		if (self.device.isExposurePointOfInterestSupported && [self.device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
			[self.device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
			[self.device setExposurePointOfInterest:focusPoint];
		}
		[self.device unlockForConfiguration];
	}
}

- (void)configDeviceAreaChangeMonitor {
    NSError *error = nil;
    if ([self.device lockForConfiguration:&error]) {
        self.device.subjectAreaChangeMonitoringEnabled = YES;
        [self.device unlockForConfiguration];
    } else {
        NSLog(@"设置设备属性过程发生错误，错误信息：%@",error.localizedDescription);
    }
}

- (CGRect)calculateInterestRect {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    CGFloat scanWidth = self.builder.transSize.width;
    CGFloat scanHeight = self.builder.transSize.height;
    CGFloat scanOriginX = screenWidth / 2 - scanWidth / 2;
    CGFloat scanOriginY = self.builder.top;
    return CGRectMake(scanOriginY / screenHeight, scanOriginX / screenWidth, scanHeight / screenHeight, scanWidth / screenWidth);
}

#pragma mark - Lazy Load Method

- (XJHQRScanManagerParamsBuilder *)builder {
	if (!_builder) {
		_builder = [[XJHQRScanManagerParamsBuilder alloc] init];
	}
	return _builder;
}

- (AVCaptureSession *)session {
	if (!_session) {
		_session = [[AVCaptureSession alloc] init];
		_session.sessionPreset = _builder.sessionPreset;
	}
	return _session;
}

- (AVCaptureVideoDataOutput *)videoDataOutput {
	if (!_videoDataOutput) {
		_videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
		[_videoDataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
	}
	return _videoDataOutput;
}

- (AVCaptureVideoPreviewLayer *)videoPreviewLayer {
	if (!_videoPreviewLayer) {
		_videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
		_videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
		_videoPreviewLayer.frame = [UIScreen mainScreen].bounds;
	}
	return _videoPreviewLayer;
}

@end
