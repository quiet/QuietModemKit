#import "QMFrameTransmitter.h"
#import "QuietModemKitPrivate.h"

@implementation QMFrameTransmitter {
    AudioQueueRef output_queue;
    AudioQueueBufferRef *output_buffers;
    float *monoBuffer;
    unsigned int bufferLength;
    unsigned int numBuffers;
    quiet_encoder *encoder;
}

static const unsigned int numChannels = 2;

void output_callback(void *user_data, AudioQueueRef queue, AudioQueueBufferRef buffer) {
    float *casted_buffer = (float *)buffer->mAudioData;
    QMFrameTransmitter *e = (__bridge id)user_data;
    quiet_encoder *enc = e->encoder;
    // XXX check emit result, don't enqueue buffer if encoder is closed
    memset(casted_buffer, 0, buffer->mAudioDataBytesCapacity);
    ssize_t written = quiet_encoder_emit(enc, e->monoBuffer, e->bufferLength);
    written = written < 0 ? 0 : written;
    for (ssize_t i = 0; i < written; i += 1) {
        casted_buffer[i * numChannels] = e->monoBuffer[i];
    }
    /*
     for (int i = 0; i < 2 * 4096; i++) {
     casted_buffer[i] = 0.5 * sin(M_PI * 2 * phase);
     phase += 1/20.0;
     }
     */
    buffer->mAudioDataByteSize = buffer->mAudioDataBytesCapacity;
    AudioQueueEnqueueBuffer(queue, buffer, 0, NULL);
}

- (id)initWithConfig:(QMTransmitterConfig *)conf {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    encoder = quiet_encoder_create(conf.opt, 44100);
    numBuffers = conf.numBuffers;
    bufferLength = conf.bufferLength;
    monoBuffer = malloc(bufferLength * sizeof(float));
    
    AudioStreamBasicDescription format;
    format.mSampleRate = 44100.0f;
    format.mFormatID = kAudioFormatLinearPCM;
    format.mFormatFlags = kAudioFormatFlagIsFloat | kAudioFormatFlagIsPacked;
    format.mBitsPerChannel = sizeof(float) * 8;
    format.mChannelsPerFrame = numChannels;
    format.mBytesPerFrame = sizeof(float) * numChannels;
    format.mFramesPerPacket = 1;
    format.mBytesPerPacket = format.mBytesPerFrame * format.mFramesPerPacket;
    format.mReserved = 0;
    
    AudioQueueNewOutput(&format, output_callback, (__bridge void * _Nullable)(self), NULL, NULL, 0, &output_queue);
    
    output_buffers = malloc(numBuffers * sizeof(AudioQueueBufferRef));
    
    for (unsigned int i = 0; i < numBuffers; i++) {
        AudioQueueAllocateBuffer(output_queue, sizeof(float) * bufferLength * numChannels, &output_buffers[i]);
        output_buffers[i]->mAudioDataByteSize = sizeof(float) * bufferLength * numChannels;
        output_callback((__bridge void *)(self), output_queue, output_buffers[i]);
    }
    
    AudioQueueStart(output_queue, NULL);
    
    return self;
}

- (void)send:(NSData *)frame {
    quiet_encoder_send(encoder, frame.bytes, frame.length);
}

- (void)setBlocking:(long)seconds withNano:(long)nano {
    quiet_encoder_set_blocking(encoder, seconds, nano);
}

- (void)setNonBlocking {
    quiet_encoder_set_nonblocking(encoder);
}

- (void)close {
    quiet_encoder_close(encoder);
}

- (void)dealloc {
    quiet_encoder_destroy(encoder);
}

@end
