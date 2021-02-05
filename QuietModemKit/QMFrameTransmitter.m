#import <AudioToolbox/AudioQueue.h>
#import <CoreAudio/CoreAudioTypes.h>

#import "DeviceAudioOutput.h"
#import "LoopbackAudioOutput.h"
#import "QMFrameTransmitter.h"
#import "QuietModemKitPrivate.h"
#import "QuietTransmitter.h"

@implementation QMFrameTransmitter {
  QuietTransmitter *producer;
  DeviceAudioOutput *device;
  LoopbackAudioOutput *loopback;
}

- (id)initWithConfig:(QMTransmitterConfig *)conf {
  if (!conf) {
    return nil;
  }

  self = [super init];
  if (!self) {
    return nil;
  }

  producer =
      [[QuietTransmitter alloc] initWithConfig:conf.opt withSampleRate:48000.f];
  if (!producer) {
    return nil;
  }

  device = [[DeviceAudioOutput alloc] initWithProducer:producer
                                        withNumBuffers:conf.numBuffers
                                      withBufferLength:conf.bufferLength];
  if (!device) {
    return nil;
  }

  return self;
}

- (id)initLoopbackWithConfig:(QMTransmitterConfig *)conf {
  if (!conf) {
    return nil;
  }

  self = [super init];
  if (!self) {
    return nil;
  }

  producer =
      [[QuietTransmitter alloc] initWithConfig:conf.opt withSampleRate:48000.f];
  if (!producer) {
    return nil;
  }

  loopback = [[LoopbackAudioOutput alloc] initWithProducer:producer];
  if (!loopback) {
    return nil;
  }

  return self;
}

- (void)send:(NSData *)frame {
  [producer send:frame];
}

- (void)setBlocking:(long)seconds withNano:(long)nano {
  [producer setBlocking:seconds withNano:nano];
}

- (void)setNonBlocking {
  [producer setNonBlocking];
}

- (void)close {
  [producer close];
}

- (void)dealloc {
  [producer close];
}

@end
