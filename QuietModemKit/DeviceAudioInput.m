#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioQueue.h>
#import <CoreAudio/CoreAudioTypes.h>

#import "DeviceAudioInput.h"

@implementation DeviceAudioInput {
  id<QuietAudioConsumer> consumer;
  unsigned int numBuffers;
  unsigned int bufferLength;
  NSMutableData *mono;
  AudioQueueRef queue;
  AudioQueueBufferRef *buffers;
  DeviceAudioInput *inUseAudio;
}

static void input_callback(void *user_data, AudioQueueRef queue,
                           AudioQueueBufferRef buffer,
                           const AudioTimeStamp *inStartTime,
                           UInt32 inNumberPacketDescriptions,
                           const AudioStreamPacketDescription *inPacketDescs) {
  float *casted_buffer = (float *)buffer->mAudioData;
  DeviceAudioInput *d = (__bridge id)user_data;
  float *mono = [d->mono mutableBytes];
  for (int i = 0; i < d->bufferLength; i++) {
    mono[i] = casted_buffer[i * num_record_channels];
  }

  ssize_t read =
      [d->consumer consumeAudioFromSamples:mono withLength:d->bufferLength];

  if (read == 0) {
    AudioQueueStop(queue, true);
    return;
  }

  AudioQueueEnqueueBuffer(queue, buffer, 0, NULL);
}

static void listener_callback(void *user_data, AudioQueueRef queue,
                              AudioQueuePropertyID prop) {
  DeviceAudioInput *p = (__bridge id)user_data;
  UInt32 res;
  UInt32 resSize = sizeof(res);
  AudioQueueGetProperty(queue, kAudioQueueProperty_IsRunning, &res, &resSize);
  if (resSize == sizeof(UInt32) && res == 0) {
    p->inUseAudio = nil;
  }
}

- (id)initWithConsumer:(id<QuietAudioConsumer>)c
        withNumBuffers:(unsigned int)withNumBuffers
      withBufferLength:(unsigned int)withBufferLength {
  if ([[AVAudioSession sharedInstance] recordPermission] !=
      AVAudioSessionRecordPermissionGranted) {
    return nil;
  }

  NSError *err = nil;
  [[AVAudioSession sharedInstance]
      setCategory:AVAudioSessionCategoryPlayAndRecord
      withOptions:(AVAudioSessionCategoryOptionDefaultToSpeaker |
                   AVAudioSessionCategoryOptionMixWithOthers)
            error:&err];

  if (err != nil) {
    return nil;
  }

  self = [super init];
  if (!self) {
    return nil;
  }

  consumer = c;
  numBuffers = withNumBuffers;
  bufferLength = withBufferLength;
  mono = [[NSMutableData alloc] initWithLength:(bufferLength * sizeof(float))];
  inUseAudio = self;

  AudioStreamBasicDescription format;
  format.mSampleRate = 44100.f;
  format.mFormatID = kAudioFormatLinearPCM;
  format.mFormatFlags = kLinearPCMFormatFlagIsFloat | kAudioFormatFlagIsPacked;
  format.mBitsPerChannel = sizeof(float) * 8;
  format.mChannelsPerFrame = num_record_channels;
  format.mBytesPerFrame = sizeof(float) * num_record_channels;
  format.mFramesPerPacket = 1;
  format.mBytesPerPacket = format.mBytesPerFrame * format.mFramesPerPacket;
  format.mReserved = 0;

  AudioQueueNewInput(&format, input_callback, (__bridge void *_Nullable)(self),
                     NULL, NULL, 0, &queue);

  buffers = malloc(numBuffers * sizeof(AudioQueueBufferRef));

  for (unsigned int i = 0; i < numBuffers; i++) {
    AudioQueueAllocateBuffer(
        queue, sizeof(float) * bufferLength * num_record_channels, &buffers[i]);
    buffers[i]->mAudioDataByteSize =
        sizeof(float) * bufferLength * num_record_channels;
    input_callback((__bridge void *)(self), queue, buffers[i], NULL, 0, NULL);
  }
  AudioQueueAddPropertyListener(queue, kAudioQueueProperty_IsRunning,
                                listener_callback,
                                (__bridge void *_Nullable)self);
  AudioQueueStart(queue, NULL);

  return self;
}

- (void)dealloc {
  AudioQueueDispose(queue, true);
}
@end
