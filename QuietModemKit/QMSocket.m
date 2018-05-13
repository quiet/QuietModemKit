#include <errno.h>

#import "QMSocket.h"
#import "QuietModemKitPrivate.h"

#import "QuietLwipInterface.h"

#include <quiet-lwip/lwip-netdb.h>
#include <quiet-lwip/lwip-socket.h>

@implementation QMSocket

static const NSString *lasterrorKey = @"QMSocket_Lasterror";

+ (void)updateLastError {
  NSNumber *lasterror = [NSNumber numberWithInt:errno];
  [[[NSThread currentThread] threadDictionary] setObject:lasterror
                                                  forKey:lasterrorKey];
}

+ (int)getLastError {
  NSNumber *lasterror =
      [[[NSThread currentThread] threadDictionary] objectForKey:lasterrorKey];
  if (lasterror == nil) {
    return 0;
  }
  return [lasterror intValue];
}

+ (NSString *)getLastErrorString {
  NSMutableData *str = [NSMutableData dataWithLength:100];
  int lasterror = [self getLastError];
  if (lasterror == 0) {
    return @"Success";
  }
  strerror_r(lasterror, [str mutableBytes], [str length]);
  return
      [NSString stringWithCString:[str bytes] encoding:NSASCIIStringEncoding];
}

- (BOOL)bind:(QMSocketAddress *)addr {
  struct lwip_sockaddr_in sock_addr;
  sock_addr.sin_family = LWIP_AF_INET;
  sock_addr.sin_port = htons((short)[addr port]);
  sock_addr.sin_addr.s_addr = [addr ip];

  int res = lwip_bind(self.lwip_fd, (struct lwip_sockaddr *)&sock_addr,
                      sizeof(sock_addr));

  if (res < 0) {
    [[self class] updateLastError];
    return NO;
  }

  return YES;
}

- (BOOL)connect:(QMSocketAddress *)addr {
  struct lwip_sockaddr_in sock_addr;
  sock_addr.sin_family = LWIP_AF_INET;
  sock_addr.sin_port = htons((short)[addr port]);
  sock_addr.sin_addr.s_addr = [addr ip];

  int res = lwip_connect(self.lwip_fd, (struct lwip_sockaddr *)&sock_addr,
                         sizeof(sock_addr));

  if (res < 0) {
    [[self class] updateLastError];
    return NO;
  }

  return YES;
}

- (BOOL)disconnect {
  struct lwip_sockaddr_in sock_addr;
  sock_addr.sin_family = LWIP_AF_UNSPEC;

  int res = lwip_connect(self.lwip_fd, (struct lwip_sockaddr *)&sock_addr,
                         sizeof(sock_addr));

  if (res < 0) {
    [[self class] updateLastError];
    return NO;
  }

  return YES;
}

- (int)getRecvDataAvailable {
  uint16_t avail = 0;
  int res = lwip_ioctl(self.lwip_fd, LWIP_FIONREAD, (void *)&avail);
  if (res < 0) {
    [[self class] updateLastError];
  }
  return avail;
}

- (QMSocketAddress *)getLocalAddress {
  struct lwip_sockaddr_in local;
  lwip_socklen_t local_len = sizeof(local);

  int res = lwip_getsockname(self.lwip_fd, (struct lwip_sockaddr *)&local,
                             &local_len);

  if (res < 0) {
    [[self class] updateLastError];
    return nil;
  }

  QMSocketAddress *addr = [[QMSocketAddress alloc] init];

  int port = ntohs(local.sin_port);
  quiet_lwip_ipv4_addr ip = local.sin_addr.s_addr;

  addr.port = port;
  addr.ip = ip;

  return addr;
}

- (QMSocketAddress *)getRemoteAddress {
  struct lwip_sockaddr_in remote;
  lwip_socklen_t remote_len = sizeof(remote);

  int res = lwip_getpeername(self.lwip_fd, (struct lwip_sockaddr *)&remote,
                             &remote_len);

  if (res < 0) {
    [[self class] updateLastError];
    return nil;
  }

  QMSocketAddress *addr = [[QMSocketAddress alloc] init];

  int port = ntohs(remote.sin_port);
  quiet_lwip_ipv4_addr ip = remote.sin_addr.s_addr;

  addr.port = port;
  addr.ip = ip;

  return addr;
}

- (BOOL)getBroadcast {
  int broadcast;
  lwip_socklen_t len = sizeof(broadcast);
  int res = lwip_getsockopt(self.lwip_fd, LWIP_SOL_SOCKET, LWIP_SO_BROADCAST,
                            &broadcast, &len);
  if (res < 0) {
    [[self class] updateLastError];
    return NO;
  }

  return broadcast;
}

- (int)getReceiveBufferSize {
  int buffer_size;
  lwip_socklen_t len = sizeof(buffer_size);
  int res = lwip_getsockopt(self.lwip_fd, LWIP_SOL_SOCKET, LWIP_SO_RCVBUF,
                            &buffer_size, &len);

  if (res < 0) {
    [[self class] updateLastError];
    return -1;
  }

  return buffer_size;
}

- (int)getSendBufferSize {
  int buffer_size;
  lwip_socklen_t len = sizeof(buffer_size);
  int res = lwip_getsockopt(self.lwip_fd, LWIP_SOL_SOCKET, LWIP_SO_SNDBUF,
                            &buffer_size, &len);

  if (res < 0) {
    [[self class] updateLastError];
    return -1;
  }

  return buffer_size;
}

- (BOOL)getReuseAddress {
  int reuse;
  lwip_socklen_t len = sizeof(reuse);
  int res = lwip_getsockopt(self.lwip_fd, LWIP_SOL_SOCKET, LWIP_SO_REUSEADDR,
                            &reuse, &len);

  if (res < 0) {
    [[self class] updateLastError];
    return NO;
  }

  return reuse;
}

- (NSTimeInterval)getReceiveTimeout {
  int timeout;
  lwip_socklen_t len = sizeof(timeout);
  int res = lwip_getsockopt(self.lwip_fd, LWIP_SOL_SOCKET, LWIP_SO_RCVTIMEO,
                            &timeout, &len);

  if (res < 0) {
    [[self class] updateLastError];
    return 0;
  }

  return ((double)timeout) / 1000.;
}

- (int)getTrafficClass {
  int class;
  lwip_socklen_t len = sizeof(class);
  int res =
      lwip_getsockopt(self.lwip_fd, LWIP_IPPROTO_IP, LWIP_IP_TOS, &class, &len);

  if (res < 0) {
    [[self class] updateLastError];
    return -1;
  }

  return class;
}

- (BOOL)getKeepAlive {
  int keepalive;
  lwip_socklen_t len = sizeof(keepalive);
  int res = lwip_getsockopt(self.lwip_fd, LWIP_SOL_SOCKET, LWIP_SO_KEEPALIVE,
                            &keepalive, &len);

  if (res < 0) {
    [[self class] updateLastError];
    return NO;
  }

  return keepalive;
}

- (BOOL)getOOBInline {
  int oob;
  lwip_socklen_t len = sizeof(oob);
  int res = lwip_getsockopt(self.lwip_fd, LWIP_SOL_SOCKET, LWIP_SO_OOBINLINE,
                            &oob, &len);

  if (res < 0) {
    [[self class] updateLastError];
    return NO;
  }

  return oob;
}

- (int)getSocketLinger {
  int linger;
  lwip_socklen_t len = sizeof(linger);
  int res = lwip_getsockopt(self.lwip_fd, LWIP_SOL_SOCKET, LWIP_SO_LINGER,
                            &linger, &len);

  if (res < 0) {
    [[self class] updateLastError];
    return -1;
  }

  return linger;
}

- (BOOL)setBroadcast:(BOOL)broadcastBool {
  int broadcast = broadcastBool;
  lwip_socklen_t len = sizeof(broadcast);
  int res = lwip_setsockopt(self.lwip_fd, LWIP_SOL_SOCKET, LWIP_SO_BROADCAST,
                            &broadcast, len);

  if (res < 0) {
    [[self class] updateLastError];
    return NO;
  }

  return YES;
}

- (BOOL)setReceiveBufferSize:(int)size {
  lwip_socklen_t len = sizeof(size);
  int res = lwip_setsockopt(self.lwip_fd, LWIP_SOL_SOCKET, LWIP_SO_RCVBUF,
                            &size, len);

  if (res < 0) {
    [[self class] updateLastError];
    return NO;
  }

  return YES;
}

- (BOOL)setSendBufferSize:(int)size {
  lwip_socklen_t len = sizeof(size);
  int res = lwip_setsockopt(self.lwip_fd, LWIP_SOL_SOCKET, LWIP_SO_SNDBUF,
                            &size, len);

  if (res < 0) {
    [[self class] updateLastError];
    return NO;
  }

  return YES;
}

- (BOOL)setReuseAddress:(BOOL)reuse {
  lwip_socklen_t len = sizeof(reuse);
  int res = lwip_setsockopt(self.lwip_fd, LWIP_SOL_SOCKET, LWIP_SO_REUSEADDR,
                            &reuse, len);

  if (res < 0) {
    [[self class] updateLastError];
    return NO;
  }

  return YES;
}

- (BOOL)setReceiveTimeout:(NSTimeInterval)interval {
  int timeout = (int)(interval * 1000.);
  lwip_socklen_t len = sizeof(timeout);
  int res = lwip_setsockopt(self.lwip_fd, LWIP_SOL_SOCKET, LWIP_SO_RCVTIMEO,
                            &timeout, len);

  if (res < 0) {
    [[self class] updateLastError];
    return NO;
  }

  return YES;
}

- (BOOL)setTrafficClass:(int)class {
  lwip_socklen_t len = sizeof(class);
  int res =
      lwip_setsockopt(self.lwip_fd, LWIP_IPPROTO_IP, LWIP_IP_TOS, &class, len);

  if (res < 0) {
    [[self class] updateLastError];
    return NO;
  }

  return YES;
}

    - (BOOL)setKeepAlive : (BOOL)ka {
  int keepalive = ka;
  lwip_socklen_t len = sizeof(keepalive);
  int res = lwip_setsockopt(self.lwip_fd, LWIP_SOL_SOCKET, LWIP_SO_KEEPALIVE,
                            &keepalive, len);

  if (res < 0) {
    [[self class] updateLastError];
    return NO;
  }

  return YES;
}

- (BOOL)setOOBInline:(BOOL)oi {
  int oob = oi;
  lwip_socklen_t len = sizeof(oob);
  int res = lwip_setsockopt(self.lwip_fd, LWIP_SOL_SOCKET, LWIP_SO_OOBINLINE,
                            &oob, len);

  if (res < 0) {
    [[self class] updateLastError];
    return NO;
  }

  return YES;
}

- (BOOL)setSocketLinger:(int)linger {
  lwip_socklen_t len = sizeof(linger);
  int res = lwip_setsockopt(self.lwip_fd, LWIP_SOL_SOCKET, LWIP_SO_LINGER,
                            &linger, len);

  if (res < 0) {
    [[self class] updateLastError];
    return NO;
  }

  return YES;
}

- (int)getLastError {
  return [[self class] getLastError];
}

- (NSString *)getLastErrorString {
  return [[self class] getLastErrorString];
}

- (BOOL)shutdownRead {
  int res = lwip_shutdown(self.lwip_fd, LWIP_SHUT_RD);
  return res >= 0;
}

- (BOOL)shutdownWrite {
  int res = lwip_shutdown(self.lwip_fd, LWIP_SHUT_WR);
  return res >= 0;
}

- (void)close {
  if (self.lwip_fd > 0) {
    lwip_close(self.lwip_fd);
  }
  self.lwip_fd = 0;
}

- (void)dealloc {
  [self close];
}
@end
