//
//  LLUPNPAction.h
//  CocoaAsyncSocket
//
//  Created by wilson on 2020/2/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,LLUPNPActionServerType) {
    
    LLUPNPActionServerTypeAVTransport,
    
    LLUPNPActionServerTypeRenderControl,
};

//控制动作对象
@interface LLUPNPAction : NSObject

/// 根据一个actionName初始化一个对象
/// @param actionName 动作名称
- (instancetype)initWithAction:(NSString *)actionName;

/// 添加子节点
/// @param value 值
/// @param key key
- (void)addChildParameterValue:(NSString *)value key:(NSString *)key;

/// 服务类型
@property (nonatomic,assign) LLUPNPActionServerType serverType;

/// 动作转为XML格式的字符串
@property (nonatomic,strong,readonly) NSString *actionXMLContent;

/// SOAP必有字段
@property (nonatomic,strong,readonly) NSString *SOAPContent;

@property (nonatomic,strong,readonly) NSString *actionName;

//设置当前url
+ (LLUPNPAction *)fetchAVTransportWithURL:(NSURL *)url;

//设置播放
+ (LLUPNPAction *)fetchPlayAction;

//设置暂停
+ (LLUPNPAction *)fetchPauseAction;

//设置停止
+ (LLUPNPAction *)fetchStopAction;

//设置声音
+ (LLUPNPAction *)fetchGetVolumeAction;

//设置声音
+ (LLUPNPAction *)fetchSetVolumeAction:(NSInteger)volume;

//设置进度
+ (LLUPNPAction *)fetchSetRealTimeAction:(NSString *)realTime;

//设置获取状态
+ (LLUPNPAction *)fetchGetStatusAction;

//设置获取进度
+ (LLUPNPAction *)fetchGetRealTimeAction;
@end

NS_ASSUME_NONNULL_END
