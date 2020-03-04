//
//  LLUPNPAnonymousDevice.h
//  CocoaAsyncSocket
//
//  Created by wilson on 2020/2/19.
//

#import "LLUPNPDevice.h"

extern NSString * _Nullable const LLUPNPDeviceDidDismissNotifiation;
NS_ASSUME_NONNULL_BEGIN

#define LLUPNP_NOTIICATION_NOTIFY_NAME @"LLUPNP_NOTIICATION_NOTIFY_NAME"

//设备服务类型
@interface LLUPNPDeviceServer: NSObject

@property (nonatomic,strong) NSString *scpdURL;
@property (nonatomic,strong) NSString *controlURL;
@property (nonatomic,strong) NSString *eventSubURL;
@property (nonatomic,strong) NSString *serviceId;
@property (nonatomic,strong) NSString *serviceType;

- (instancetype)initWithDict:(NSDictionary *)dict;
@end

//内部使用的设备对象
@interface LLUPNPAnonymousDevice : LLUPNPDevice

/// 根据xml数据初始化一个对象
/// @param xmlContent xml数据
- (instancetype)initWithXMLContent:(NSData *)xmlContent location:(NSString *)location;

//xml字典
@property (nonatomic,strong,readonly) NSDictionary *xmlDict;

//设备里的服务列表
@property (nonatomic,strong,readonly) NSArray *serviceArray;

//控制url
@property (nonatomic,strong,readonly) NSString *controlURL;

//已经拼接deviceURL
@property (nonatomic,strong,readonly) NSString *AVTransportURL;

@property (nonatomic,strong,readonly) NSString *renderURL;

//设备所在的ip地址,如http://192.168.31.1:1300
@property (nonatomic,strong,readonly) NSString *deviceURL;
@end

NS_ASSUME_NONNULL_END
