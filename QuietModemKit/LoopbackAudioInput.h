#import <Foundation/Foundation.h>

#import "QuietModemAudio.h"

@interface LoopbackAudioInput : NSObject
- (id)initWithConsumer:(id<QuietAudioConsumer>)c;
@end
