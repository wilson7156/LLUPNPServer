//
//  LLUPNPAnonymousDevice.m
//  CocoaAsyncSocket
//
//  Created by wilson on 2020/2/19.
//

#import "LLUPNPAnonymousDevice.h"
#import <XMLDictionary/XMLDictionary.h>
#import "NSString+LLUPNPAdd.h"

NSString *const LLUPNPDeviceDidDismissNotifiation = @"LLUPNPDeviceDidDismissNotifiation";

@implementation LLUPNPDeviceServer

- (instancetype)initWithDict:(NSDictionary *)dict {
    
    self = [super init];
    if (self) {
        
        self.scpdURL = dict[@"SCPDURL"];
        self.controlURL = dict[@"controlURL"];
        self.eventSubURL = dict[@"eventSubURL"];
        self.serviceId = dict[@"serviceId"];
        self.serviceType = dict[@"serviceType"];
        
    }
    return self;
}

@end

@interface LLUPNPAnonymousDevice ()

@property (nonatomic,assign,readwrite) LLUPNPDeviceType deviceType;
@property (nonatomic,assign,readwrite) LLUPNPDeviceSubType subType;
@property (nonatomic,strong,readwrite) NSString *uuid;
@property (nonatomic,strong,readwrite) NSString *deviceId;
@property (nonatomic,strong,readwrite) NSString *deviceName;
@property (nonatomic,strong,readwrite) NSString *modelName;
@property (nonatomic,strong,readwrite) NSString *modeNumber;
@property (nonatomic,strong,readwrite) NSString *manufacturer;
@property (nonatomic,strong,readwrite) NSString *manufacturerURL;
@property (nonatomic,strong,readwrite) NSString *modelDescription;
@property (nonatomic,strong,readwrite) NSString *serialNumber;
@property (nonatomic,strong) NSString *deviceTypeString;
@property (nonatomic,strong) NSString *url;
@end

@implementation LLUPNPAnonymousDevice
@synthesize deviceType,subType,uuid,deviceId,deviceName,modelName,modeNumber,manufacturer,manufacturerURL,modelDescription,serialNumber;

- (instancetype)initWithXMLContent:(NSData *)xmlContent location:(nonnull NSString *)location {
    
    self = [super init];
    if (self) {
        
        self.url = location;
        [self _parseXMLWithContent:xmlContent];
    }
    return self;
}

- (void)_parseXMLWithContent:(NSData *)content {
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithXMLData:content];
    self->_xmlDict = dictionary;
    
    NSDictionary *deviceDict = dictionary[@"device"];
    NSString *udn = deviceDict[@"UDN"];
    if (udn) {
        self.uuid = [udn valueForKey:@"uuid"];
    }
    self.deviceTypeString = deviceDict[@"deviceType"];
    self.deviceId = deviceDict[@"friendlyNameId"];
    self.deviceName = deviceDict[@"friendlyName"];
    self.modelName = deviceDict[@"modelName"];
    self.modeNumber = deviceDict[@"modelNumber"];
    self.manufacturer = deviceDict[@"manufacturer"];
    self.manufacturerURL = deviceDict[@"manufacturerURL"];
    self.modelDescription = deviceDict[@"modelDescription"];
    self.serialNumber = deviceDict[@"serialNumber"];
    
    [self checkDeviceTypeWithList:deviceDict[@"serviceList"]];
}

- (void)checkDeviceTypeWithList:(NSDictionary *)listDict {
    
    NSArray *listArray = [listDict objectForKey:@"service"];
    NSMutableArray *array = [NSMutableArray new];
    
    if ([self.deviceTypeString containsString:@"MediaRenderer"]) {
        self.deviceType = LLUPNPDeviceTypeMediaServer;
    }
    
    LLUPNPDeviceSubType type = LLUPNPDeviceSubTypeNone;
    for (NSDictionary *dict in listArray) {
        
        LLUPNPDeviceServer *deviceServer = [[LLUPNPDeviceServer alloc] initWithDict:dict];
        [array addObject:deviceServer];
        
        if (self.deviceType == LLUPNPDeviceTypeMediaServer) {
            
            if ([deviceServer.serviceType containsString:@"AVTransport"]) {
                type |= LLUPNPDeviceSubTypeAVTransport;
                self->_AVTransportURL = [self.deviceURL stringByAppendingPathComponent:deviceServer.controlURL];
            }else if ([deviceServer.serviceType containsString:@"ConnectionManager"]) {
                type |= LLUPNPDeviceSubTypeConnectManager;
                
            }else if ([deviceServer.serviceType containsString:@"RenderingControl"]) {
                type |= LLUPNPDeviceSubTypeRenderingControl;
                self->_renderURL = [self.deviceURL stringByAppendingPathComponent:deviceServer.controlURL];
            }
        }
    }
    self.subType = type;
    if (array.count > 0) {
        self->_serviceArray = array;
    }
}

- (NSString *)deviceURL {
    
    NSURL *url = [NSURL URLWithString:self.url];
    NSString *urlString = [NSString stringWithFormat:@"%@://%@:%@",url.scheme,url.host,url.port.stringValue];;
    return urlString;
}

@end
