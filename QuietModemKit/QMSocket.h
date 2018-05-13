#import "QMSocketAddress.h"
#import <Foundation/Foundation.h>

@interface QMSocket : NSObject
+ (int)getLastError;
+ (NSString *)getLastErrorString;
- (BOOL)bind:(QMSocketAddress *)addr;
- (BOOL)connect:(QMSocketAddress *)addr;
- (BOOL)disconnect;
- (int)getRecvDataAvailable;
- (QMSocketAddress *)getLocalAddress;
- (QMSocketAddress *)getRemoteAddress;
- (BOOL)getBroadcast;
- (int)getReceiveBufferSize;
- (int)getSendBufferSize;
- (BOOL)getReuseAddress;
- (NSTimeInterval)getReceiveTimeout;
- (int)getTrafficClass;
- (BOOL)getOOBInline;
- (int)getSocketLinger;
- (BOOL)setBroadcast:(BOOL)broadcastBool;
- (BOOL)setReceiveBufferSize:(int)size;
- (BOOL)setSendBufferSize:(int)size;
- (BOOL)setReuseAddress:(BOOL)reuse;
- (BOOL)setReceiveTimeout:(NSTimeInterval)interval;
- (BOOL)setTrafficClass:(int)c;
- (BOOL)setKeepAlive:(BOOL)keepaliive;
- (BOOL)setOOBInline:(BOOL)oobinline;
- (BOOL)setSocketLinger:(int)linger;
- (int)getLastError;
- (NSString *)getLastErrorString;
- (BOOL)shutdownRead;
- (BOOL)shutdownWrite;
- (void)close;
@end
