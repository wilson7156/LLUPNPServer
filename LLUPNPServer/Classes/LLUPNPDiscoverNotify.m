//
//  LLUPNPDiscoverNotify.m
//  CocoaAsyncSocket
//
//  Created by wilson on 2020/2/20.
//

#import "LLUPNPDiscoverNotify.h"

@implementation LLUPNPDiscoverNotify

- (instancetype)initWithString:(NSString *)string {
    
    self = [super init];
    if (self) {
        
        NSString *host = [string valueForKey:@"HOST"];
        if (host) {
            
            NSArray *hostArray = [host componentsSeparatedByString:@":"];
            self.host = hostArray.firstObject;
            if (hostArray.lastObject) {
                self.port = [hostArray.lastObject integerValue];
            }
        }
        
        NSString *cacheControl = [string valueForKey:@"Cache-Control"];
        if (cacheControl) {
            
            NSArray *array = [cacheControl componentsSeparatedByString:@"="];
            self.maxAge = array.lastObject;
        }
        self.location = [string valueForKey:@"LOCATION"];
        self.server = [string valueForKey:@"SERVER"];
        self.nt = [string valueForKey:@"NT"];
        self.usn = [string valueForKey:@"USN"];
        self.nts = [string valueForKey:@"NTS"];
        self.opt = [string valueForKey:@"OPT"];
        self.nls = [string valueForKey:@"01-NLS"];
        
        NSArray *usnArray = [self.usn componentsSeparatedByString:@":"];
        if (usnArray.count >= 2) {
            self.uuid = usnArray[1];
        }
    }
    return self;
}

- (BOOL)isAlive {
    return [self.nts containsString:@"alive"];
}

@end
