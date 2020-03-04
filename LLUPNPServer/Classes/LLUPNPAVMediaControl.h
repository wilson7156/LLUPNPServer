//
//  LLUPNPAVMediaControl.h
//  CocoaAsyncSocket
//
//  Created by wilson on 2020/3/1.
//

#import <Foundation/Foundation.h>
@class LLUPNPDevice;

//时间字符串定义，例如 00:00:00
typedef NSString *LLMediaRealTime NS_EXTENSIBLE_STRING_ENUM;

NS_ASSUME_NONNULL_BEGIN

//播放状态
typedef NS_ENUM(NSInteger,LLUPNPMediaControlState) {
    
    //正在播放
    LLUPNPMediaControlStatePlaying,
    
    //正在投屏中
    LLUPNPMediaControlStateTransporting,
    
    //暂停
    LLUPNPMediaControlStatePause,
    
    //播放结束
    LLUPNPMediaControlStateEnd,
};

@class LLUPNPAVMediaControl;
@protocol LLUPNPAVMediaControlDelegate <NSObject>

@optional

/// 播放状态改变时回调
/// @param control control
/// @param state 状态
- (void)mediaControl:(LLUPNPAVMediaControl *)control didChangeState:(LLUPNPMediaControlState)state;

/// 当前进度字符串回调
/// @param control control
/// @param realTime 时间字符串，如00:00:00
- (void)mediaControl:(LLUPNPAVMediaControl *)control onRealTime:(LLMediaRealTime)realTime;

@end

//音视频播放
@interface LLUPNPAVMediaControl : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/// 根据LLUPNPDevice和urls数组创建一个播放对象
/// @param device 播放设备
/// @param urls 播放j链接数组
+ (instancetype)controlWithDevice:(LLUPNPDevice *)device urls:(NSArray <NSURL *> *)urls;

/// 当前播放的设备
@property (nonatomic,strong,readonly) LLUPNPDevice *device;

/// 当前播放状态
@property (nonatomic,assign,readonly) LLUPNPMediaControlState status;

/// 当前播放链接
@property (nonatomic,strong,readonly) NSURL *currentURL;

/// 调试模式,默认YES
@property (nonatomic,assign) BOOL debug;

/// 当前时长,以秒单位,当state == LLUPNPMediaControlStatePlaying 可以获取,或者可以kvo获取
@property (nonatomic,assign) NSInteger duration;

/// 当前进度 0-1,在回调mediaControl:onRealTime 方法可以获取,或者可以kvo获取
@property (nonatomic,assign,readonly) CGFloat rate;

/// 设置音量，默认会随手机系统音量设置
@property (nonatomic,assign) CGFloat volume;

/// 是否开启音量随手机系统音量设置,默认是YES
@property (nonatomic,assign) BOOL autoSystemVolume;

/// 自动播放下一音视频,默认是NO
@property (nonatomic,assign) BOOL autoPlayNext;

/// 是否正在播放
@property (nonatomic,assign,readonly,getter=isPlaying) BOOL playing;

/// 是否已经暂停
@property (nonatomic,assign,readonly,getter=isPause) BOOL pause;

/// 是否已经停止
@property (nonatomic,assign,readonly,getter=isStop) BOOL stop;

 /// 代理
@property (nonatomic,weak) id<LLUPNPAVMediaControlDelegate> delegate;

/// 替换当前url
/// @param url url
- (void)replaceURL:(NSURL *)url;

/// 播放
- (void)play;

/// 暂停
- (void)pause;

/// 停止
- (void)stop;

/// 跳转到某一时间
/// @param realTime 时间字符串
- (void)seekToRealTime:(LLMediaRealTime)realTime;

/// 跳转到某一进度
/// @param rate 进度 0-1
- (void)seekToRate:(CGFloat)rate;
@end

NS_ASSUME_NONNULL_END
