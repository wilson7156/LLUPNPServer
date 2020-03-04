//
//  NSString+LLUPNPAdd.h
//  CocoaAsyncSocket
//
//  Created by wilson on 2020/2/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (LLUPNPAdd)

/// 根据key获取value
/// @param key key
- (NSString *)valueForKey:(NSString *)key;

/// 判断是否数字
- (BOOL)isNumber;

/// 转换时长
// string格式如00:00:00
- (NSString *)convertDuration;

/// 时长字符串转换成数字，以秒为单位
/// 需要转换的字符串需要00:00:00格式
- (NSInteger)transportDuration;

/// 转换成时间
/// @param time 时间数字
+ (NSString *)convertDurationValueWithTime:(NSInteger)time;
@end

NS_ASSUME_NONNULL_END
