#ifndef QMNetworkInterfaceConfig_h
#define QMNetworkInterfaceConfig_h

#import <Foundation/Foundation.h>

#import "QMReceiverConfig.h"
#import "QMTransmitterConfig.h"

@interface QMNetworkInterfaceConfig : NSObject
- (id)initWithTransmitterConfig:(QMTransmitterConfig *)txConf
             withReceiverConfig:(QMReceiverConfig *)rxConf;
@property(copy) NSData *hardwareAddress;
@property(copy) NSString *localInetAddress;
@property(copy) NSString *localNetmask;
@property(copy) NSString *localGateway;
@end

#endif /* QMNetworkInterfaceConfig_h */
