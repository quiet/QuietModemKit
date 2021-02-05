#import "QMFrameReceiver.h"
#import "DeviceAudioInput.h"
#import "LoopbackAudioInput.h"
#import "QuietModemKitPrivate.h"
#import "QuietReceiver.h"

@interface QMFrameReceiver ()
@property(atomic) QMFrameReceiverCallback frameReceiverCallback;
@property(atomic) dispatch_queue_t callbackQueue;
@end

@implementation QMFrameReceiver {
  QuietReceiver *consumer;
  LoopbackAudioInput *loopback;
  DeviceAudioInput *device;
  NSThread *callbackThread;
}

- (id)initWithConfig:(QMReceiverConfig *)conf {
  if (!conf) {
    return nil;
  }

  self = [super init];
  if (!self) {
    return nil;
  }

  consumer =
      [[QuietReceiver alloc] initWithConfig:conf.opt withSampleRate:48000.f];
  if (!consumer) {
    return nil;
  }

  device = [[DeviceAudioInput alloc] initWithConsumer:consumer
                                       withNumBuffers:conf.numBuffers
                                     withBufferLength:conf.bufferLength];
  if (!device) {
    return nil;
  }

  self.frameReceiverCallback = nil;

  return self;
}

- (id)initLoopbackWithConfig:(QMReceiverConfig *)conf {
  if (!conf) {
    return nil;
  }

  self = [super init];
  if (!self) {
    return nil;
  }

  consumer =
      [[QuietReceiver alloc] initWithConfig:conf.opt withSampleRate:48000.f];
  if (!consumer) {
    return nil;
  }

  loopback = [[LoopbackAudioInput alloc] initWithConsumer:consumer];
  if (!loopback) {
    return nil;
  }

  self.frameReceiverCallback = nil;

  return self;
}

- (void)setReceiveCallback:(QMFrameReceiverCallback)callback {
  [self setReceiveCallback:callback onQueue:dispatch_get_main_queue()];
}

- (void)setReceiveCallback:(QMFrameReceiverCallback)callback
                   onQueue:(dispatch_queue_t)queue {
  self.frameReceiverCallback = callback;
  self.callbackQueue = queue;
  if (callbackThread == nil) {
    callbackThread = [[NSThread alloc] initWithBlock:^{
      [self setBlocking:0 withNano:0];
      while (true) {
        NSData *recv = [self receive];
        if (recv == nil) {
          return;
        }

        [self onReceive:recv];
      }
    }];
    [callbackThread start];
  }
}

- (NSData *)receive {
  return [consumer receive];
}

- (size_t)receiveTo:(NSMutableData *)data {
  return [consumer receiveTo:data];
}

- (void)onReceive:(NSData *)frame {
  dispatch_async(self.callbackQueue, ^{
    self.frameReceiverCallback(frame);
  });
}

- (void)setBlocking:(long)seconds withNano:(long)nano {
  [consumer setBlocking:seconds withNano:nano];
}

- (void)setNonBlocking {
  [consumer setNonBlocking];
}

- (void)close {
  [consumer close];
}

- (void)dealloc {
  [consumer close];
}

@end
