#import "QMFrameReceiver.h"
#import "QuietModemKitPrivate.h"

@implementation QMFrameReceiver {
    AudioQueueRef queue;
    AudioQueueBufferRef *buffers;
    quiet_decoder *decoder;
    QMFrameReceiverCallback callback;
    uint8_t *recvBuffer;
    float *monoBuffer;
    unsigned int recvBufferLength;
    unsigned int audioBufferLength;
    unsigned int audioNumBuffers;
}

static void quiet_frame_receiver_callback(void *user_data, AudioQueueRef queue, AudioQueueBufferRef buffer, const AudioTimeStamp *inStartTime, UInt32 inNumberPacketDescriptions, const AudioStreamPacketDescription *inPacketDescs) {
    float *casted_buffer = (float *)buffer->mAudioData;
    QMFrameReceiver *d = (__bridge id)user_data;
    quiet_decoder *dec = d->decoder;
    for (int i = 0; i < d->audioBufferLength; i++) {
        d->monoBuffer[i] = casted_buffer[i * 2];
    }
    quiet_decoder_consume(dec, d->monoBuffer, d->audioBufferLength);
    // XXX no callback?
    // XXX don't enqueue on consume close
    if (d->callback != NULL) {
        ssize_t written = 1;
        while (written > 0) {
            written = quiet_decoder_recv(dec, d->recvBuffer, d->recvBufferLength);
            if (written > 0) {
                NSData *recv = [NSData dataWithBytes:d->recvBuffer length:written];
                d->callback(recv);
            }
        }
    }
    AudioQueueEnqueueBuffer(queue, buffer, 0, NULL);
}

- (id)initWithConfig:(QMReceiverConfig *)conf {
    if ([[AVAudioSession sharedInstance] recordPermission] != AVAudioSessionRecordPermissionGranted) {
        return nil;
    }
    
    self = [super init];
    if (!self) {
        return nil;
    }
    decoder = quiet_decoder_create(conf.opt, 44100);
    
    callback = NULL;
    audioNumBuffers = conf.numBuffers;
    audioBufferLength = conf.bufferLength;
    monoBuffer = malloc(audioBufferLength * sizeof(float));
    recvBufferLength = 1 << 16;
    recvBuffer = malloc(recvBufferLength);
    
    AudioStreamBasicDescription format;
    format.mSampleRate = 44100;
    format.mFormatID = kAudioFormatLinearPCM;
    format.mFormatFlags = kLinearPCMFormatFlagIsFloat;
    format.mBitsPerChannel = sizeof(float) * 8;
    format.mChannelsPerFrame = 2;
    format.mBytesPerFrame = sizeof(float) * 2;
    format.mFramesPerPacket = 1;
    format.mBytesPerPacket = format.mBytesPerFrame * format.mFramesPerPacket;
    
    AudioQueueNewInput(&format, quiet_frame_receiver_callback, (__bridge void * _Nullable)(self), NULL, kCFRunLoopCommonModes, 0, &queue);
    
    buffers = malloc(audioNumBuffers * sizeof(AudioQueueBufferRef));
    
    for (unsigned int i = 0; i < audioNumBuffers; i++) {
        AudioQueueAllocateBuffer(queue, sizeof(float) * audioBufferLength * 2, &buffers[i]);
        buffers[i]->mAudioDataByteSize = sizeof(float) * audioBufferLength * 2;
        quiet_frame_receiver_callback((__bridge void *)(self), queue, buffers[i], NULL, 0, NULL);
    }
    
    AudioQueueStart(queue, NULL);
    
    return self;
}

- (void)setReceiveCallback:(QMFrameReceiverCallback)newCallback {
    callback = newCallback;
}

- (NSData *)receive {
    ssize_t written = quiet_decoder_recv(decoder, recvBuffer, recvBufferLength);
    if (written > 0) {
        NSData *recv = [NSData dataWithBytes:recvBuffer length:written];
        return recv;
    }
    return nil;
}

- (void)setBlocking:(long)seconds withNano:(long)nano {
    quiet_decoder_set_blocking(decoder, seconds, nano);
}

- (void)setNonBlocking {
    quiet_decoder_set_nonblocking(decoder);
}

- (void)close {
    quiet_decoder_close(decoder);
}

- (void)dealloc {
    AudioQueueStop(queue, true);
    if (recvBuffer) {
        free(recvBuffer);
    }
    quiet_decoder_destroy(decoder);
}

@end
