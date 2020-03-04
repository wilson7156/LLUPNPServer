//
//  LLUPNPDevice.h
//  CocoaAsyncSocket
//
//  Created by wilson on 2020/2/19.
//

#import <Foundation/Foundation.h>

//设备类型
typedef NS_OPTIONS(NSInteger, LLUPNPDeviceType) {
    
    LLUPNPDeviceTypeUnknow,
    
    //多媒体类型
    LLUPNPDeviceTypeMediaServer,
    
    //目录
    LLUPNPDeviceTypeContentDirectory
};

typedef NS_OPTIONS(NSInteger,LLUPNPDeviceSubType) {
    
    LLUPNPDeviceSubTypeNone,
    
    LLUPNPDeviceSubTypeAVTransport,
    
    LLUPNPDeviceSubTypeRenderingControl,
    
    LLUPNPDeviceSubTypeConnectManager
};

NS_ASSUME_NONNULL_BEGIN

@interface LLUPNPDevice : NSObject

///设备类型
@property (nonatomic,assign,readonly) LLUPNPDeviceType deviceType;

///设备子类型
@property (nonatomic,assign,readonly) LLUPNPDeviceType subType;

/// 当前设备uuid
@property (nonatomic,strong,readonly) NSString *uuid;

/// 设备id
@property (nonatomic,strong,readonly) NSString *deviceId;

/// 当前设备的名称
@property (nonatomic,strong,readonly) NSString *deviceName;

/// 设备型号名称
@property (nonatomic,strong,readonly) NSString *modelName;

/// 设备序号
@property (nonatomic,strong,readonly) NSString *modeNumber;

/// 制造商
@property (nonatomic,strong,readonly) NSString *manufacturer;

/// 制造商网址
@property (nonatomic,strong,readonly) NSString *manufacturerURL;

/// 型号信息
@property (nonatomic,strong,readonly) NSString *modelDescription;

/// 序列号
@property (nonatomic,strong,readonly) NSString *serialNumber;
@end

NS_ASSUME_NONNULL_END
