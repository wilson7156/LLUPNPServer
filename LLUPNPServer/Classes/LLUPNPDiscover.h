//
//  LLUPNPDiscover.h
//  CocoaAsyncSocket
//
//  Created by wilson on 2020/2/19.
//

#import <Foundation/Foundation.h>
#import "LLUPNPDevice.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,LLUPNPDiscoverType) {
    
    //默认类型，搜索投屏类型
    LLUPNPDiscoverTypeDefault,
    
    //搜索所有设备和服务
    LLUPNPDiscoverTypeAll,
    
    //仅搜索网络中的根设备
    LLUPNPDiscoverTypeRootDevice,
    
    //查询UUID标示的设备
    LLUPNPDiscoverTypeUUID,
    
    //服务类型
    LLUPNPDiscoverTypeService,
    
    //设备类型
    LLUPNPDiscoverTypeDevice,
};

//搜索状态
typedef NS_ENUM(NSInteger,LLUPNPDiscoverState) {
    
    //开始搜索
    LLUPNPDiscoverStateBegin,
    
    //搜索结束
    LLUPNPDiscoverStateEnd,
    
    //搜索超时
    LLUPNPDiscoverStateTimeout
};

@class LLUPNPDiscover;
@protocol LLUPNPDiscoverDelegate <NSObject>

@optional
/// 当前搜索的状态
/// @param discover 当前搜索器对象
/// @param state    状态值
- (void)discover:(LLUPNPDiscover *)discover didChangeState:(LLUPNPDiscoverState)state;

/// 搜索结束时能搜索到设备
/// @param discover 当前搜索对象
/// @param devices 搜索到的可用的设备数组，多次调用可能会重复，需要筛选
- (void)discover:(LLUPNPDiscover *)discover didDiscoverDevices:(NSArray <LLUPNPDevice *> *)devices;

/// 可用的设备将要消失状态
/// @param discover 当前搜索对象
/// @param device 要消失的设备对象
- (void)discover:(LLUPNPDiscover *)discover willDismissDevice:(LLUPNPDevice *)device;
@end


///负责对服务进行发现处理，也就是搜索网络中可用的设备，并监听UPUP服务的Notify处理
@interface LLUPNPDiscover : NSObject

- (instancetype)init NS_UNAVAILABLE;

//设置搜索的userAgent,默认是 UPnP/1.0 LLUPNPServer/1.0
@property (nonatomic,strong) NSString *userAgent;

/// 如果搜索不到是否会自动搜索,默认为NO
@property (nonatomic,assign) BOOL autoDiscover;

/// 搜索超时时间,默认为30
@property (nonatomic,assign) NSTimeInterval timeout;

/// 当前搜索类型
@property (nonatomic,assign,readonly) LLUPNPDiscoverType type;

/// 类型指定的名称
@property (nonatomic,strong,readonly) NSString *name;

/// 代理
@property (nonatomic,weak) id <LLUPNPDiscoverDelegate> delegate;

/// 调试模式
@property (nonatomic,assign) BOOL debug;

/// 创建一个针对 LLUPNPDiscoverType 类型的搜索附近的可用设备
/// @param type 类型
/// @param name 类型指定的名称
/// 如果type = LLUPNPDiscoverTypeDefault,LLUPNPDiscoverTypeAll,LLUPNPDiscoverRootDevice类型，name设置为nil,内部也会自动忽略该字段
/// 如果type = LLUPNPDiscoverTypeUUID,则name设置需要搜索的UUID
- (instancetype)initWithType:(LLUPNPDiscoverType)type name:(NSString * _Nullable)name;

/// 开始搜索
- (void)discover;

/// 结束搜索
- (void)stopDiscover;
@end

NS_ASSUME_NONNULL_END
