//
//  LLUPNPDiscover.m
//  CocoaAsyncSocket
//
//  Created by wilson on 2020/2/19.
//

#import "LLUPNPDiscover.h"
#import <CocoaAsyncSocket/GCDAsyncUdpSocket.h>
#import "NSString+LLUPNPAdd.h"
#import "LLUPNPAnonymousDevice.h"
#import "LLUPNPDiscoverNotify.h"


//upnp固定广播地址
#define UPNP_HOST @"239.255.255.250"

//upnp固定端口
#define UPNP_PORT 1900

#define SEND_DISCOVER_TAG 100


//搜索可用的设备返回数据对象
@interface LLUPNPDiscoverRespone : NSObject

@property (nonatomic,strong) NSString *contentType;
@property (nonatomic,strong) NSString *server;
@property (nonatomic,strong) NSString* contentLength;
@property (nonatomic,strong) NSString *maxAge;
@property (nonatomic,strong) NSString *ext;
@property (nonatomic,strong) NSString *st;
@property (nonatomic,strong) NSString *usn;
@property (nonatomic,strong) NSString *location;

@end

@implementation LLUPNPDiscoverRespone

- (instancetype)initWithString:(NSString *)string {
    
    self = [super init];
    if (self) {
        
        self.contentType = [string valueForKey:@"Content-Type"];
        self.server = [string valueForKey:@"Server"];
        self.contentLength = [string valueForKey:@"Content-Length"];
        
        NSString *cacheControl = [string valueForKey:@"Cache-Control"];
        if (cacheControl) {
            
            NSArray *array = [cacheControl componentsSeparatedByString:@"="];
            self.maxAge = array.lastObject;
        }
        self.ext = [string valueForKey:@"EXT"];
        self.st = [string valueForKey:@"ST"];
        self.usn = [string valueForKey:@"USN"];
        self.location = [string valueForKey:@"Location"];
    }
    
    return self;
}
@end

@interface LLUPNPDiscover ()<GCDAsyncUdpSocketDelegate> {
    
    dispatch_source_t _timer;
    NSInteger _intervalTime;
    
}
//udp套接字
@property (nonatomic,strong) GCDAsyncUdpSocket *udpSocket;

//搜索到的数据返回缓存数组
@property (nonatomic,strong) NSMutableArray *responeArray;

//当前搜索到的设备数组
@property (nonatomic,strong) NSMutableArray *deviceArray;

//upnp网关定时发送的对象数据
@property (nonatomic,strong) LLUPNPDiscoverNotify *notify;

@end


@implementation LLUPNPDiscover

- (instancetype)initWithType:(LLUPNPDiscoverType)type name:(NSString * _Nullable)name {
    
    self = [super init];
    if (self) {
        
        self.userAgent = @"UPnP/1.0 LLUPNPServer/1.0";
        self->_timeout = 30;
        self->_type = type;
        self->_name = name;
        self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        
        
        
        self.responeArray = [NSMutableArray new];
        self.deviceArray = [NSMutableArray new];
    }
    return self;
}

- (void)discover {
    
    if (self->_timer) {
        return;
    }
    [self.deviceArray removeAllObjects];
    
    //停止上一次搜索
    [self _stopDiscover];
    
    //设置upd的配置
    NSError *error = nil;
    if (![self.udpSocket bindToPort:UPNP_PORT error:&error]) {
    }

    if (![self.udpSocket joinMulticastGroup:UPNP_HOST error:&error]) {
    }
        
    NSData *sendData = [[self _getDiscoverString] dataUsingEncoding:NSUTF8StringEncoding];
    [self.udpSocket sendData:sendData toHost:UPNP_HOST port:UPNP_PORT withTimeout:0 tag:SEND_DISCOVER_TAG];
    [self.udpSocket beginReceiving:nil];
}

- (void)stopDiscover {

    [self _stopDiscover];
    [self _callChangeState:LLUPNPDiscoverStateEnd];
    [self _stopTimer];
}


#pragma mark - AsyncUdpSocketDelegate
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    
    if (tag == SEND_DISCOVER_TAG) {
        [self _callChangeState:LLUPNPDiscoverStateBegin];
        [self _startTimer];
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    
    NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (!content) {
        return;
    }

#if DEBUG
    if (self.debug) {
        NSLog(@"---receive discover respone:\n%@---",content);
    }
#endif
    
    if ([content hasPrefix:@"NOTIFY"]) {
        
        //upnp网关设备定时发送Notify报文
        [self _parseNotify:content];
        
    }else if ([content hasPrefix:@"HTTP/1.1"]) {
        
        //搜索到设备
        [self _parseRespone:content];
    }
}

#pragma mark - Private
- (void)_stopDiscover {
    [self.udpSocket pauseReceiving];
}

/// 服务搜索目标
- (NSString *)_getSTString {
    
    if (self.type == LLUPNPDiscoverTypeAll) {
        return @"ssdp:all";
    }else if (self.type == LLUPNPDiscoverTypeUUID) {
        return [NSString stringWithFormat:@"uuid:%@",self.name];
    }else if (self.type == LLUPNPDiscoverTypeRootDevice) {
        return @"upnp:rootdevice";
    }else if (self.type == LLUPNPDiscoverTypeDevice) {
        return [NSString stringWithFormat:@"urn:schemas-upnp-org:device:%@",self.name];
    }else if (self.type == LLUPNPDiscoverTypeService) {
        return [NSString stringWithFormat:@"urn:schemas-upnp-org:service:%@",self.name];
    }
    return @"urn:schemas-upnp-org:service:AVTransport:1";
}

//搜索报文
- (NSString *)_getDiscoverString {
    
    NSString *discover = @"M-SEARCH * HTTP/1.1\r\n\
                         MAN: \"ssdp:discover\"\r\n\
                         MX: 5\r\n\
                         HOST:%@:%d\r\n\
                         ST:%@";
    NSString *string = [NSString stringWithFormat:discover,UPNP_HOST,UPNP_PORT,[self _getSTString]];
    if (self.userAgent) {
        string = [string stringByAppendingFormat:@"\r\nUser-Agent:%@",self.userAgent];
    }
    return string;
}

/*
 NOTIFY * HTTP/1.1

 HOST: 239.255.255.250:1900

 CACHE-CONTROL: max-age=60

 LOCATION: http://192.168.31.1:5351/rootDesc.xml

 SERVER: MiWiFi/x UPnP/1.1 MiniUPnPd/1.9

 NT: urn:schemas-upnp-org:device:InternetGatewayDevice:1

 USN: uuid:95e236e5-2ad0-4d4c-a161-6c25f2e9a7f1::urn:schemas-upnp-org:device:InternetGatewayDevice:1

 NTS: ssdp:alive

 OPT: "http://schemas.upnp.org/upnp/1/0/"; ns=01

 01-NLS: 1

 BOOTID.UPNP.ORG: 1

 CONFIGID.UPNP.ORG: 1337
 */
//解析Notify报文
- (void)_parseNotify:(NSString *)content {
    
    LLUPNPDiscoverNotify *notify = [[LLUPNPDiscoverNotify alloc] initWithString:content];
    if (!notify.isAlive) {
     
        //byebye报文,删除本地缓存对象
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uuid=%@",notify.uuid];
        NSArray *predicateArray = [self.deviceArray filteredArrayUsingPredicate:predicate];
        [self.deviceArray removeObjectsInArray:predicateArray];
        
        if (predicateArray.count > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(discover:willDismissDevice:)]) {
                    [self.delegate discover:self willDismissDevice:predicateArray.firstObject];
                }
            });
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:LLUPNP_NOTIICATION_NOTIFY_NAME object:notify];
}

/*
 HTTP/1.1 200 OK

 Content-Type: text/html; charset="utf-8"

 Server: Linux/2.6.35.13+ UPnP/1.0 CyberLinkJava/1.8

 Content-Length: 0

 Cache-Control: max-age=1800

 EXT:

 ST: urn:schemas-upnp-org:service:AVTransport:1

 USN: uuid:7cb23253caf8::urn:schemas-upnp-org:service:AVTransport:1

 Location: http://192.168.31.223:4004/description.xml
 */
//解析搜索到设备的报文信息
- (void)_parseRespone:(NSString *)content {
    
    LLUPNPDiscoverRespone *respone = [[LLUPNPDiscoverRespone alloc] initWithString:content];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"location=%@",respone.location];
    NSArray *predicateArray = [self.responeArray filteredArrayUsingPredicate:predicate];
    if (predicateArray.count == 0) {
        [self.responeArray addObject:respone];
    }
    
    //下载文件
    [self _downloadDeviceDescriptionWithRespone:respone];
}

//下载可用设备的描述文件
- (void)_downloadDeviceDescriptionWithRespone:(LLUPNPDiscoverRespone *)discoverRespone {
    
    if (!discoverRespone.location) {
        return;
    }
    dispatch_semaphore_t seamphore = dispatch_semaphore_create(0);
    NSURL *url = [NSURL URLWithString:discoverRespone.location];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
       
        if (error) {
            return;
        }
        
        if (!response || !data) {
            return;
        }
        
        NSHTTPURLResponse *httpRespone = (NSHTTPURLResponse *)response;
        if (httpRespone.statusCode != 200) {
            return;
        }
        
        //解析数据
        LLUPNPAnonymousDevice *device = [[LLUPNPAnonymousDevice alloc] initWithXMLContent:data location:discoverRespone.location];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uuid=%@",device.uuid];
        NSArray *predicateArray = [self.deviceArray filteredArrayUsingPredicate:predicate];
        if (predicateArray.count == 0) {
            [self.deviceArray addObject:device];
        }
        
        [self _stopTimer];
        [self _callDeviceArrayDelegate];
        
        dispatch_semaphore_signal(seamphore);
    }];
    
    [task resume];
    dispatch_semaphore_wait(seamphore, DISPATCH_TIME_FOREVER);
}


- (void)_callChangeState:(LLUPNPDiscoverState)state {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(discover:didChangeState:)]) {
            [self.delegate discover:self didChangeState:state];
        }
    });
}

- (void)_callDeviceArrayDelegate {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(discover:didDiscoverDevices:)]) {
            [self.delegate discover:self didDiscoverDevices:[self.deviceArray copy]];
        }
    });
}

- (void)_startTimer {
    
    if (!_timer) {
        
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
        dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 0.0 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(_timer, ^{
           
            if (self->_intervalTime > self.timeout) {
                
                [self _callChangeState:LLUPNPDiscoverStateTimeout];
                [self _stopTimer];
                
                if (self.autoDiscover) {
                    [self discover];
                }else {
                    [self _stopDiscover];
                }
            }
            self->_intervalTime++;
        });
    }
    dispatch_resume(self->_timer);
}

- (void)_stopTimer {
    
    if (_timer) {
        dispatch_cancel(_timer);
        self->_intervalTime = 0;
    }
    _timer = nil;
}

- (void)dealloc
{
    if (self.udpSocket) {
        [self.udpSocket enableReusePort:YES error:nil];
    }
}

@end
