#import "QMNetworkInterfaceConfig.h"
#import "QuietModemKitPrivate.h"
#import <Foundation/Foundation.h>

@implementation QMNetworkInterfaceConfig

- (id)initWithTransmitterConfig:(QMTransmitterConfig *)txConf
             withReceiverConfig:(QMReceiverConfig *)rxConf {
  if (!txConf || !rxConf) {
    return nil;
  }

  self = [super init];
  if (!self) {
    return nil;
  }

  _txConf = txConf;
  _rxConf = rxConf;

  NSMutableData *addr = [NSMutableData dataWithLength:6];
  uint8_t *addr_bytes = [addr mutableBytes];
  addr_bytes[0] = 2;
  addr_bytes[0] |= (uint8_t)(arc4random_uniform(16) << 4);
  for (int i = 1; i < 6; i++) {
    addr_bytes[i] = (uint8_t)arc4random_uniform(256);
  }

  _hardwareAddress = [NSData dataWithData:addr];

  _localInetAddress = @"0.0.0.0";
  _localNetmask = @"0.0.0.0";
  _localGateway = @"0.0.0.0";

  return self;
}

@end
