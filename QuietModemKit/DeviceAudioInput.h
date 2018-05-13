#import <Foundation/Foundation.h>

#import "QuietModemAudio.h"

@interface DeviceAudioInput : NSObject
- (id)initWithConsumer:(id<QuietAudioConsumer>)c
        withNumBuffers:(unsigned int)numBuffers
      withBufferLength:(unsigned int)bufferLength;
@end
