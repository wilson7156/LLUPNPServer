//
//  LLUPNPAction.m
//  CocoaAsyncSocket
//
//  Created by wilson on 2020/2/20.
//

#import "LLUPNPAction.h"
#import <KissXML/KissXML.h>

@interface LLUPNPAction ()

@property (nonatomic,strong) DDXMLElement *element;

@end

@implementation LLUPNPAction

+ (LLUPNPAction *)fetchAVTransportWithURL:(NSURL *)url {
    
    LLUPNPAction *action = [[LLUPNPAction alloc] initWithAction:@"SetAVTransportURI"];
    [action addChildParameterValue:@"0" key:@"InstanceID"];
    [action addChildParameterValue:url.absoluteString key:@"CurrentURI"];
    [action addChildParameterValue:@"" key:@"CurrentURIMetaData"];
    return action;
}

+ (LLUPNPAction *)fetchPlayAction {
    
    LLUPNPAction *action = [[LLUPNPAction alloc] initWithAction:@"Play"];
    [action addChildParameterValue:@"0" key:@"InstanceID"];
    [action addChildParameterValue:@"1" key:@"Speed"];
    return action;
}

+ (LLUPNPAction *)fetchPauseAction {
    
    LLUPNPAction *action = [[LLUPNPAction alloc] initWithAction:@"Pause"];
    [action addChildParameterValue:@"0" key:@"InstanceID"];
    [action addChildParameterValue:@"1" key:@"Speed"];
    return action;
}

+ (LLUPNPAction *)fetchStopAction {
    
    LLUPNPAction *action = [[LLUPNPAction alloc] initWithAction:@"Stop"];
    [action addChildParameterValue:@"0" key:@"InstanceID"];
    return action;
}

+ (LLUPNPAction *)fetchGetVolumeAction {
    
    LLUPNPAction *action = [[LLUPNPAction alloc] initWithAction:@"GetVolume"];
    action.serverType = LLUPNPActionServerTypeRenderControl;
    [action addChildParameterValue:@"0" key:@"InstanceID"];
    [action addChildParameterValue:@"Master" key:@"Channel"];
    return action;
}

+ (LLUPNPAction *)fetchSetVolumeAction:(NSInteger)volume {
    
    LLUPNPAction *action = [[LLUPNPAction alloc] initWithAction:@"SetVolume"];
    action.serverType = LLUPNPActionServerTypeRenderControl;
    [action addChildParameterValue:@"0" key:@"InstanceID"];
    [action addChildParameterValue:@"Master" key:@"Channel"];
    [action addChildParameterValue:@(volume).stringValue key:@"DesiredVolume"];
    return action;
}

+ (LLUPNPAction *)fetchSetRealTimeAction:(NSString *)realTime {
    
    LLUPNPAction *action = [[LLUPNPAction alloc] initWithAction:@"Seek"];
    [action addChildParameterValue:realTime key:@"Target"];
    [action addChildParameterValue:@"REL_TIME" key:@"Unit"];
    [action addChildParameterValue:@"0" key:@"InstanceID"];
    return action;
}

+ (LLUPNPAction *)fetchGetStatusAction {
    
    LLUPNPAction *action = [[LLUPNPAction alloc] initWithAction:@"GetTransportInfo"];
    [action addChildParameterValue:@"0" key:@"InstanceID"];
    return action;
}

+ (LLUPNPAction *)fetchGetRealTimeAction {
    
    LLUPNPAction *action = [[LLUPNPAction alloc] initWithAction:@"GetPositionInfo"];
    [action addChildParameterValue:@"0" key:@"InstanceID"];
    [action addChildParameterValue:@"" key:@"MediaDuration"];
    return action;
}

- (instancetype)initWithAction:(NSString *)actionName {
    
    self = [super init];
    if (self) {
        
        self->_actionName = actionName;
        
        NSString *elementString = [NSString stringWithFormat:@"u:%@",self.actionName];
        self.element = [DDXMLElement elementWithName:elementString];
    }
    return self;
}

- (void)addChildParameterValue:(NSString *)value key:(NSString *)key {
    
    DDXMLElement *children = [DDXMLElement elementWithName:key stringValue:value];
    [self.element addChild:children];
}

- (NSString *)actionXMLContent {
    
    //添加element节点
    DDXMLNode *node = [DDXMLNode attributeWithName:@"xmlns:u" stringValue:[self fetchServerType]];
    [self.element addAttribute:node];
    
    //添加必有字段
    DDXMLElement *element = [DDXMLElement elementWithName:@"s:Envelope"];
    DDXMLNode *encodingNode = [DDXMLNode attributeWithName:@"s:encodingStyle" stringValue:@"http://schemas.xmlsoap.org/soap/encoding/"];
    DDXMLNode *xmlnsNode = [DDXMLNode attributeWithName:@"xmlns:s" stringValue:@"http://schemas.xmlsoap.org/soap/envelope/"];
    [element addAttribute:encodingNode];
    [element addAttribute:xmlnsNode];
    
    DDXMLElement *bodyElement = [DDXMLElement elementWithName:@"s:Body"];
    [bodyElement addChild:self.element];
    
    [element addChild:bodyElement];
    return element.XMLString;
}

- (NSString *)SOAPContent {
    
    NSString *name = [NSString stringWithFormat:@"SOAPACTION: \"urn:schemas-upnp-org:service:%@:#%@\"",[self fetchServerType],self.actionName];
    return name;
}

- (NSString *)fetchServerType {
    
    if (self.serverType == LLUPNPActionServerTypeAVTransport) {
        return @"urn:schemas-upnp-org:service:AVTransport:1";
    }
    return @"urn:schemas-upnp-org:service:RenderingControl:1";
}



@end
