#import "QMUdpSocket.h"
#import "QuietModemKitPrivate.h"

#include <quiet-lwip/lwip-socket.h>
#include <quiet-lwip/quiet-lwip.h>

@implementation QMUdpSocket

+ (id)udpSocket {
  return [[self alloc] init];
}

+ (id)udpSocketWithAddress:(QMSocketAddress *)addr {
  return [[self alloc] initWithAddress:addr];
}

- (id)init {
  self = [super init];
  if (!self) {
    return nil;
  }

  self.lwip_fd = lwip_socket(LWIP_AF_INET, LWIP_SOCK_DGRAM, 0);
  if (self.lwip_fd < 0) {
    return nil;
  }

  return self;
}

- (id)initWithAddress:(QMSocketAddress *)addr {
  self = [self init];
  if (!self) {
    return nil;
  }

  if (![self bind:addr]) {
    return nil;
  }

  return self;
}

- (int)recvData:(NSMutableData *)data
    fromAddress:(QMSocketAddress *__autoreleasing *)src {
  struct lwip_sockaddr_in from;
  lwip_socklen_t from_len = sizeof(from);
  int res = lwip_recvfrom(self.lwip_fd, [data mutableBytes], [data length], 0,
                          (struct lwip_sockaddr *)&from, &from_len);
  if (res > 0) {
    if (src != nil) {
      *src = [[QMSocketAddress alloc] init];
      [*src setIp:from.sin_addr.s_addr];
      [*src setPort:ntohs(from.sin_port)];
    }
    return res;
  }
  [[self class] updateLastError];
  return 0;
}

- (int)sendData:(NSData *)data toAddress:(QMSocketAddress *)dst {
  struct lwip_sockaddr_in remote;
  memset(&remote, 0, sizeof(remote));
  remote.sin_family = LWIP_AF_INET;
  remote.sin_port = htons((short)dst.port);
  remote.sin_addr.s_addr = dst.ip;

  int res = lwip_sendto(self.lwip_fd, [data bytes], [data length], 0,
                        (struct lwip_sockaddr *)&remote, sizeof(remote));

  if (res > 0) {
    return res;
  }
  [[self class] updateLastError];
  return 0;
}

@end
