#import <Foundation/Foundation.h>

#import "QuietModemAudio.h"

@interface LoopbackAudio : NSObject
+ (void)addProducer:(id<QuietAudioProducer>)p;
+ (void)addConsumer:(id<QuietAudioConsumer>)c;
+ (void)removeProducer:(id<QuietAudioProducer>)p;
+ (void)removeConsumer:(id<QuietAudioConsumer>)c;
@end
