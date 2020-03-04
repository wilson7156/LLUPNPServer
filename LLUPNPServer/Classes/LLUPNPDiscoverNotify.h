//
//  LLUPNPDiscoverNotify.h
//  CocoaAsyncSocket
//
//  Created by wilson on 2020/2/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//upnp网关设备定时发送的报文,内部类
@interface LLUPNPDiscoverNotify : NSObject

@property (nonatomic,strong) NSString *host;
@property (nonatomic,assign) NSInteger port;
@property (nonatomic,strong) NSString *maxAge;
@property (nonatomic,strong) NSString *location;
@property (nonatomic,strong) NSString *server;
@property (nonatomic,strong) NSString *nt;
@property (nonatomic,strong) NSString *usn;
@property (nonatomic,strong) NSString *nts;
@property (nonatomic,strong) NSString *opt;
@property (nonatomic,strong) NSString *nls;
@property (nonatomic,strong) NSString *uuid;

@property (nonatomic,assign) BOOL isAlive;


- (instancetype)initWithString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
