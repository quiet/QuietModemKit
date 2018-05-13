#import "QMNetworkInterface.h"
#import "QuietModemKitPrivate.h"

#import "DeviceAudioInput.h"
#import "DeviceAudioOutput.h"
#import "LoopbackAudioInput.h"
#import "LoopbackAudioOutput.h"
#import "QuietLwipInterface.h"

@implementation QMNetworkInterface {
  DeviceAudioInput *deviceInput;
  DeviceAudioOutput *deviceOutput;
  LoopbackAudioInput *loopbackInput;
  LoopbackAudioOutput *loopbackOutput;
  QuietLwipInterface *interface;
}

- (id)initWithConfig:(QMNetworkInterfaceConfig *)interfaceConfig {
  if (!interfaceConfig) {
    return nil;
  }

  self = [super init];
  if (!self) {
    return nil;
  }

  [QuietLwipInterface initializeQuietLwip];

  interface = [[QuietLwipInterface alloc] initWithConfig:interfaceConfig];

  if (!interface) {
    return nil;
  }

  deviceOutput = [[DeviceAudioOutput alloc] initWithProducer:interface withNumBuffers:3 withBufferLength:4096];

  if (!deviceOutput) {
    return nil;
  }

  deviceInput = [[DeviceAudioInput alloc] initWithConsumer:interface withNumBuffers:3 withBufferLength:4096];

  if (!deviceInput) {
    return nil;
  }

  return self;
}

- (id)initLoopbackWithConfig:(QMNetworkInterfaceConfig *)interfaceConfig {
  if (!interfaceConfig) {
    return nil;
  }

  self = [super init];
  if (!self) {
    return nil;
  }

  [QuietLwipInterface initializeQuietLwip];

  interface = [[QuietLwipInterface alloc] initWithConfig:interfaceConfig];

  if (!interface) {
    return nil;
  }

  loopbackOutput = [[LoopbackAudioOutput alloc] initWithProducer:interface];

  if (!loopbackOutput) {
    return nil;
  }

  loopbackInput = [[LoopbackAudioInput alloc] initWithConsumer:interface];

  if (!loopbackInput) {
    return nil;
  }

  return self;
}

- (NSString *)getLocalAddress {
  return [interface getLocalAddress];
}

- (NSString *)getNetmask {
  return [interface getNetmask];
}

- (NSString *)getGateway {
  return [interface getGateway];
}

- (void)close {
  [interface close];
}

- (void)dealloc {
  [interface close];
}

@end
