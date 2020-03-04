//
//  LLUPNPAVMediaControl.m
//  CocoaAsyncSocket
//
//  Created by wilson on 2020/3/1.
//

#import "LLUPNPAVMediaControl.h"
#import "LLUPNPDevice.h"
#import "LLUPNPAnonymousDevice.h"
#import "LLUPNPStatusObserver.h"
#import "LLUPNPHttpNetwork.h"
#import "NSString+LLUPNPAdd.h"

NSString *AVSystemVolumeNotification = @"AVSystemController_SystemVolumeDidChangeNotification";
NSString *AVSystemVolumeParameterKey = @"AVSystemController_AudioVolumeNotificationParameter";


#ifndef LL_LOCK
#define LL_LOCK(lock) dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
#endif

#ifndef LL_UNLOCK
#define LL_UNLOCK(lock) dispatch_semaphore_signal(lock);
#endif

@interface LLUPNPAVMediaControl ()<LLUPNPStatusObserverDelegate> {
    
    BOOL _isStopOperation;
    NSInteger _playIndex;
    NSInteger _delayPlayInterval;
}

//当前设备
@property (nonatomic,strong) LLUPNPAnonymousDevice *anoymousDevice;

// 监听状态对象
@property (nonatomic,strong) LLUPNPStatusObserver *statusObserver;

@property (nonatomic,strong) NSArray *urls;
@property (nonatomic,strong) NSURL *transportURL;
@property (nonatomic,strong) NSURL *url;

@property (strong, nonatomic, nonnull) dispatch_semaphore_t stateLock;
@property (nonatomic,strong) LLUPNPHttpNetwork *network;

@end

@implementation LLUPNPAVMediaControl

+ (instancetype)controlWithDevice:(LLUPNPDevice *)device urls:(NSArray<NSURL *> *)urls {
    return [[LLUPNPAVMediaControl alloc] initWithDevice:device urls:urls];
}

- (instancetype)initWithDevice:(LLUPNPDevice *)device urls:(NSArray *)urls {
    
    self = [super init];
    if (self) {
        
        self->_delayPlayInterval = 2;
        self->_playIndex = 0;
        self->_isStopOperation = YES;
        self.stateLock = dispatch_semaphore_create(1);
        self->_urls = urls;
        self->_device = device;
        self->_url = urls.firstObject;
        self->_status = LLUPNPMediaControlStateEnd;
        self.debug = NO;
        self.network = [LLUPNPHttpNetwork new];
        self.autoSystemVolume = YES;
        
        if ([device isKindOfClass:[LLUPNPAnonymousDevice class]]) {
            self.anoymousDevice = (LLUPNPAnonymousDevice *)device;
        }
        
        NSURL *transportURL = [NSURL URLWithString:self.anoymousDevice.AVTransportURL];
        self.statusObserver = [[LLUPNPStatusObserver alloc] initWithURL:transportURL];
        self.statusObserver.delegate = self;
        [self.statusObserver start];
        
        self.transportURL = [NSURL URLWithString:self.anoymousDevice.AVTransportURL];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDidDismiss:) name:LLUPNPDeviceDidDismissNotifiation object:nil];
    }
    return self;
}

- (NSURL *)currentURL {
    return self.url;
}

- (void)setDebug:(BOOL)debug {
    _debug = debug;
    self.network.debug = debug;
}

- (void)setVolume:(CGFloat)volume {
    _volume = volume;
    [self _updateVolume:volume];
}

- (void)setAutoSystemVolume:(BOOL)autoSystemVolume {
    _autoSystemVolume = autoSystemVolume;
    
    if (autoSystemVolume) {
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChange:) name:AVSystemVolumeNotification object:nil];
    }else {
        
        [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVSystemVolumeNotification object:nil];
    }
}

- (BOOL)isPlaying {
    return self.status == LLUPNPMediaControlStatePlaying;
}

- (BOOL)isPause {
    return self.status == LLUPNPMediaControlStatePause;
}

- (BOOL)isStop {
    return self.status == LLUPNPMediaControlStateEnd;
}

- (void)replaceURL:(NSURL *)url {
    self->_url = url;
    [self _stopSuccessful:nil];
    [self play];
}

- (void)play {
    
    //先获取当前播放状态，如果是暂停的，则设置播放
    //如果是播放的，先停止当前的，再重新播放
    if (self.status == LLUPNPMediaControlStatePause) {
        [self _setPlayAction];
        return;
    }
    
    __weak typeof(self) _self = self;
    [self.statusObserver fetchStatusSuccessful:^(LLUPNPMediaStatus status) {
        
        __strong typeof(_self) self = _self;
        
        [self _stopSuccessful:^(BOOL success) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self->_delayPlayInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self _play];
            });
        }];
    }];
}

- (void)pause {
    
    if (self.status == LLUPNPMediaControlStatePlaying) {
        
        __weak typeof(self) _self = self;
        self->_isStopOperation = YES;
        LLUPNPAction *action = [LLUPNPAction fetchPauseAction];
        [self.network POSTWithURL:self.transportURL action:action withRespone:^(LLUPNPRespone * _Nullable respone) {
            
            __strong typeof(_self) self = _self;
            if (respone.success) {
                [self _callStatus:LLUPNPMediaControlStatePause withError:nil];
            }
        }];
    }
}

- (void)stop {
    [self _stopSuccessful:nil];
    [self _callStatus:LLUPNPMediaControlStateEnd withError:nil];
    [self.statusObserver pause];
}

- (void)seekToRealTime:(LLMediaRealTime)realTime {
    
    if (!realTime) {
        return;
    }
    
    if (self.duration == 0) {
        return;
    }
    
    LLUPNPAction *action = [LLUPNPAction fetchSetRealTimeAction:realTime];
    [self.network POSTWithURL:self.transportURL action:action withRespone:^(LLUPNPRespone * _Nonnull respone) {}];
}

- (void)seekToRate:(CGFloat)rate {
    
    if (self.duration <= 0) {
        return;
    }
    
    NSInteger time = rate * self.duration;
    NSString *seekTime = [NSString convertDurationValueWithTime:time];
    [self seekToRealTime:seekTime];
}

#pragma mark - Private Method
//设置url和播放
- (void)_play {
    
    self->_isStopOperation = NO;
    __weak typeof(self) _self = self;
    [self _setTransportURLWithSuccess:^(BOOL success) {
        __strong typeof(_self) self = _self;
        if (success) {
            [self _setPlayAction];
        }
    }];
}

//设置播放
- (void)_setPlayAction {
    
    __weak typeof(self) _self = self;
    LLUPNPAction *action = [LLUPNPAction fetchPlayAction];
    [self.network POSTWithURL:self.transportURL action:action withRespone:^(LLUPNPRespone * _Nonnull respone) {
        
        __strong typeof(_self) self = _self;
        if (!respone.success) {
            return;
        }
        if (self->_duration > 0) {
            [self _callStatus:LLUPNPMediaControlStatePlaying withError:nil];
        }
        [self.statusObserver start];
        self->_isStopOperation = NO;
    }];
}

//设置当前播放url
- (void)_setTransportURLWithSuccess:(void(^)(BOOL success))succesful {
    
    if (!self.url) {
        return;
    }
    
    LLUPNPAction *action = [LLUPNPAction fetchAVTransportWithURL:self.url];
    [self.network POSTWithURL:self.transportURL action:action withRespone:^(LLUPNPRespone * _Nonnull respone) {
        if (succesful) {
            succesful(respone.success);
        }
    }];
}

//设置停止播放
- (void)_stopSuccessful:(void(^)(BOOL success))successful {
    
    LLUPNPAction *action = [LLUPNPAction fetchStopAction];
    [self.network POSTWithURL:self.transportURL action:action withRespone:^(LLUPNPRespone * _Nonnull respone) {
        if (successful) {
            successful(respone.success);
        }
    }];
}

- (void)_callStatus:(LLUPNPMediaControlState)status withError:(NSError *)error {
    
    if (self->_status == status) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(mediaControl:didChangeState:)]) {
        [self.delegate mediaControl:self didChangeState:status];
    }
    self->_status = status;
}

- (void)_updateVolume:(CGFloat)volume {
    
    NSInteger v = volume * 100;
    LLUPNPAction *action = [LLUPNPAction fetchSetVolumeAction:v];
    NSURL *url = [NSURL URLWithString:self.anoymousDevice.renderURL];
    [self.network POSTWithURL:url action:action withRespone:^(LLUPNPRespone * _Nonnull respone) {}];
}

- (BOOL)_canPlayNext {
    
    if (!self.autoPlayNext) {
        return NO;
    }
    
    NSInteger index = self->_playIndex;
    index++;
    if (index >= self.urls.count) {
        return NO;
    }
    return YES;
}

- (void)playNext {
    
    NSInteger index = self->_playIndex;
    if (index >= self.urls.count) {
        return;
    }
    
    NSURL *url = self.urls[index];
    self->_playIndex = index;
    self->_url = url;
    [self play];
}

#pragma mark - NSNotification
- (void)volumeChange:(NSNotification *)notification {
    
    CGFloat volume = [[notification.userInfo objectForKey:AVSystemVolumeParameterKey] floatValue];
    self.volume = volume;
}

- (void)deviceDidDismiss:(NSNotification *)notification {
    if ([notification.object isKindOfClass:[NSString class]]) {
        
        NSString *uuid = notification.object;
        if (![uuid isEqualToString:self.device.uuid]) {
            return;
        }
        [self stop];
    }
}

#pragma mark - LLUPNPStatusObserverDelegate
- (void)observer:(LLUPNPStatusObserver *)observer playState:(LLUPNPMediaStatus)state {
    
    LL_LOCK(self.stateLock)
    if (state == LLUPNPMediaStatusPlaying) {}
    else if (state == LLUPNPMediaStatusStop) {
        
        if (self.duration > 0) {
            
            self->_duration = 0;
            //是否自动播放
            if (![self _canPlayNext] && self->_isStopOperation) {
                if (self.status != LLUPNPMediaControlStateEnd) {
                    [observer pause];
                }
                self->_delayPlayInterval = 2;
                [self _callStatus:LLUPNPMediaControlStateEnd withError:nil];
            }else {
                self->_delayPlayInterval = 0;
                self->_status = LLUPNPMediaControlStateEnd;
                [self playNext];
            }
        }
    }else if (state == LLUPNPMediaStatusTransitioning) {
        if (self.duration == 0) {
            [self _callStatus:LLUPNPMediaControlStateTransporting withError:nil];
        }
    }
    LL_UNLOCK(self.stateLock)
}

- (void)observer:(LLUPNPStatusObserver *)observer duration:(NSString *)duration realTime:(NSString *)realTime {
    
    if (self->_isStopOperation) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSInteger durationValue = [duration transportDuration];
        NSInteger realTimeValue = [realTime transportDuration];
        
        //计算进度
        CGFloat rate = realTimeValue / (CGFloat)durationValue;
        
        if (self.duration == 0) {
            [self willChangeValueForKey:@"duration"];
            self->_duration = durationValue;
            [self didChangeValueForKey:@"duration"];
            
            [self _callStatus:LLUPNPMediaControlStatePlaying withError:nil];
        }
        
        if (self.status == LLUPNPMediaControlStatePlaying) {
            
            if ([self.delegate respondsToSelector:@selector(mediaControl:onRealTime:)]) {
                [self.delegate mediaControl:self onRealTime:realTime];
            }
        }
        
        if (rate > 0) {
            [self willChangeValueForKey:@"rate"];
            self->_rate = rate;
            [self didChangeValueForKey:@"rate"];
        }
    });
}

- (void)dealloc
{
    [self.statusObserver stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
