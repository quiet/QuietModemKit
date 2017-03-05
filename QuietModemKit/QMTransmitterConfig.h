#ifndef QMTransmitterConfig_h
#define QMTransmitterConfig_h

#import <Foundation/Foundation.h>
#include "quiet.h"

@interface QMTransmitterConfig : NSObject
- (id)initWithProfile:(NSString *)profile forKey:(NSString *)key;
- (id)initWithKey:(NSString *)key;
@property quiet_encoder_options *opt;
@property unsigned int numBuffers;
@property unsigned int bufferLength;

@end

#endif /* QMTransmitterConfig_h */
