#import "QMTcpSocket.h"
#import "QuietModemKitPrivate.h"

#include <quiet-lwip/lwip-netdb.h>
#include <quiet-lwip/lwip-socket.h>
#include <quiet-lwip/quiet-lwip.h>

@implementation QMTcpSocket

static const int backlog = 4;

+ (id)tcpSocket {
  return [[self alloc] init];
}

+ (id)tcpSocketWithAddress:(QMSocketAddress *)addr {
  return [[self alloc] initWithAddress:addr];
}

- (id)init {
  self = [super init];
  if (!self) {
    return nil;
  }

  self.lwip_fd = lwip_socket(LWIP_AF_INET, LWIP_SOCK_STREAM, 0);
  if (self.lwip_fd < 0) {
    return nil;
  }

  return self;
}

- (id)initWithLwipFd:(int)fd {
  self = [super init];
  if (!self) {
    return nil;
  }

  self.lwip_fd = fd;
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

- (BOOL)listen {
  int res = lwip_listen(self.lwip_fd, backlog);
  if (res < 0) {
    [[self class] updateLastError];
    return NO;
  }

  return YES;
}

- (QMTcpSocket *)accept {
  struct lwip_sockaddr_in recv_from;
  lwip_socklen_t recv_from_len = sizeof(recv_from);
  int accept_fd = lwip_accept(self.lwip_fd, (struct lwip_sockaddr *)&recv_from,
                              &recv_from_len);

  if (accept_fd < 0) {
    [[self class] updateLastError];
    return nil;
  }

  return [[[self class] alloc] initWithLwipFd:accept_fd];
}

- (int)recvData:(NSMutableData *)data {
  int recv = lwip_read(self.lwip_fd, [data mutableBytes], [data length]);
  if (recv < 0) {
    [[self class] updateLastError];
  }
  return recv;
}

- (int)sendData:(NSData *)data {
  int sent = lwip_write(self.lwip_fd, [data bytes], [data length]);
  if (sent < 0) {
    [[self class] updateLastError];
  }
  return sent;
}

- (BOOL)getTcpNoDelay {
  int nodelay;
  lwip_socklen_t len = sizeof(nodelay);
  int res = lwip_getsockopt(self.lwip_fd, LWIP_SOL_SOCKET, LWIP_TCP_NODELAY,
                            &nodelay, &len);

  if (res < 0) {
    [[self class] updateLastError];
    return NO;
  }

  return nodelay;
}

- (BOOL)setTcpNoDelay:(BOOL)nd {
  int nodelay = nd;
  lwip_socklen_t len = sizeof(nodelay);
  int res = lwip_setsockopt(self.lwip_fd, LWIP_SOL_SOCKET, LWIP_TCP_NODELAY,
                            &nodelay, len);

  if (res < 0) {
    [[self class] updateLastError];
    return NO;
  }

  return YES;
}

@end
