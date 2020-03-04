//
//  NSString+LLUPNPAdd.m
//  CocoaAsyncSocket
//
//  Created by wilson on 2020/2/19.
//

#import "NSString+LLUPNPAdd.h"

@implementation NSString (LLUPNPAdd)

- (NSString *)valueForKey:(NSString *)key {
    
    __block NSString *value = nil;
    
    NSRange range = [self rangeOfString:key];
    if (range.location == NSNotFound) {
        return nil;
    }
    
    NSArray *array = [self componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    [array enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {

        NSString *string = [(NSString *)obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSRange range = [string rangeOfString:key];
        if (range.location != NSNotFound) {
            value = [string substringFromIndex:range.length+1];
            *stop = YES;
        }
    }];
    return [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (BOOL)isNumber {
    NSString *string = [self stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
    if(string.length > 0) {
        return NO;
    }
    return YES;
}

- (NSString *)convertDuration {
    
    NSArray *array = [self componentsSeparatedByString:@":"];
    NSInteger time = 0;
    if (array.count == 3) {
        
        NSInteger interval = 60 * 60;
        for (NSString *string in array) {
            if (![self isNumber]) {
                continue;
            }
            time += [string integerValue] * interval;
            interval /= 60;
        }
    }else if (array.count == 2) {
        
        NSInteger interval = 60 ;
        for (NSString *string in array) {
            if (![self isNumber]) {
                continue;
            }
            time += [string integerValue] * interval;
            interval /= 60;
        }
    }
    if (time == 0) {
        return nil;
    }
    return @(time).stringValue;
}

- (NSInteger)transportDuration {
    
    NSArray *array = [self componentsSeparatedByString:@":"];
    NSInteger time = 0;
    if (array.count == 3) {
        
        NSInteger interval = 60 * 60;
        for (NSString *string in array) {
            if (![string isNumber]) {
                continue;
            }
            time += [string integerValue] * interval;
            interval /= 60;
        }
    }else if (array.count == 2) {
        
        NSInteger interval = 60 ;
        for (NSString *string in array) {
            if (![string isNumber]) {
                continue;
            }
            time += [string integerValue] * interval;
            interval /= 60;
        }
    }
    return time;
}

+ (NSString *)convertDurationValueWithTime:(NSInteger)time {
    
    if (time == 0) {
        return nil;
    }
    
    NSInteger minute = 60;
    NSInteger hour = minute * minute;
    NSTimeInterval hourTime = time / hour;
    NSInteger hourMode = time % hour;
    NSTimeInterval minuteTime = hourMode / minute;
    NSTimeInterval second = hourMode % minute;
    
    NSString *hourString = [self _getTimeString:hourTime];
    NSString *minuteString = [self _getTimeString:minuteTime];
    NSString *secondString = [self _getTimeString:second];
    
    return [NSString stringWithFormat:@"%@:%@:%@",hourString,minuteString,secondString];
}

+ (NSString *)_getTimeString:(NSInteger)time {
    
    if (time < 10) {
        return [NSString stringWithFormat:@"0%ld",time];
    }
    return [NSString stringWithFormat:@"%ld",time];
}

@end
