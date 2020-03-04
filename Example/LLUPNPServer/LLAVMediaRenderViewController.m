//
//  LLAVMediaRenderViewController.m
//  LLUPNPServer_Example
//
//  Created by wilson on 2020/2/25.
//  Copyright © 2020 704110362@qq.com. All rights reserved.
//

#import "LLAVMediaRenderViewController.h"
#import <LLUPNPServer/LLUPNPServer.h>

@interface LLAVMediaRenderViewController ()<LLUPNPAVMediaControlDelegate>

@property (nonatomic,strong) LLUPNPAVMediaControl *control;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *rateLabel;
@property (weak, nonatomic) IBOutlet UISlider *sliderView;

@end

@implementation LLAVMediaRenderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *urls = @[[NSURL URLWithString:@"http://192.168.31.80/zhi.mp3"],
    [NSURL URLWithString:@"http://192.168.31.80/you.mp3"],
    [NSURL URLWithString:@"http://192.168.31.80/01.mkv"]];
    
    self.control = [LLUPNPAVMediaControl controlWithDevice:self.device urls:urls];
    self.control.autoPlayNext = YES;
    self.control.delegate = self;
}

- (IBAction)playButtonClick:(id)sender {
    [self.control play];
}

- (IBAction)pauseButtonClick:(id)sender {
    [self.control pause];
}

- (IBAction)stopButtonClick:(id)sender {
    [self.control stop];
}

- (void)sliderValueChange {
    [self.control seekToRate:self.sliderView.value];
}

#pragma mark - LLUPNPAVMediaControlDelegate
- (void)mediaControl:(LLUPNPAVMediaControl *)control didChangeState:(LLUPNPMediaControlState)state {
    
    if (state == LLUPNPMediaControlStatePlaying) {
        NSLog(@"开始播放......");
        NSLog(@"当前视频总时长:%ld",control.duration);
    }else if (state == LLUPNPMediaControlStatePause) {
        NSLog(@"已经暂停......");
    }else if (state == LLUPNPMediaControlStateTransporting) {
        NSLog(@"正在投屏中.....");
    }else if (state == LLUPNPMediaControlStateEnd) {
        NSLog(@"播放结束......");
    }
}

- (void)mediaControl:(LLUPNPAVMediaControl *)control onRealTime:(LLMediaRealTime)realTime {
    NSLog(@"当前播放时间:%@,当前进度:%f",realTime,control.rate);
    
    self.sliderView.value = control.rate;
    self.durationLabel.text = [NSString convertDurationValueWithTime:control.duration];
    self.rateLabel.text = realTime;
    
}
@end
