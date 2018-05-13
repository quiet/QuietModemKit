#import "QMTransmitterConfig.h"
#import "QuietModemAudio.h"
#include "quiet.h"
#import <Foundation/Foundation.h>

@interface QuietTransmitter : NSObject <QuietAudioProducer>
- (id)initWithConfig:(quiet_encoder_options *)conf
      withSampleRate:(unsigned int)rate;
- (void)send:(NSData *)frame;
- (void)setBlocking:(long)seconds withNano:(long)nano;
- (void)setNonBlocking;
- (size_t)clampFrameLen:(size_t)sampleLen;
- (size_t)getFrameLen;
- (void)close;
@end
