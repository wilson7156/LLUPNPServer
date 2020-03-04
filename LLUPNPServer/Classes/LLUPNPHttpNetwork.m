//
//  LLUPNPHttpNetwork.m
//  CocoaAsyncSocket
//
//  Created by wilson on 2020/3/1.
//

#import "LLUPNPHttpNetwork.h"



static LLUPNPHttpNetwork *_network = nil;
@interface LLUPNPHttpNetwork ()

@property (nonatomic,strong) NSURL *url;
@property (nonatomic,strong) NSOperationQueue *queue;

@end

@implementation LLUPNPHttpNetwork

//+ (instancetype)shareNetwork {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        _network = [LLUPNPHttpNetwork new];
//    });
//    return  _network;
//}

- (instancetype)init {
    
    self= [super init];
    if (self) {
        self.queue = [NSOperationQueue new];
        self.queue.maxConcurrentOperationCount = 1;
    }
    return self;
}

- (void)POSTWithURL:(NSURL *)url action:(LLUPNPAction *)action withRespone:(nonnull void (^)(LLUPNPRespone * _Nullable))responeBlock {
    
    [self.queue addOperationWithBlock:^{

        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = @"POST";
        [request addValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
        [request addValue:action.SOAPContent forHTTPHeaderField:@"SOAPAction"];
        request.HTTPBody = [action.actionXMLContent dataUsingEncoding:NSUTF8StringEncoding];
            
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

            if (error || !response || !data) {

                if (responeBlock) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        responeBlock(nil);
                    });
                }
                return;
            }

            NSHTTPURLResponse *httpRespone = (NSHTTPURLResponse *)response;
            if (httpRespone.statusCode != 200) {
                if (responeBlock) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        responeBlock(nil);
                    });
                }
                return;
            }

        #if DEBUG
            if (self.debug) {
                NSLog(@"XML:%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            }
        #endif
            LLUPNPRespone *upnpRespone = [[LLUPNPRespone alloc] initActionName:action.actionName responeXMLContent:data];
            if (responeBlock) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    responeBlock(upnpRespone);
                });
            }
        }];
        [task resume];
    }];
}
@end
