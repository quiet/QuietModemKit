#ifndef QMNetworkInterface_h
#define QMNetworkInterface_h

#import "QMNetworkInterfaceConfig.h"

@interface QMNetworkInterface : NSObject
- (id)initWithConfig:(QMNetworkInterfaceConfig *)conf;
- (id)initLoopbackWithConfig:(QMNetworkInterfaceConfig *)conf;
- (NSString *)getLocalAddress;
- (NSString *)getNetmask;
- (NSString *)getGateway;
- (void)close;
@end

#endif /* QMNetworkInterface_h */
