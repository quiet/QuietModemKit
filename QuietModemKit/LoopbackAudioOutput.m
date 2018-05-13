#import "LoopbackAudioOutput.h"
#import "LoopbackAudio.h"

@implementation LoopbackAudioOutput

- (id)initWithProducer:(id<QuietAudioProducer>)p {
  self = [super init];
  if (!self) {
    return nil;
  }

  [LoopbackAudio addProducer:p];

  return self;
}

@end
