#import "QuietLwipInterface.h"
#import "QuietModemKitPrivate.h"

#include <quiet-lwip/lwip-netdb.h>
#include <quiet-lwip/lwip-socket.h>

@implementation QuietLwipInterface {
  quiet_lwip_interface *interface;
  dispatch_once_t closeOnce;
}

static const size_t ipv4_str_len = (4 * 3) + 3 + 1;

+ (void)initializeQuietLwip {
  static dispatch_once_t lwip_initialized;
  dispatch_once(&lwip_initialized, ^{
    quiet_lwip_init();
  });
}

+ (quiet_lwip_ipv4_addr)strAddressToBytes:(NSString *)strAddr {
  if (!strAddr) {
    return 0;
  }

  const char *addr = [strAddr cStringUsingEncoding:NSASCIIStringEncoding];

  struct lwip_addrinfo hints;
  memset(&hints, 0, sizeof(struct lwip_addrinfo));
  hints.ai_family = LWIP_AF_INET;

  struct lwip_addrinfo *result;
  int error = lwip_getaddrinfo(addr, NULL, &hints, &result);

  if (error) {
    return 0;
  }

  quiet_lwip_ipv4_addr ret = 0;
  if (result[0].ai_addrlen == sizeof(struct lwip_sockaddr_in)) {
    struct lwip_sockaddr_in addr =
        *(struct lwip_sockaddr_in *)(result[0].ai_addr);
    ret = addr.sin_addr.s_addr;
  }

  lwip_freeaddrinfo(result);
  return ret;
}

+ (NSString *)byteAddressToStr:(quiet_lwip_ipv4_addr)byteAddr {
  struct lwip_in_addr ip_addr;
  ip_addr.s_addr = byteAddr;
  NSMutableData *addr = [NSMutableData dataWithLength:ipv4_str_len];
  char *res =
      lwip_inet_ntoa_r(&ip_addr, [addr mutableBytes], (int)[addr length]);

  if (!res) {
    return nil;
  }
  return [[NSString alloc] initWithData:addr encoding:NSASCIIStringEncoding];
}

- (id)initWithConfig:(QMNetworkInterfaceConfig *)interfaceConfig {
  quiet_lwip_driver_config *conf = malloc(sizeof(quiet_lwip_driver_config));
  conf->encoder_opt = interfaceConfig.txConf.opt;
  conf->encoder_rate = 44100;
  conf->decoder_opt = interfaceConfig.rxConf.opt;
  conf->decoder_rate = 44100;
  memcpy(conf->hardware_addr, [interfaceConfig.hardwareAddress bytes],
         sizeof(conf->hardware_addr));

  quiet_lwip_ipv4_addr localAddr, netmask, gateway;
  localAddr =
      [QuietLwipInterface strAddressToBytes:interfaceConfig.localInetAddress];
  netmask = [QuietLwipInterface strAddressToBytes:interfaceConfig.localNetmask];
  gateway = [QuietLwipInterface strAddressToBytes:interfaceConfig.localGateway];

  interface = quiet_lwip_create(conf, localAddr, netmask, gateway);

  free(conf);

  if (!interface) {
    return nil;
  }

  if (localAddr == 0) {
    quiet_lwip_autoip(interface);
  }

  return self;
}

- (ssize_t)produceAudioToSamples:(float *)samples withLength:(size_t)length {
  return quiet_lwip_get_next_audio_packet(interface, samples, length);
}

- (ssize_t)consumeAudioFromSamples:(const float *)samples
                        withLength:(size_t)length {
  return quiet_lwip_recv_audio_packet(interface, samples, length);
}

- (NSString *)getLocalAddress {
  return
      [[self class] byteAddressToStr:quiet_lwip_get_local_address(interface)];
}

- (NSString *)getNetmask {
  return [[self class] byteAddressToStr:quiet_lwip_get_netmask(interface)];
}

- (NSString *)getGateway {
  return [[self class] byteAddressToStr:quiet_lwip_get_gateway(interface)];
}

- (void)close {
  dispatch_once(&closeOnce, ^{
    quiet_lwip_close(interface);
  });
}

- (void)dealloc {
  [self close];
  quiet_lwip_destroy(interface);
}

@end
