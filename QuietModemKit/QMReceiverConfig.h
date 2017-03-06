#ifndef QMReceiverConfig_h
#define QMReceiverConfig_h

#import <Foundation/Foundation.h>

@interface QMReceiverConfig : NSObject
- (id)initWithProfile:(NSString *)profile forKey:(NSString *)key;
- (id)initWithKey:(NSString *)key;
@property unsigned int numBuffers;
@property unsigned int bufferLength;
@end

#endif /* QMReceiverConfig_h */
