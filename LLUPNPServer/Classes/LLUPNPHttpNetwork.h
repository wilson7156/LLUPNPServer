//
//  LLUPNPHttpNetwork.h
//  CocoaAsyncSocket
//
//  Created by wilson on 2020/3/1.
//

#import <Foundation/Foundation.h>
#import "LLUPNPAction.h"
#import "LLUPNPRespone.h"


NS_ASSUME_NONNULL_BEGIN

@interface LLUPNPHttpNetwork : NSObject

//+ (instancetype)shareNetwork;

@property (nonatomic,assign) BOOL debug;

- (void)POSTWithURL:(NSURL *)url action:(LLUPNPAction *)action withRespone:(void(^)(LLUPNPRespone * respone))respone;

@end

NS_ASSUME_NONNULL_END
