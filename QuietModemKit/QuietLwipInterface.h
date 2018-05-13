#import "QMNetworkInterfaceConfig.h"
#import "QuietModemAudio.h"
#import <Foundation/Foundation.h>

#include <quiet-lwip/quiet-lwip.h>

@interface QuietLwipInterface
    : NSObject <QuietAudioProducer, QuietAudioConsumer>
+ (void)initializeQuietLwip;
+ (quiet_lwip_ipv4_addr)strAddressToBytes:(NSString *)strAddr;
+ (NSString *)byteAddressToStr:(quiet_lwip_ipv4_addr)byteAddr;
- (id)initWithConfig:(QMNetworkInterfaceConfig *)conf;
- (NSString *)getLocalAddress;
- (NSString *)getNetmask;
- (NSString *)getGateway;
- (void)close;
@end
