#import <Foundation/Foundation.h>

#import "QuietModemAudio.h"

@interface DeviceAudioOutput : NSObject
- (id)initWithProducer:(id<QuietAudioProducer>)p
        withNumBuffers:(unsigned int)numBuffers
      withBufferLength:(unsigned int)bufferLength;
@end
