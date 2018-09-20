//
//  XJHViewController.m
//  XJHQRScanKit_Example
//
//  Created by xujunhao on 2018/9/19.
//  Copyright © 2018年 cocoadogs. All rights reserved.
//

#import "XJHViewController.h"
#import "SecondViewController.h"
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>

#define XJHQRScanKitImageNamed(name) [UIImage imageNamed:name inBundle:[NSBundle bundleWithURL:[[NSBundle bundleForClass:NSClassFromString(@"XJHQRScanView")] URLForResource:@"XJHQRScanKit" withExtension:@"bundle"]] compatibleWithTraitCollection:nil]

@interface XJHViewController ()

@property (nonatomic, strong) UIButton *nextBtn;
@property (nonatomic, strong) UIImageView *imgView;

@end

@implementation XJHViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	[self buildUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI Build Method

- (void)buildUI {
	self.view.backgroundColor = [UIColor whiteColor];
	self.navigationItem.title = @"YOYO";
	[self.view addSubview:self.imgView];
	[self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.center.equalTo(self.view);
		make.size.mas_equalTo(CGSizeMake(200, 200));
	}];
	[self.view addSubview:self.nextBtn];
	[self.nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
		make.center.equalTo(self.view);
		make.size.mas_equalTo(CGSizeMake(100, 40));
	}];
}

#pragma mark - Lazy Load Methods

- (UIButton *)nextBtn {
	if (!_nextBtn) {
		_nextBtn = [[UIButton alloc] init];
		[_nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
		[_nextBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
		[_nextBtn setBackgroundColor:[UIColor whiteColor]];
		_nextBtn.layer.cornerRadius = 5.0f;
		_nextBtn.layer.borderWidth = 0.5f;
		_nextBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
		@weakify(self)
		[[_nextBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
			@strongify(self)
            [self.navigationController pushViewController:[[SecondViewController alloc] init] animated:YES];
		}];
	}
	return _nextBtn;
}

- (UIImageView *)imgView {
	if (!_imgView) {
		_imgView = [[UIImageView alloc] init];
		_imgView.image = [XJHQRScanKitImageNamed(@"scan_net") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
		//		_netView.tintColor = [UIColor colorWithRed:41/255.0f green:108/255.0f blue:254/255.0f alpha:1.0];
		_imgView.tintColor = [UIColor redColor];
		_imgView.contentMode = UIViewContentModeScaleAspectFill;
		_imgView.clipsToBounds = YES;
	}
	return _imgView;
}

@end
