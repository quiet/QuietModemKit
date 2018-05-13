#import "QMSocket.h"

@interface QMTcpSocket : QMSocket
+ (id)tcpSocket;
+ (id)tcpSocketWithAddress:(QMSocketAddress *)addr;
- (id)init;
- (id)initWithAddress:(QMSocketAddress *)addr;
- (BOOL)listen;
- (QMTcpSocket *)accept;
- (int)recvData:(NSMutableData *)data;
- (int)sendData:(NSData *)data;
- (BOOL)getTcpNoDelay;
- (BOOL)setTcpNoDelay:(BOOL)nd;
@end
