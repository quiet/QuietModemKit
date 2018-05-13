#import <Foundation/Foundation.h>

@interface QMSocketAddress : NSObject
+ (id)withIpAddress:(NSString *)ip;
+ (id)withIpAddress:(NSString *)ip withPort:(NSUInteger)port;
- (id)initWithIpAddress:(NSString *)ip;
- (id)initWithIpAddress:(NSString *)ip withPort:(NSUInteger)port;
- (NSString *)addr;
@property(readonly) NSUInteger port;
@end
