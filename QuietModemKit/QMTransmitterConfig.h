#ifndef QMTransmitterConfig_h
#define QMTransmitterConfig_h

#import <Foundation/Foundation.h>

@interface QMTransmitterConfig : NSObject
- (id)initWithProfile:(NSString *)profile forKey:(NSString *)key;
- (id)initWithKey:(NSString *)key;
@property unsigned int numBuffers;
@property unsigned int bufferLength;

@end

#endif /* QMTransmitterConfig_h */
