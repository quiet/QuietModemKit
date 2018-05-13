#ifndef QMFrameTransmitter_h
#define QMFrameTransmitter_h

#import <Foundation/Foundation.h>

#import "QMTransmitterConfig.h"

@interface QMFrameTransmitter : NSObject
- (id)initWithConfig:(QMTransmitterConfig *)conf;
- (id)initLoopbackWithConfig:(QMTransmitterConfig *)conf;
- (void)send:(NSData *)frame;
- (void)setBlocking:(long)seconds withNano:(long)nano;
- (void)setNonBlocking;
- (void)close;
@end

#endif /* QMFrameTransmitter_h */
