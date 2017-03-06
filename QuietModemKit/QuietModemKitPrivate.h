#ifndef QuietModemKitPrivate_h
#define QuietModemKitPrivate_h

#include "QMTransmitterConfig.h"
#include "QMReceiverConfig.h"
#include "quiet.h"

@interface QMTransmitterConfig()
@property quiet_encoder_options *opt;
@end

@interface QMReceiverConfig()
@property quiet_decoder_options *opt;
@end

#endif /* QuietModemKitPrivate_h */
