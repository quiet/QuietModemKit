#import "LoopbackAudioInput.h"
#import "LoopbackAudio.h"

@implementation LoopbackAudioInput

- (id)initWithConsumer:(id<QuietAudioConsumer>)c {
  self = [super init];
  if (!self) {
    return nil;
  }

  [LoopbackAudio addConsumer:c];

  return self;
}

@end
