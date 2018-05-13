#ifndef QuietModemKitPrivate_h
#define QuietModemKitPrivate_h

#import "QMFrameReceiver.h"
#import "QMNetworkInterfaceConfig.h"
#import "QMReceiverConfig.h"
#import "QMSocket.h"
#import "QMSocketAddress.h"
#import "QMTransmitterConfig.h"
#include "quiet.h"

@interface QMTransmitterConfig ()
@property quiet_encoder_options *opt;
@end

@interface QMReceiverConfig ()
@property quiet_decoder_options *opt;
@end

@interface QMFrameReceiver ()
- (void)onReceive:(NSData *)frame;
@end

@interface QMNetworkInterfaceConfig ()
@property(copy) QMTransmitterConfig *txConf;
@property(copy) QMReceiverConfig *rxConf;
@end

@interface QMSocketAddress ()
@property uint32_t ip;
@property NSUInteger port;
@end

@interface QMSocket ()
@property int lwip_fd;
+ (void)updateLastError;
@end

#endif /* QuietModemKitPrivate_h */
