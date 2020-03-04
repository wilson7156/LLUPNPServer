//
//  LLUPNPDevice.m
//  CocoaAsyncSocket
//
//  Created by wilson on 2020/2/19.
//

#import "LLUPNPDevice.h"

@implementation LLUPNPDevice

- (NSString *)description {
    
    NSString *string = @"uuid:%@\r\n\
                        deviceId:%@\r\n\
                        deviceName:%@\r\n\
                        modelName:%@\r\n\
                        modelNumber:%@\r\n\
                        manufacturer:%@\r\n\
                        manufacturerURL:%@\r\n\
                        modelDescription:%@\r\n\
                        serialNumber:%@\r\n";
    return [NSString stringWithFormat:string,self.uuid,self.deviceId,self.deviceName,self.modelName,self.modeNumber,self.manufacturer,self.manufacturerURL,self.modelDescription,self.serialNumber];
}

@end
