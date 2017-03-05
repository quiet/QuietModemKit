#ifndef QMFrameTransmitter_h
#define QMFrameTransmitter_h

#import <Foundation/Foundation.h>
#include <AudioToolbox/AudioQueue.h>
#include <CoreAudio/CoreAudioTypes.h>

#include "quiet.h"
#include "QMTransmitterConfig.h"

@interface QMFrameTransmitter : NSObject
- (id)initWithConfig:(QMTransmitterConfig *)conf;
- (void)send:(NSData *)frame;
- (void)setBlocking:(long)seconds withNano:(long)nano;
- (void)setNonBlocking;
- (void)close;
@end

#endif /* QMFrameTransmitter_h */
