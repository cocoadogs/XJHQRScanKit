//
//  SecondViewController.m
//  XJHQRScanKit_Example
//
//  Created by xujunhao on 2018/9/19.
//  Copyright © 2018年 cocoadogs. All rights reserved.
//

#import "SecondViewController.h"
#import <XJHQRScanKit/XJHQRScanKit.h>
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>

@interface SecondViewController ()

@property (nonatomic, strong) XJHQRScanView *scanView;
@property (nonatomic, strong) XJHQRScanManager *scanManager;
@property (nonatomic, strong) UIButton *nextBtn;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	[self configScanManager];
	[self buildUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
	_scanManager = nil;
}

#pragma mark - Private Methods

- (void)buildUI {
	self.view.backgroundColor = [UIColor whiteColor];
	self.navigationItem.title = @"YOYO";
	[self.view addSubview:self.scanView];
    [self.view addSubview:self.nextBtn];
    [self.nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(100, 40));
    }];
    [self.scanView startAnimation];
}

- (void)configScanManager {
	[self.scanManager configWithViewController:self configuration:^(XJHQRScanManagerParamsBuilder *builder) {
        builder.transSize = CGSizeMake(200, 200);
        builder.top = 150;
	} brightnessNotification:^(CGFloat brightness) {
        if (brightness < -1) {
            NSLog(@"太黑了，开开灯吧");
        } 
	} resultNotification:^(NSString *code, NSError *error) {
		if (error) {
			NSLog(@"扫码发生错误 = %@", error);
		} else {
			NSLog(@"扫码结果 = %@", code);
		}
	}];
	[self.scanManager startScanning];
}

#pragma mark - Lazy Load Methods

- (XJHQRScanView *)scanView {
	if (!_scanView) {
		_scanView = [[XJHQRScanView alloc] initWithFrame:self.view.bounds configuration:^(XJHQRScanViewParamsBuilder *builder) {
			builder.transSize = CGSizeMake(200, 200);
			builder.lineLocation = XJHQRScanOutlineLocationOutside;
			builder.animateDuration = 0.02;
			builder.top = 150;
			builder.cornerWidth = 5.0f;
			builder.outlineWidth = 1.0f;
		}];
	}
	_scanView.center = self.view.center;
	return _scanView;
}

- (XJHQRScanManager *)scanManager {
	if (!_scanManager) {
		_scanManager = [[XJHQRScanManager alloc] init];
	}
	return _scanManager;
}

- (UIButton *)nextBtn {
    if (!_nextBtn) {
        _nextBtn = [[UIButton alloc] init];
        [_nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
        [_nextBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_nextBtn setBackgroundColor:[UIColor whiteColor]];
        _nextBtn.layer.cornerRadius = 5.0f;
        _nextBtn.layer.borderWidth = 0.5f;
        _nextBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
    return _nextBtn;
}

@end
