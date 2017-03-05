#ifndef QMFrameReceiver_h
#define QMFrameReceiver_h

#import <Foundation/Foundation.h>
#include <AudioToolbox/AudioQueue.h>
#include <CoreAudio/CoreAudioTypes.h>
#include <AVFoundation/AVFoundation.h>

#include "QMReceiverConfig.h"
#include "quiet.h"

typedef void (^QMFrameReceiverCallback)(NSData *frame);

@interface QMFrameReceiver : NSObject
- (id)initWithConfig:(QMReceiverConfig *)conf;
- (NSData *)receive;
- (void)setBlocking:(long)seconds withNano:(long)nano;
- (void)setNonBlocking;
- (void)close;
@end

#endif /* QMFrameReceiver_h */
