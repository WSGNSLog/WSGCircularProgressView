//
//  ViewController.m
//  WSGCircularProgressView
//
//  Created by wsg on 2017/1/6.
//  Copyright © 2017年 wsg. All rights reserved.
//

#import "ViewController.h"
#import "CircularProgressView.h"

@interface ViewController ()
@property (nonatomic, strong) NSTimer *updateTimer;
@property (nonatomic, weak) CircularProgressView *progressView;
@property (nonatomic, strong) UIView *coverView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:0.8];
    
    UIButton *startBtn = [[UIButton alloc]init];
    startBtn.frame = CGRectMake(100, 300, 50, 50);
    startBtn.backgroundColor = [UIColor cyanColor];
    [startBtn setTitle:@"start" forState:UIControlStateNormal];
    [startBtn addTarget:self action:@selector(startClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startBtn];
}

- (void)startClick{
    
    UIView *cover = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    cover.backgroundColor = [UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:0.3];
    CircularProgressView *progressView = [[CircularProgressView alloc]initWithFrame:CGRectMake(100, 100, 100, 100)];
    [cover addSubview:progressView];
    self.progressView = progressView;
    
    UIButton *stopBtn = [[UIButton alloc]init];
    stopBtn.frame = CGRectMake(150, 380, 50, 50);
    stopBtn.backgroundColor = [UIColor cyanColor];
    [stopBtn setTitle:@"cancel" forState:UIControlStateNormal];
    [stopBtn addTarget:self action:@selector(cancelClick) forControlEvents:UIControlEventTouchUpInside];
    [cover addSubview:stopBtn];
    [[UIApplication sharedApplication].keyWindow addSubview:cover];
    self.coverView = cover;
    [self performSelector:@selector(beginUpdatingProgressView) withObject:nil afterDelay:0];
}
- (void)beginUpdatingProgressView
{
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
}
- (void)updateProgress:(NSTimer *)timer
{
    if (self.progressView.progress+0.01 >=1) {
        [timer invalidate];
        [self cancelClick];
    } else {
        [self.progressView setProgress:self.progressView.progress + 0.01  animated:YES];
        self.progressView.centerLabel.text = [NSString stringWithFormat:@"%.02f%%", self.progressView.progress*100];
    }
}
- (void)cancelClick{
    [self.updateTimer invalidate];
    [self.coverView removeFromSuperview];
    self.coverView = nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
