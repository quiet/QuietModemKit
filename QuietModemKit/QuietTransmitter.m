#import "QuietTransmitter.h"
#import "QuietModemKitPrivate.h"

@implementation QuietTransmitter {
  quiet_encoder *encoder;
  dispatch_once_t closeOnce;
}

- (id)initWithConfig:(quiet_encoder_options *)conf
      withSampleRate:(float)rate {
  if (!conf) {
    return nil;
  }

  self = [super init];
  if (!self) {
    return nil;
  }

  encoder = quiet_encoder_create(conf, rate);
  if (!encoder) {
    return nil;
  }

  return self;
}

- (void)send:(NSData *)frame {
  quiet_encoder_send(encoder, frame.bytes, frame.length);
}

- (void)setBlocking:(long)seconds withNano:(long)nano {
  quiet_encoder_set_blocking(encoder, seconds, nano);
}

- (void)setNonBlocking {
  quiet_encoder_set_nonblocking(encoder);
}

- (size_t)clampFrameLen:(size_t)sampleLen {
  return quiet_encoder_clamp_frame_len(encoder, sampleLen);
}

- (size_t)getFrameLen {
  return quiet_encoder_get_frame_len(encoder);
}

- (ssize_t)produceAudioToSamples:(float *)samples withLength:(size_t)length {
  return quiet_encoder_emit(encoder, samples, length);
}

- (void)close {
  dispatch_once(&closeOnce, ^{
    quiet_encoder_close(encoder);
  });
}

- (void)dealloc {
  quiet_encoder_destroy(encoder);
}

@end
