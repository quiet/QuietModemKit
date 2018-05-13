#import "QuietReceiver.h"
#import "QuietModemKitPrivate.h"

@implementation QuietReceiver {
  quiet_decoder *decoder;
  NSMutableData *recvBuffer;
  dispatch_once_t closeOnce;
}

- (id)initWithConfig:(quiet_decoder_options *)conf
      withSampleRate:(unsigned int)rate {
  if (!conf) {
    return nil;
  }

  self = [super init];
  if (!self) {
    return nil;
  }

  decoder = quiet_decoder_create(conf, rate);
  if (!decoder) {
    return nil;
  }

  recvBuffer = [[NSMutableData alloc] initWithLength:4096];
  return self;
}

- (NSData *)receive {
  ssize_t written = quiet_decoder_recv(decoder, [recvBuffer mutableBytes],
                                       [recvBuffer length]);
  if (written > 0) {
    return [[NSData alloc]
        initWithData:[recvBuffer subdataWithRange:NSMakeRange(0, written)]];
  }
  return nil;
}

- (size_t)receiveTo:(NSMutableData*)data {
  ssize_t written = quiet_decoder_recv(decoder, [data mutableBytes], [data length]);
  
  if (written > 0) {
    return written;
  }
  return 0;
}

- (void)setBlocking:(long)seconds withNano:(long)nano {
  quiet_decoder_set_blocking(decoder, seconds, nano);
}

- (void)setNonBlocking {
  quiet_decoder_set_nonblocking(decoder);
}

- (ssize_t)consumeAudioFromSamples:(const float *)samples
                        withLength:(size_t)length {
  return quiet_decoder_consume(decoder, samples, length);
}

- (void)close {
  dispatch_once(&closeOnce, ^{
    quiet_decoder_close(decoder);
  });
}

- (void)dealloc {
  quiet_decoder_destroy(decoder);
}

@end
