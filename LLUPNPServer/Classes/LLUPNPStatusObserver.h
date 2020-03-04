//
//  LLUPNPStatusObserver.h
//  CocoaAsyncSocket
//
//  Created by wilson on 2020/3/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,LLUPNPMediaStatus) {
    
    //停止
    LLUPNPMediaStatusStop,
    
    //正在投票中
    LLUPNPMediaStatusTransitioning,
    
    //播放
    LLUPNPMediaStatusPlaying,
    
    //暂停
    LLUPNPMediaStatusPause
};

@class LLUPNPStatusObserver;
@protocol LLUPNPStatusObserverDelegate <NSObject>

@optional

/// 当前进度回调
/// @param observer observr
/// @param duration 时长
/// @param realTime 进度字符串,如00:00:00
- (void)observer:(LLUPNPStatusObserver *)observer duration:(NSString *)duration realTime:(NSString *)realTime;

/// 当前进度回调
/// @param observer observer
/// @param schedule 进度，0-1
- (void)observer:(LLUPNPStatusObserver *)observer onSchedule:(CGFloat)schedule;

/// 返回播放状态
/// @param observer observer
/// @param state 状态
- (void)observer:(LLUPNPStatusObserver *)observer playState:(LLUPNPMediaStatus)state;
@end

/// 状态和进度管理
@interface LLUPNPStatusObserver : NSObject

- (instancetype)initWithURL:(NSURL *)url;

@property (nonatomic,strong,readonly) NSURL *url;
@property (nonatomic,weak) id <LLUPNPStatusObserverDelegate> delegate;

/// 比较当前播放url是否一样
/// @param url 播放url
- (BOOL)isPlayURL:(NSURL *)url;

/// 获取当前状态
/// @param successful 结果返回
- (void)fetchStatusSuccessful:(void(^)(LLUPNPMediaStatus status))successful;

- (void)start;
- (void)pause;
- (void)stop;
@end

NS_ASSUME_NONNULL_END
