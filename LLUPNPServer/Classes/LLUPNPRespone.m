//
//  LLUPNPRespone.m
//  CocoaAsyncSocket
//
//  Created by wilson on 2020/2/20.
//

#import "LLUPNPRespone.h"
#import <XMLDictionary/XMLDictionary.h>

@interface LLUPNPRespone ()

@property (nonatomic,strong) NSString *actionName;
@property (nonatomic,strong) NSDictionary *resultDict;

@end

@implementation LLUPNPRespone

- (instancetype)initActionName:(NSString *)action responeXMLContent:(NSData *)data {
    
    self = [super init];
    if (self) {
        
        self->_actionName = action;
        NSDictionary *dict = [NSDictionary dictionaryWithXMLData:data];
        id bodyDict = [dict objectForKey:@"s:Body"];
        if ([bodyDict isKindOfClass:[NSArray class]]) {
            
            NSArray *array = (NSArray *)bodyDict;
            [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [self checkSuccess:obj];
            }];
            
        }else if ([bodyDict isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *resultDict = (NSDictionary *)bodyDict;
            [self checkSuccess:resultDict];
        }
    }
    return self;
}

- (void)checkSuccess:(NSDictionary *)dict {
    
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    NSString *value = [self.actionName stringByAppendingString:@"Response"];
    NSString *newValue = [NSString stringWithFormat:@"u:%@",value];
    self->_resultDict = dict[newValue];
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString *key, id  _Nonnull obj, BOOL * _Nonnull stop) {
       
        if ([key isEqualToString:newValue]) {
         
            self->_success = YES;
            *stop = YES;
            return;
        }
    }];
}

- (NSString *)fetchSuccessValueForKey:(NSString *)key {
    return [_resultDict objectForKey:key];
}

@end
