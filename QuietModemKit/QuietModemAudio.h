#ifndef QuietModemAudio_h
#define QuietModemAudio_h

#import <Foundation/Foundation.h>

#include <stdlib.h>

static const unsigned int num_playback_channels = 2;
static const unsigned int num_record_channels = 2;

typedef float audio_sample_t;

@protocol QuietAudioProducer
- (ssize_t)produceAudioToSamples:(float *)samples withLength:(size_t)length;
@end

@protocol QuietAudioConsumer
- (ssize_t)consumeAudioFromSamples:(const float *)samples
                        withLength:(size_t)length;
@end

typedef struct {
  size_t num_frames;
  float *scratch;
  ssize_t (*produce)(void *, float *, size_t);
  void *produce_arg;
} quiet_audio_producer;

typedef struct {
  size_t num_frames;
  float *scratch;
  void (*consume)(void *, const float *, size_t);
  void *consume_arg;
} quiet_audio_consumer;

void convert_stereo2mono(const audio_sample_t *stereo_buf, float *mono_f,
                         size_t num_frames, unsigned int num_channels);
void convert_mono2stereo(const float *mono_f, audio_sample_t *stereo_buf,
                         size_t num_frames);
void sum_mono2stereo(const float *mono_f, audio_sample_t *stereo_buf,
                     size_t num_frames);

#endif /* QuietModemAudio_h */
