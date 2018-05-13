#import "QMReceiverConfig.h"
#import "QuietModemAudio.h"

#include "quiet.h"

@interface QuietReceiver : NSObject <QuietAudioConsumer>
- (id)initWithConfig:(quiet_decoder_options *)conf
      withSampleRate:(unsigned int)rate;
- (NSData *)receive;
- (size_t)receiveTo:(NSMutableData *)data;
- (void)setBlocking:(long)seconds withNano:(long)nano;
- (void)setNonBlocking;
- (void)close;
@end
