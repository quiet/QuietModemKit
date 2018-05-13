#import "QMSocket.h"

@interface QMUdpSocket : QMSocket
+ (id)udpSocketWithAddress:(QMSocketAddress *)addr;
- (id)initWithAddress:(QMSocketAddress *)addr;
- (int)recvData:(NSMutableData *)data fromAddress:(QMSocketAddress **)src;
- (int)sendData:(NSData *)data toAddress:(QMSocketAddress *)dst;
@end
