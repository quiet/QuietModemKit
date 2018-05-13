#import "QMSocketAddress.h"
#import "QuietModemKitPrivate.h"

#import "QuietLwipInterface.h"

@implementation QMSocketAddress {
  NSUInteger _port;
}

+ (id)withIpAddress:(NSString *)ip {
  return [[self alloc] initWithIpAddress:ip];
}

+ (id)withIpAddress:(NSString *)ip withPort:(NSUInteger)port {
  return [[self alloc] initWithIpAddress:ip withPort:port];
}

+ (id)empty {
  return [[self alloc] init];
}

- (id)init {
  self = [super init];
  if (!self) {
    return nil;
  }

  _ip = 0;
  _port = 0;

  return self;
}

- (id)initWithIpAddress:(NSString *)ip {
  self = [self init];
  if (!self) {
    return nil;
  }

  [self setAddr:ip];

  return self;
}

- (id)initWithIpAddress:(NSString *)ip withPort:(NSUInteger)port {
  self = [self init];
  if (!self) {
    return nil;
  }

  [self setAddr:ip];
  _port = port;

  return self;
}

- (BOOL)isEqual:(id)object {
  if (![object isMemberOfClass:[QMSocketAddress class]]) {
    return NO;
  }

  QMSocketAddress *other = object;

  if ([other ip] != [self ip]) {
    return NO;
  }

  return [other port] == [self port];
}

- (NSString *)addr {
  return [QuietLwipInterface byteAddressToStr:_ip];
}

- (void)setAddr:(NSString *)addr {
  _ip = [QuietLwipInterface strAddressToBytes:addr];
}

@end
