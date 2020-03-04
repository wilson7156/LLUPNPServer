//
//  LLUPNPStatusObserver.m
//  CocoaAsyncSocket
//
//  Created by wilson on 2020/3/1.
//

#import "LLUPNPStatusObserver.h"
#import "LLUPNPAction.h"
#import "LLUPNPHttpNetwork.h"
#import "NSString+LLUPNPAdd.h"

@interface LLUPNPStatusObserver ()
{
    dispatch_source_t _timer;

    
    BOOL _isPlay;
}

@property (nonatomic,strong) NSString *currentPlayURL;
@property (nonatomic,strong) LLUPNPHttpNetwork *network;
@end

@implementation LLUPNPStatusObserver

- (instancetype)initWithURL:(NSURL *)url {
    
    self = [super init];
    if (self) {
        
        self->_url = url;
        self.network = [LLUPNPHttpNetwork new];
        [self _creatTimer];
    }
    return self;
}

- (void)start {
    
    if (!self->_timer) {
        return;
    }
    
    if (self->_isPlay) {
        return;
    }
    
    self->_isPlay = YES;
    dispatch_resume(self->_timer);
}

- (void)pause {
    self->_isPlay = NO;
    if (!self->_timer) {
        return;
    }
    dispatch_suspend(self->_timer);
}

- (void)stop {
    
    if (!self->_timer) {
        return;
    }
    self->_isPlay = NO;
    dispatch_cancel(self->_timer);
}

- (BOOL)isPlayURL:(NSURL *)url {
    return [self.currentPlayURL isEqualToString:url.absoluteString];
}

- (void)fetchStatusSuccessful:(void (^)(LLUPNPMediaStatus))successful {
    [self _fetchStatus:successful];
}

- (void)_creatTimer {
    
    if (!_timer) {
        self->_timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
        dispatch_source_set_timer(self->_timer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 0.0 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(self->_timer, ^{
           
            [self _fetchRealTime];
            [self _fetchStatus:nil];
        });
    }
}

- (void)_fetchRealTime {
    
    __weak typeof(self) _self = self;
    LLUPNPAction *action = [LLUPNPAction fetchGetRealTimeAction];
    [self.network POSTWithURL:self.url action:action withRespone:^(LLUPNPRespone * _Nonnull respone) {
        
        __strong typeof(_self) self = _self;
        if (!self->_timer) {
            return;
        }
        
        if (!respone.success) {
            return;
        }
        
        NSString *currentURL = [respone fetchSuccessValueForKey:@"TrackURI"];
        self->_currentPlayURL = currentURL;
        
        //获取音视频时长
        NSString *durationString = [respone fetchSuccessValueForKey:@"TrackDuration"];
        NSString *newDuration = [durationString stringByReplacingOccurrencesOfString:@":" withString:@""];
        NSTimeInterval duration = 0;
        if ([newDuration isNumber]) {
            duration = [newDuration doubleValue];
        }
        
        //获取当前进度时间
        //当前进度时间大于0
        NSString *realTime = [respone fetchSuccessValueForKey:@"RelTime"];
        if (!realTime) {
            return;
        }
        
        NSString *newTime = [realTime stringByReplacingOccurrencesOfString:@":" withString:@""];
        if ([newTime integerValue] <= 0) {
            return;
        }
        
        //当前进度
        CGFloat schedulue = [newTime integerValue] / duration;
        if (schedulue < 1) {
            
            if ([self.delegate respondsToSelector:@selector(observer:duration:realTime:)]) {
                [self.delegate observer:self duration:durationString realTime:realTime];
            }
        }
    }];
}

- (void)_fetchStatus:(void(^)(LLUPNPMediaStatus status))successful {
    
    LLUPNPAction *action = [LLUPNPAction fetchGetStatusAction];
    [self.network POSTWithURL:self.url action:action withRespone:^(LLUPNPRespone * _Nonnull respone) {
        
        if (!respone.success) {
            return;
        }
        
        NSString *statusString = [respone fetchSuccessValueForKey:@"CurrentTransportStatus"];
        if (![statusString.uppercaseString isEqualToString:@"OK"]) {
            return;
        }
        
        NSString *state = [respone fetchSuccessValueForKey:@"CurrentTransportState"];
        __block LLUPNPMediaStatus status = LLUPNPMediaStatusStop;
        if ([state.uppercaseString isEqualToString:@"NO_MEDIA_PRESENT"] ||
            [state.uppercaseString isEqualToString:@"STOPPED"]) {
            
            status = LLUPNPMediaStatusStop;
        }else if ([state.uppercaseString isEqualToString:@"PLAYING"]) {
            
            status = LLUPNPMediaStatusPlaying;
        }else if ([state.uppercaseString isEqualToString:@"TRANSITIONING"]) {
            
            status = LLUPNPMediaStatusTransitioning;
        }else if ([state.uppercaseString isEqualToString:@"PLAYBACK_PAUSED"] ||
                  [state.uppercaseString isEqualToString:@"PAUSED_PLAYBACK"]) {
            
            status = LLUPNPMediaStatusPause;
        }
        
        [self _callState:status];
        if (successful) {
            successful(status);
        }
    }];
}

- (void)_callState:(LLUPNPMediaStatus)status {
    
    if ([self.delegate respondsToSelector:@selector(observer:playState:)]) {
        [self.delegate observer:self playState:status];
    }
}

@end
