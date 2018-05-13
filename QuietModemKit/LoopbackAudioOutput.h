#import <Foundation/Foundation.h>

#import "QuietModemAudio.h"

@interface LoopbackAudioOutput : NSObject
- (id)initWithProducer:(id<QuietAudioProducer>)p;
@end
