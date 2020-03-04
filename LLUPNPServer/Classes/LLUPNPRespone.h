//
//  LLUPNPRespone.h
//  CocoaAsyncSocket
//
//  Created by wilson on 2020/2/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//控制返回结果对象
@interface LLUPNPRespone : NSObject

/// 根据actionName和返回的xml数据生成Respone对象
/// @param action 控制字段
/// @param data xml数据
- (instancetype)initActionName:(NSString *)action responeXMLContent:(NSData *)data;

/// 是否成功
@property (nonatomic,assign,readonly) BOOL success;

@property (nonatomic,strong,readonly) NSString *error;

/// 返回成功的子节点的数据
/// @param key 节点
- (NSString *)fetchSuccessValueForKey:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
