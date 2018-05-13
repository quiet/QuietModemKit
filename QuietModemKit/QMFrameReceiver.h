#ifndef QMFrameReceiver_h
#define QMFrameReceiver_h

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioQueue.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <Foundation/Foundation.h>

#import "QMReceiverConfig.h"

typedef void (^QMFrameReceiverCallback)(NSData *frame);

@interface QMFrameReceiver : NSObject
- (id)initWithConfig:(QMReceiverConfig *)conf;
- (id)initLoopbackWithConfig:(QMReceiverConfig *)conf;
- (NSData *)receive;
- (size_t)receiveTo:(NSMutableData*)data;
- (void)setReceiveCallback:(QMFrameReceiverCallback)callback;
- (void)setReceiveCallback:(QMFrameReceiverCallback)callback onQueue:(dispatch_queue_t)queue;
- (void)setBlocking:(long)seconds withNano:(long)nano;
- (void)setNonBlocking;
- (void)close;
@end

#endif /* QMFrameReceiver_h */
