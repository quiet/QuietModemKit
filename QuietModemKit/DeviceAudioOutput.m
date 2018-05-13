#import <AudioToolbox/AudioQueue.h>

#import "DeviceAudioOutput.h"
#import "quiet.h"

@implementation DeviceAudioOutput {
  id<QuietAudioProducer> producer;
  unsigned int numBuffers;
  unsigned int bufferLength;
  NSMutableData *mono;
  AudioQueueRef output_queue;
  AudioQueueBufferRef *output_buffers;
  DeviceAudioOutput *inUseAudio;
}

static void output_callback(void *user_data, AudioQueueRef queue,
                            AudioQueueBufferRef buffer) {
  float *casted_buffer = (float *)buffer->mAudioData;
  DeviceAudioOutput *p = (__bridge id)user_data;
  memset(casted_buffer, 0, buffer->mAudioDataBytesCapacity);
  float *mono = [p->mono mutableBytes];

  ssize_t written =
      [p->producer produceAudioToSamples:mono withLength:p->bufferLength];

  if (written == 0) {
    AudioQueueStop(queue, false);
    return;
  }

  written = (written < 0) ? 0 : written;

  for (ssize_t i = 0; i < written; i += 1) {
    casted_buffer[i * num_playback_channels] = mono[i];
  }

  buffer->mAudioDataByteSize = buffer->mAudioDataBytesCapacity;
  AudioQueueEnqueueBuffer(queue, buffer, 0, NULL);
}

static void listener_callback(void *user_data, AudioQueueRef queue,
                              AudioQueuePropertyID prop) {
  DeviceAudioOutput *p = (__bridge id)user_data;
  UInt32 res;
  UInt32 resSize = sizeof(res);
  AudioQueueGetProperty(queue, kAudioQueueProperty_IsRunning, &res, &resSize);
  if (resSize == sizeof(UInt32) && res == 0) {
    p->inUseAudio = nil;
  }
}

- (id)initWithProducer:(id<QuietAudioProducer>)p
        withNumBuffers:(unsigned int)withNumBuffers
      withBufferLength:(unsigned int)withBufferLength {
  self = [super init];
  if (!self) {
    return nil;
  }

  producer = p;
  numBuffers = withNumBuffers;
  bufferLength = withBufferLength;
  mono = [[NSMutableData alloc] initWithLength:(bufferLength * sizeof(float))];
  inUseAudio = self;

  AudioStreamBasicDescription format;
  format.mSampleRate = 44100.f;
  format.mFormatID = kAudioFormatLinearPCM;
  format.mFormatFlags = kAudioFormatFlagIsFloat | kAudioFormatFlagIsPacked;
  format.mBitsPerChannel = sizeof(float) * 8;
  format.mChannelsPerFrame = num_playback_channels;
  format.mBytesPerFrame = sizeof(float) * num_playback_channels;
  format.mFramesPerPacket = 1;
  format.mBytesPerPacket = format.mBytesPerFrame * format.mFramesPerPacket;
  format.mReserved = 0;

  AudioQueueNewOutput(&format, output_callback,
                      (__bridge void *_Nullable)(self), NULL, NULL, 0,
                      &output_queue);

  output_buffers = malloc(numBuffers * sizeof(AudioQueueBufferRef));

  for (unsigned int i = 0; i < numBuffers; i++) {
    AudioQueueAllocateBuffer(
        output_queue, sizeof(float) * bufferLength * num_playback_channels,
        &output_buffers[i]);
    output_buffers[i]->mAudioDataByteSize =
        sizeof(float) * bufferLength * num_playback_channels;
    output_callback((__bridge void *)(self), output_queue, output_buffers[i]);
  }
  AudioQueueAddPropertyListener(output_queue, kAudioQueueProperty_IsRunning,
                                listener_callback,
                                (__bridge void *_Nullable)(self));
  AudioQueueStart(output_queue, NULL);

  return self;
}

- (void)dealloc {
  AudioQueueDispose(output_queue, true);
}
@end
