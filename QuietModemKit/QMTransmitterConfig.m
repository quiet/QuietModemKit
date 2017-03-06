#import "QMTransmitterConfig.h"
#import "QuietModemKitPrivate.h"


static const unsigned int default_num_buffers = 3;
static const unsigned int default_buffer_length = 4096;

@implementation QMTransmitterConfig

- (id)initWithProfile:(NSString *)profile forKey:(NSString *)key {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _opt = quiet_encoder_profile_str(profile.UTF8String, key.UTF8String);
    
    _numBuffers = default_num_buffers;
    _bufferLength = default_buffer_length;
    
    return self;
}

- (id)initWithKey:(NSString *)key {
    NSBundle *bundle = [NSBundle bundleForClass: [QMTransmitterConfig class]];
    NSString *profile_path = [bundle pathForResource:@"quiet-profiles" ofType:@"json"];
    NSString *profile = [NSString stringWithContentsOfFile:profile_path encoding:NSUTF8StringEncoding error:NULL];
    
    return [self initWithProfile:profile forKey: key];
}

- (void)dealloc {
    free(_opt);
}

@end
