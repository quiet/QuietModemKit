#ifndef QMReceiverConfig_h
#define QMReceiverConfig_h

#import <Foundation/Foundation.h>
#include "quiet.h"

@interface QMReceiverConfig : NSObject
- (id)initWithProfile:(NSString *)profile forKey:(NSString *)key;
- (id)initWithKey:(NSString *)key;
@property quiet_decoder_options *opt;
@property unsigned int numBuffers;
@property unsigned int bufferLength;
@end

#endif /* QMReceiverConfig_h */
